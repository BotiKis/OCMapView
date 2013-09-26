//
//  OCMapView.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCMapView.h"

@interface OCMapView ()
@property (nonatomic, strong) NSMutableSet *allAnnotations;
@property (nonatomic) MKCoordinateRegion lastRefreshedMapRegion;
@property (nonatomic) MKMapRect lastRefreshedMapRect;
@property (nonatomic) BOOL neeedsClustering;

@property (nonatomic, strong) NSArray *reclusterOnChangeProperties;
@end

@implementation OCMapView

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit;
{
    _allAnnotations = [[NSMutableSet alloc] init];
    _annotationsToIgnore = [[NSMutableSet alloc] init];
    _clusteringMethod = OCClusteringMethodBubble;
    _clusterSize = 0.2;
    _minLongitudeDeltaToCluster = 0.0;
    _minimumAnnotationCountPerCluster = 0;
    _clusteringEnabled = YES;
    _clusterByGroupTag = NO;
    _clusterInvisibleViews = NO;
    _neeedsClustering = YES;
    
    // define relevant properties (those, which will affect the clustering)
    self.reclusterOnChangeProperties = @[@"annotationsToIgnore",
                                         @"clusteringEnabled",
                                         @"clusteringMethod",
                                         @"clusterSize",
                                         @"clusterByGroupTag",
                                         @"minLongitudeDeltaToCluster",
                                         @"minimumAnnotationCountPerCluster",
                                         @"clusterInvisibleViews",
                                         @"annotationsToIgnore"];
    
    // listen to changes
    for (NSString *keyPath in self.reclusterOnChangeProperties) {
        [self addObserver:self forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)dealloc
{
    for (NSString *keyPath in self.reclusterOnChangeProperties) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

#pragma mark - MKMapView

- (void)addAnnotation:(id < MKAnnotation >)annotation{
    [_allAnnotations addObject:annotation];
    self.neeedsClustering = YES;
    [self doClustering];
}

- (void)addAnnotations:(NSArray *)annotations{
    [_allAnnotations addObjectsFromArray:annotations];
    self.neeedsClustering = YES;
    [self doClustering];
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation{
    [_allAnnotations removeObject:annotation];
    self.neeedsClustering = YES;
    [self doClustering];
}

- (void)removeAnnotations:(NSArray *)annotations{
    for (id<MKAnnotation> annotation in annotations) {
        [_allAnnotations removeObject:annotation];
    }
    self.neeedsClustering = YES;
    [self doClustering];
}

#pragma mark - Properties
//
// Returns, like the original method,
// all annotations in the map unclustered.
- (NSArray *)annotations {
    return [_allAnnotations allObjects];
}

//
// Returns all annotations which are actually displayed on the map. (clusters)
- (NSArray *)displayedAnnotations {
    return super.annotations;
}

//
// Observe properties, that will need reclustering on change
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context;
{
    if ([self.reclusterOnChangeProperties containsObject:keyPath]) {
        if (![[change objectForKey:NSKeyValueChangeNewKey]
              isEqual:[change objectForKey:NSKeyValueChangeOldKey]]) {
            self.neeedsClustering = YES;
        }
    }
}

#pragma mark - Clustering

- (void)doClustering;
{
    // only recluster if, annotations did change, map was zoomed or,
    // map was panned significantly
    if(!self.neeedsClustering && !MKMapRectIsNull(self.lastRefreshedMapRect) &&
       ![self mapWasZoomed] && ![self mapWasPannedSignificantly]){
        // no update needed
        return;
    }
    
    NSMutableArray *annotationsToCluster = nil;
    
    // Filter invisible (eg. out of visible map rect) annotations, if wanted
    if (self.clusterInvisibleViews) {
        annotationsToCluster = [[_allAnnotations allObjects] mutableCopy];
    } else {
        annotationsToCluster = [[self filterAnnotationsForVisibleMap:[_allAnnotations allObjects]] mutableCopy];
    }
    
    // Remove the annotation which should be ignored
    [annotationsToCluster removeObjectsInArray:[_annotationsToIgnore allObjects]];
    
    // Cluster annotations, when enabled and map is above the minimum zoom
    NSArray *clusteredAnnotations;
    if (_clusteringEnabled && (self.region.span.longitudeDelta > _minLongitudeDeltaToCluster))
    {
        //calculate cluster radius
        CLLocationDistance clusterRadius = self.region.span.longitudeDelta * _clusterSize;
        
        // clustering
        if (self.clusteringMethod == OCClusteringMethodBubble) {
            clusteredAnnotations = [OCAlgorithms bubbleClusteringWithAnnotations:annotationsToCluster
                                                                   clusterRadius:clusterRadius
                                                                         grouped:self.clusterByGroupTag];
        } else {
            clusteredAnnotations =[OCAlgorithms gridClusteringWithAnnotations:annotationsToCluster
                                                                  clusterRect:MKCoordinateSpanMake(clusterRadius, clusterRadius)
                                                                      grouped:self.clusterByGroupTag];
        }
    }
    // pass through without when not
    else{
        clusteredAnnotations = annotationsToCluster;
    }
    
    NSMutableArray *annotationsToDisplay = [clusteredAnnotations mutableCopy];
    [annotationsToDisplay addObjectsFromArray:[_annotationsToIgnore allObjects]];
    
    // check minumum cluster size
    for (NSInteger i=0; i<annotationsToDisplay.count; i++) {
        OCAnnotation *ocAnnotation = annotationsToDisplay[i];
        if ([ocAnnotation isKindOfClass:[OCAnnotation class]] &&
            ocAnnotation.annotationsInCluster.count < self.minimumAnnotationCountPerCluster) {
            [annotationsToDisplay removeObject:ocAnnotation];
            [annotationsToDisplay addObjectsFromArray:ocAnnotation.annotationsInCluster];
            i--; // we removed one object, go back one (otherwise some will be skipped)
        }
    }
    
    // update visible annotations
    for (id<MKAnnotation> annotation in self.displayedAnnotations) {
        if (annotation == self.userLocation) {
            continue;
        }
        
        // remove old annotations
        if (![annotationsToDisplay containsObject:annotation]) {
            [super removeAnnotation:annotation];
        } else {
            [annotationsToDisplay removeObject:annotation];
        }
    }
    
    // add not existing annotations
    [super addAnnotations:annotationsToDisplay];
    
    // update last rects & needs clustering
    self.lastRefreshedMapRect = self.visibleMapRect;
    self.lastRefreshedMapRegion = self.region;
    self.neeedsClustering = NO;
}

#pragma mark map rect changes tracking

- (BOOL)mapWasZoomed;
{
    return (fabs(self.lastRefreshedMapRect.size.width - self.visibleMapRect.size.width) > 0.1f);
}

- (BOOL)mapWasPannedSignificantly;
{
    CGPoint lastPoint = [self convertCoordinate:self.lastRefreshedMapRegion.center toPointToView:self];
    CGPoint currentPoint = [self convertCoordinate:self.region.center toPointToView:self];
    
    return ((fabs(lastPoint.x - currentPoint.x) > self.frame.size.width/3.0) ||
            (fabs(lastPoint.y - currentPoint.y) > self.frame.size.height/3.0));
}

#pragma mark - Helpers

- (NSArray *)filterAnnotationsForVisibleMap:(NSArray *)annotationsToFilter{
    // return array
    NSMutableArray *filteredAnnotations = [[NSMutableArray alloc] initWithCapacity:[annotationsToFilter count]];
    
    // border calculation
    CLLocationDistance a = self.region.span.latitudeDelta / 2.0;
    CLLocationDistance b = self.region.span.longitudeDelta / 2.0;
    CLLocationDistance radius = sqrt(pow(a,2.0) + pow(b,2.0));
    
    for (id<MKAnnotation> annotation in annotationsToFilter) {
        // if annotation is not inside the coordinates, kick it
        if ((CLLocationCoordinateDistance([annotation coordinate], self.centerCoordinate) <= radius)) {
            [filteredAnnotations addObject:annotation];
        }
    }
    
    return filteredAnnotations;
}

@end
