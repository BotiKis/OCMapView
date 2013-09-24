//
//  OCMapView.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCMapView.h"

@interface OCMapView ()
@property (nonatomic, strong) NSMutableSet *allAnnotations;
- (void)sharedInit;

/// Filters annotations for visibleMapRect.
/** This method filters the annotations for the visibleMapRect.*/
- (NSArray *)filterAnnotationsForVisibleMap:(NSArray *)annotationsToFilter;
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
    _clusteringEnabled = YES;
    _clusterByGroupTag = NO;
    _clusterInvisibleViews = NO;
}

#pragma mark - MKMapView

- (void)addAnnotation:(id < MKAnnotation >)annotation{
    [_allAnnotations addObject:annotation];
    [self doClustering];
}

- (void)addAnnotations:(NSArray *)annotations{
    [_allAnnotations addObjectsFromArray:annotations];
    [self doClustering];
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation{
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
- (NSArray *)annotations{
    return [_allAnnotations allObjects];
}

//
// Returns all annotations which are actually displayed on the map. (clusters)
- (NSArray *)displayedAnnotations{
    return super.annotations;    
}

//
// enable or disable clustering
- (void)setClusteringEnabled:(BOOL)enabled{
    _clusteringEnabled = enabled;
    [self doClustering];
}

#pragma mark - Clustering

- (void)doClustering{
    
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
        switch (_clusteringMethod) {
            case OCClusteringMethodBubble:{
                clusteredAnnotations = [OCAlgorithms bubbleClusteringWithAnnotations:annotationsToCluster
                                                                    andClusterRadius:clusterRadius
                                                                             grouped:self.clusterByGroupTag];
                break;
            }
            case OCClusteringMethodGrid:{
                clusteredAnnotations =[OCAlgorithms gridClusteringWithAnnotations:annotationsToCluster
                                                                   andClusterRect:MKCoordinateSpanMake(clusterRadius, clusterRadius)
                                                                          grouped:self.clusterByGroupTag];
                break;
            }
        }
    }
    // pass through without when not
    else{
        clusteredAnnotations = annotationsToCluster;
    }
    
    NSMutableArray *annotationsToDisplay = [clusteredAnnotations mutableCopy];
    [annotationsToDisplay addObjectsFromArray:[_annotationsToIgnore allObjects]];
    
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
