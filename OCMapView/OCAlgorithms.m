//
//  OCAlgorythms.m
//  openClusterMapView
//
//  Created by Botond Kis on 15.07.11.
//

#import "OCAlgorithms.h"
#import "OCAnnotation.h"
#import "OCDistance.h"
#import "OCGrouping.h"

@implementation OCAlgorithms

// Bubble clustering with iteration
+ (NSArray*)bubbleClusteringWithAnnotations:(NSArray*)annotationsToCluster
                              clusterRadius:(CLLocationDistance)radius
                                    grouped:(BOOL)grouped;
{
    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    
	// Clustering
	for (id <MKAnnotation> annotation in annotationsToCluster)
    {
		// Find fitting existing cluster
		BOOL foundCluster = NO;
        for (OCAnnotation *clusterAnnotation in clusteredAnnotations) {
            // If the annotation is in range of the cluster, add it
            if ((CLLocationCoordinateDistance([annotation coordinate], [clusterAnnotation coordinate]) <= radius)) {
                // check group
                if (grouped && [annotation conformsToProtocol:@protocol(OCGrouping)]) {
                    if (![clusterAnnotation.groupTag isEqualToString:((id <OCGrouping>)annotation).groupTag])
                        continue;
                }
                
                foundCluster = YES;
                [clusterAnnotation addAnnotation:annotation];
                break;
            }
        }
        
        // If the annotation wasn't added to a cluster, create a new one
        if (!foundCluster){
            OCAnnotation *newCluster = [[OCAnnotation alloc] initWithAnnotation:annotation];
            [clusteredAnnotations addObject:newCluster];
            
            // check group
            if (grouped && [annotation conformsToProtocol:@protocol(OCGrouping)]) {
                newCluster.groupTag = [(id<OCGrouping>)annotation groupTag];
            }
        }
	}
    
    // whipe all empty or single annotations
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (OCAnnotation *anAnnotation in clusteredAnnotations) {
        if ([anAnnotation.annotationsInCluster count] == 1) {
            [returnArray addObject:[anAnnotation.annotationsInCluster lastObject]];
        } else if ([anAnnotation.annotationsInCluster count] > 1){
            [returnArray addObject:anAnnotation];
        }
    }
    
    return returnArray;
}


// Grid clustering with predefined size
+ (NSArray*)gridClusteringWithAnnotations:(NSArray*)annotationsToCluster
                              clusterRect:(MKCoordinateSpan)tileRect
                                  grouped:(BOOL)grouped;
{
    NSMutableDictionary *clusteredAnnotations = [[NSMutableDictionary alloc] init];
    
    // iterate through all annotations
	for (id<MKAnnotation> annotation in annotationsToCluster)
    {
        // calculate grid coordinates of the annotation
        NSInteger row = ([annotation coordinate].longitude+180.0)/tileRect.longitudeDelta;
        NSInteger column = ([annotation coordinate].latitude+90.0)/tileRect.latitudeDelta;
        NSString *key = [NSString stringWithFormat:@"%d%d",row,column];
        
        // add group tag to key
        if (grouped && [annotation conformsToProtocol:@protocol(OCGrouping)]) {
            key = [NSString stringWithFormat: @"%@%@", key, [(id<OCGrouping>)annotation groupTag]];
        }
        
        // get the cluster for the calculated coordinates
        OCAnnotation *clusterAnnotation = [clusteredAnnotations objectForKey:key];
        
        // if there is none, create one
        if (clusterAnnotation == nil) {
            clusterAnnotation = [[OCAnnotation alloc] init];
            
            CLLocationDegrees lon = row * tileRect.longitudeDelta + tileRect.longitudeDelta/2.0 - 180.0;
            CLLocationDegrees lat = (column * tileRect.latitudeDelta) + tileRect.latitudeDelta/2.0 - 90.0;
            clusterAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
            
            // check group
            if (grouped && [annotation conformsToProtocol:@protocol(OCGrouping)]) {
                clusterAnnotation.groupTag = [(id<OCGrouping>)annotation groupTag];
            }
            
            [clusteredAnnotations setValue:clusterAnnotation forKey:key];
        }
        
        // add annotation to the cluster
        [clusterAnnotation addAnnotation:annotation];
	}
    
    // return array
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    // add single annotations directly without OCAnnotation
    for (OCAnnotation *anAnnotation in [clusteredAnnotations allValues]) {
        if ([anAnnotation.annotationsInCluster count] == 1) {
            [returnArray addObject:[anAnnotation.annotationsInCluster lastObject]];
        } else if ([anAnnotation.annotationsInCluster count] > 1) {
            [returnArray addObject:anAnnotation];
        }
    }
    
    return returnArray;
}

@end
