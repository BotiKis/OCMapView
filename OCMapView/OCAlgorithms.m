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
#import <math.h>

@implementation OCAlgorithms

#pragma mark - bubbleClustering

// Bubble clustering with iteration
+ (NSArray*) bubbleClusteringWithAnnotations:(NSArray *) annotationsToCluster andClusterRadius:(CLLocationDistance)radius grouped:(BOOL) grouped{
    
    // memory
    [annotationsToCluster retain];
    
    // return array
    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    
	// Clustering
	for (id <MKAnnotation> annotation in annotationsToCluster) {
		// flag for cluster
		BOOL isContaining = NO;
		
		// If it's the first one, add it as new cluster annotation
		if([clusteredAnnotations count] == 0){
            OCAnnotation *newCluster = [[OCAnnotation alloc] initWithAnnotation:annotation];
            [clusteredAnnotations addObject:newCluster];
            
            // check group
            if (grouped && [annotation respondsToSelector:@selector(groupTag)]) {
                newCluster.groupTag = ((id <OCGrouping>)annotation).groupTag;
            }
            
            [newCluster release];
		}
		else {
            for (OCAnnotation *clusterAnnotation in clusteredAnnotations) {
                // If the annotation is in range of the Cluster add it to it
                if(isLocationNearToOtherLocation([annotation coordinate], [clusterAnnotation coordinate], radius)){
                    
                    // check group
                    if (grouped && [annotation respondsToSelector:@selector(groupTag)]) {
                        if (![clusterAnnotation.groupTag isEqualToString:((id <OCGrouping>)annotation).groupTag])
                            continue;
                    }
                    
					isContaining = YES;
					[clusterAnnotation addAnnotation:annotation];
					break;
				}
            }
            
            // If the annotation is not in a Cluster make it to a new one
			if (!isContaining){
				OCAnnotation *newCluster = [[OCAnnotation alloc] initWithAnnotation:annotation];
				[clusteredAnnotations addObject:newCluster];
                
                // check group
                if (grouped && [annotation respondsToSelector:@selector(groupTag)]) {
                    newCluster.groupTag = ((id <OCGrouping>)annotation).groupTag;
                }
                
                [newCluster release];
			}
		}
	}
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    // whipe all empty or single annotations
    for (OCAnnotation *anAnnotation in clusteredAnnotations) {
        if ([anAnnotation.annotationsInCluster count] <= 1) {
            [returnArray addObject:[anAnnotation.annotationsInCluster lastObject]];
        }
        else{
            [returnArray addObject:anAnnotation];
        }
    }
    
    // memory
    [annotationsToCluster release];
    [clusteredAnnotations release];
    
    return [returnArray autorelease];
}


// Grid clustering with predefined size
+ (NSArray*) gridClusteringWithAnnotations:(NSArray *) annotationsToCluster andClusterRect:(MKCoordinateSpan)tileRect grouped:(BOOL) grouped{
    
    // memory
    [annotationsToCluster retain];
    
    // return array
    NSMutableDictionary *clusteredAnnotations = [[NSMutableDictionary alloc] init];
    
    // iterate through all annotations
	for (id <MKAnnotation> annotation in annotationsToCluster) {
        
        // calculate grid coordinates of the annotation
        int row = ([annotation coordinate].longitude+180.0)/tileRect.longitudeDelta;
        int column = ([annotation coordinate].latitude+90.0)/tileRect.latitudeDelta;
        
        NSString *key = [NSString stringWithFormat:@"%d%d",row,column];
        
        
        // get the cluster for the calculated coordinates
        OCAnnotation *clusterAnnotation = [[clusteredAnnotations objectForKey:key] retain];
        
        // if there is none, create one
        if (clusterAnnotation == nil) {
            clusterAnnotation = [[OCAnnotation alloc] init];
            
            CLLocationDegrees lon = row * tileRect.longitudeDelta + tileRect.longitudeDelta/2.0 - 180.0;
            CLLocationDegrees lat = (column * tileRect.latitudeDelta) + tileRect.latitudeDelta/2.0 - 90.0;
            clusterAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
            
            // check group
            if (grouped && [annotation respondsToSelector:@selector(groupTag)]) {
                clusterAnnotation.groupTag = ((id <OCGrouping>)annotation).groupTag;
            }
            
            [clusteredAnnotations setValue:clusterAnnotation forKey:key];
        }
        
        // check group
        if (grouped && [annotation respondsToSelector:@selector(groupTag)]) {
            if (![clusterAnnotation.groupTag isEqualToString:((id <OCGrouping>)annotation).groupTag]){
                [clusterAnnotation release];
                continue;
            }
        }
        
        // add annotation to the cluster
        [clusterAnnotation addAnnotation:annotation];
        [clusterAnnotation release];
	}
    
    // return array
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    // whipe all empty or single annotations
    for (OCAnnotation *anAnnotation in [clusteredAnnotations allValues]) {
        if ([anAnnotation.annotationsInCluster count] <= 1) {
            [returnArray addObject:[anAnnotation.annotationsInCluster lastObject]];
        }
        else{
            [returnArray addObject:anAnnotation];
        }
    }
    
    // memory
    [annotationsToCluster release];
    [clusteredAnnotations release];
    
    return [returnArray autorelease];
}

@end
