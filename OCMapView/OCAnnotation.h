//
//  OCAnnotation.h
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import <MapKit/MapKit.h>
#import "OCGrouping.h"

/// Annotation class which represents a Cluster.
/** OCAnnotation stores all annotations which are in its area.
 Objects of this class will be handed over to the MKMapView delegate method "viewForAnnotation".
 Implements OCGrouping protocol. @see OCGrouping
 */
@interface OCAnnotation : NSObject <OCGrouping>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *groupTag;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/// Init with annotations
/** Init cluster with containing annotations*/
- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

/// List of annotations in the cluster.
/** Returns all annotations in the cluster. */
- (NSArray*)annotationsInCluster;

// Adds an annotation to the cluster
/// Adds a single annotation to the cluster.
/** Adds a given annotation to the cluster and sets the title to the number of containing annotations. */
- (void)addAnnotation:(id<MKAnnotation>)annotation;

/// Adds multiple annotations to the cluster.
/** Adds multiple annotations to the cluster and sets the title to the number of containing annotations.
 Calls addAnnotation in a loop. */
- (void)addAnnotations:(NSArray *)annotations;

/// Removes a single annotation from the cluster.
/** Removes a given annotation from the cluster and sets the title to the number of containing annotations. */
- (void)removeAnnotation:(id<MKAnnotation>)annotation;

/// Removes multiple annotations from the cluster.
/** Removes multiple annotations from the cluster and sets the title to the number of containing annotations. */
- (void)removeAnnotations:(NSArray*)annotations;

@end
