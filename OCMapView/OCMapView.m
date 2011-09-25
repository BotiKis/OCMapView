//
//  OCMapView.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCMapView.h"

@implementation OCMapView
@synthesize clusteringEnabled;
@synthesize annotationsToIgnore;
@synthesize clusteringMethod;
@synthesize clusterSize;
@synthesize minLongitudeDeltaToCluster;

- (id)init
{
    self = [super init];
    if (self) {
        allAnnotations = [[NSMutableSet alloc] init];
        annotationsToIgnore = [[NSMutableSet alloc] init];
        clusteringMethod = OCClusteringMethodBubble;
        clusterSize = 0.2;
        minLongitudeDeltaToCluster = 0.0;
        clusteringEnabled = YES;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];    
    if (self) {
        allAnnotations = [[NSMutableSet alloc] init];
        annotationsToIgnore = [[NSMutableSet alloc] init];
        clusteringMethod = OCClusteringMethodBubble;
        clusterSize = 0.2;
        minLongitudeDeltaToCluster = 0.0;
        clusteringEnabled = YES;
    }
    return self;
}

- (void)dealloc{
    [allAnnotations release];
    [annotationsToIgnore release];
    
    [super dealloc];
}

// ======================================
#pragma mark MKMapView implementation

- (void)addAnnotation:(id < MKAnnotation >)annotation{
    [allAnnotations addObject:annotation];
    [self doClustering];
}

- (void)addAnnotations:(NSArray *)annotations{
    [allAnnotations addObjectsFromArray:annotations];
    [self doClustering];
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation{
    [allAnnotations removeObject:annotation];
    [self doClustering];
}

- (void)removeAnnotations:(NSArray *)annotations{
    [annotations retain];
    for (id<MKAnnotation> annotation in annotations) {
        [allAnnotations removeObject:annotation];
    }
    [annotations release];
    [self doClustering];
}


// ======================================
#pragma mark - Properties
//
// Returns, like the original method,
// all annotations in the map unclustered.
- (NSArray *)annotations{
    return [allAnnotations allObjects];
}

//
// Returns all annotations which are actually displayed on the map. (clusters)
- (NSArray *)displayedAnnotations{
    return super.annotations;    
}

//
// enable or disable clustering
- (void)setClusteringEnabled:(BOOL)enabled{
    clusteringEnabled = enabled;
    [self doClustering];
}

// ======================================
#pragma mark - Clustering

- (void)doClustering{
    
    // Remove the annotation which should be ignored
    NSMutableArray *bufferArray = [[NSMutableArray alloc] initWithArray:[allAnnotations allObjects]];
    [bufferArray removeObjectsInArray:[annotationsToIgnore allObjects]];
    NSMutableArray *annotationsToCluster = [[NSMutableArray alloc] initWithArray:[self filterAnnotationsForVisibleMap:bufferArray]];
    [bufferArray release];
    
    //calculate cluster radius
    CLLocationDistance clusterRadius = self.region.span.longitudeDelta * clusterSize;
    
    // Do clustering
    NSArray *clusteredAnnotations;
    
    // Check if clustering is enabled and map is above the minZoom
    if (clusteringEnabled && (self.region.span.longitudeDelta > minLongitudeDeltaToCluster)) {
        
        // switch to selected algoritm
        switch (clusteringMethod) {
            case OCClusteringMethodBubble:{
                clusteredAnnotations = [[NSArray alloc] initWithArray:[OCAlgorithms bubbleClusteringWithAnnotations:annotationsToCluster andClusterRadius:clusterRadius]];
                break;
            }
            case OCClusteringMethodGrid:{
                clusteredAnnotations =[[NSArray alloc] initWithArray:[OCAlgorithms gridClusteringWithAnnotations:annotationsToCluster andClusterRect:MKCoordinateSpanMake(clusterRadius, clusterRadius)]];
                break;
            }
            default:{
                clusteredAnnotations = [annotationsToCluster retain];
                break;
            }
        }
    }
    // pass through without when not
    else{
        clusteredAnnotations = [annotationsToCluster retain];
    }
    
    // Clear map but leave Userlcoation
    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] initWithArray:self.displayedAnnotations];
    [annotationsToRemove removeObject:self.userLocation];
    [super removeAnnotations:annotationsToRemove];
    [annotationsToRemove release];

    // add clustered and ignored annotations to map
    [super addAnnotations: clusteredAnnotations];
    [super addAnnotations: [annotationsToIgnore allObjects]];
    
    // memory
    [clusteredAnnotations release];
    [annotationsToCluster release];
}

// ======================================
#pragma mark - Helpers

- (NSArray *)filterAnnotationsForVisibleMap:(NSArray *)annotationsToFilter{
    // return array
    NSMutableArray *filteredAnnotations = [[NSMutableArray alloc] initWithCapacity:[annotationsToFilter count]];
    
    // border calculation
    CLLocationDistance maxLat = self.centerCoordinate.latitude + self.region.span.latitudeDelta/2.0;
    CLLocationDistance minLat = self.centerCoordinate.latitude - self.region.span.latitudeDelta/2.0;
    CLLocationDistance maxLon = self.centerCoordinate.longitude + self.region.span.longitudeDelta/2.0;
    CLLocationDistance minLon = self.centerCoordinate.longitude - self.region.span.longitudeDelta/2.0;
    
    for (id<MKAnnotation> annotation in annotationsToFilter) {
        // if annotation is not inside the coordinates, kick it
        if ([annotation coordinate].latitude < maxLat && [annotation coordinate].latitude > minLat && [annotation coordinate].longitude < maxLon && [annotation coordinate].longitude > minLon) {
            [filteredAnnotations addObject:annotation];
        }
    }
    
    return [filteredAnnotations autorelease];
}

@end
