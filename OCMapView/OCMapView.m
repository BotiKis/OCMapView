//
//  OCMapView.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCMapView.h"



@implementation OCMapView
{
    BOOL _clusteringEnabled;
    NSMutableSet *_allAnnotations;
    MKCoordinateRegion _lastRefreshedMapRegion;
    MKMapRect _lastRefreshedMapRect;
    NSArray *_reclusterOnChangeProperties;
    
    NSTimer *_doClusteringTimer;
}

@synthesize clusteringEnabled = _clusteringEnabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
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
    
    // define relevant properties (those, which will affect the clustering)
    _reclusterOnChangeProperties = @[@"annotationsToIgnore",
                                     @"clusteringEnabled",
                                     @"clusteringMethod",
                                     @"clusterSize",
                                     @"clusterByGroupTag",
                                     @"minLongitudeDeltaToCluster",
                                     @"minimumAnnotationCountPerCluster",
                                     @"clusterInvisibleViews",
                                     @"annotationsToIgnore"];
    
    // listen to changes
    for (NSString *keyPath in _reclusterOnChangeProperties) {
        [self addObserver:self forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)dealloc
{
    if(_doClusteringTimer) {
        [_doClusteringTimer invalidate];
        _doClusteringTimer = nil;
    }
    for (NSString *keyPath in _reclusterOnChangeProperties) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

#pragma mark - MKMapView

- (void)addAnnotation:(id < MKAnnotation >)annotation {
    [_allAnnotations addObject:annotation];
    [self doClustering];
}

- (void)addAnnotations:(NSArray *)annotations {
    [_allAnnotations addObjectsFromArray:annotations];
    [self doClustering];
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation {
    [_allAnnotations removeObject:annotation];
    [self doClustering];
}

- (void)removeAnnotations:(NSArray *)annotations{
    for (id<MKAnnotation> annotation in annotations) {
        [_allAnnotations removeObject:annotation];
    }
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
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;
{
    if ([_reclusterOnChangeProperties containsObject:keyPath]) {
        if (![[change objectForKey:NSKeyValueChangeNewKey]
              isEqual:[change objectForKey:NSKeyValueChangeOldKey]])
        {
            [self doClustering];
        }
    }
}

#pragma mark - Clustering

- (void)doClustering
{
    if(!_doClusteringTimer) {
        _doClusteringTimer = [NSTimer scheduledTimerWithTimeInterval:0.0
                                                              target:self
                                                            selector:@selector(doClusteringNow)
                                                            userInfo:nil
                                                             repeats:NO];
    }
}

- (void)doClusteringNow
{
    [_doClusteringTimer invalidate];
    _doClusteringTimer = nil;
    
    NSMutableArray *annotationsToCluster = nil;
    MKCoordinateRegion self_region = self.region;
    
    // Filter invisible (eg. out of visible map rect) annotations, if wanted
    if(self.clusterInvisibleViews) {
        annotationsToCluster = [[_allAnnotations allObjects] mutableCopy];
    } else {
        annotationsToCluster = [[self filterAnnotationsForVisibleMap:[_allAnnotations allObjects]] mutableCopy];
    }
    
    // Remove the annotation which should be ignored
    [annotationsToCluster removeObjectsInArray:[_annotationsToIgnore allObjects]];
    
    // Cluster annotations, when enabled and map is above the minimum zoom
    NSArray *clusteredAnnotations;
    if (_clusteringEnabled && (self_region.span.longitudeDelta > _minLongitudeDeltaToCluster))
    {
        //calculate cluster radius
        CLLocationDistance clusterRadius = self_region.span.longitudeDelta * _clusterSize;
        
        // clustering
        if (self.clusteringMethod == OCClusteringMethodBubble) {
            clusteredAnnotations = [OCAlgorithms bubbleClusteringWithAnnotations:annotationsToCluster
                                                                   clusterRadius:clusterRadius
                                                                         grouped:self.clusterByGroupTag];
        } else {
            clusteredAnnotations = [OCAlgorithms gridClusteringWithAnnotations:annotationsToCluster
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
    _lastRefreshedMapRect = self.visibleMapRect;
    _lastRefreshedMapRegion = self.region;
}

#pragma mark map rect changes tracking

- (BOOL)mapWasZoomed
{
    return (fabs(_lastRefreshedMapRect.size.width - self.visibleMapRect.size.width) > 0.1f);
}

- (BOOL)mapWasPannedSignificantly
{
    CGPoint lastPoint = [self convertCoordinate:_lastRefreshedMapRegion.center toPointToView:self];
    CGPoint currentPoint = [self convertCoordinate:self.region.center toPointToView:self];
    
    return ((fabs(lastPoint.x - currentPoint.x) > self.frame.size.width/3.0) ||
            (fabs(lastPoint.y - currentPoint.y) > self.frame.size.height/3.0));
}

#pragma mark - Helpers

- (NSArray *)filterAnnotationsForVisibleMap:(NSArray *)annotationsToFilter
{
    NSMutableArray *filteredAnnotations = [[NSMutableArray alloc] initWithCapacity:[annotationsToFilter count]];
    
    MKCoordinateRegion self_region = self.region;
    
    for (id<MKAnnotation> annotation in annotationsToFilter)
    {
        // if annotation is not inside the coordinates, kick it
        if(MKCoordinateRegionContainsPoint(self_region, [annotation coordinate])) {
            [filteredAnnotations addObject:annotation];
        }
    }
    
    return filteredAnnotations;
}

@end
