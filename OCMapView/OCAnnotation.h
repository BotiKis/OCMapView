//
//  OCAnnotation.h
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OCGrouping.h"

/// Annotation class which represents a Cluster.
/** OCAnnotation stores all annotations which are in its area.
 Objects of this class will be returned by the delegate method of OCMapView "viewForAnnotation".
 Implements MKAnnotation protocol.
 */
@interface OCAnnotation : NSObject <MKAnnotation, OCGrouping>{
    NSMutableArray *annotationsInCluster;
    NSString *title;
    NSString *subtitle;
    NSString *_groupTag;
    CLLocationCoordinate2D coordinate;
}
//
// Constructors
/// Standard initializer
- (id)init;

/// Init with annotations.
/** Init object with containing annotations*/
- (id)initWithAnnotation:(id <MKAnnotation>) annotation;

//
/// List of annotations in the cluster.
/** Returns all annotations in the cluster.
 READONLY
 */
@property(nonatomic, readonly) NSArray *annotationsInCluster;
//
/// List of annotations in the cluster.
/** @See annotationsInCluster property*/
- (NSArray *)annotationsInCluster;

//
// manipulate cluster
/// Adds a single annotation to the cluster.
/** Adds a given annotation to the cluster and sets the title to the number of containing annotations.*/
- (void)addAnnotation:(id < MKAnnotation >)annotation;

/// Adds multiple annotations to the Cluster.
/** Adds multiple annotations to the cluster and sets the title to the number of containing annotations.
 Calls addAnnotation in a loop.*/
- (void)addAnnotations:(NSArray *)annotations;

///Removes a single annotation from the Cluster.
/** Removes a given annotation from the cluster and sets the title to the number of containing annotations.*/
- (void)removeAnnotation:(id < MKAnnotation >)annotation;

/// Removes multiple annotations from the Cluster.
/** Removes multiple annotations from the cluster and sets the title to the number of containing annotations.*/
- (void)removeAnnotations:(NSArray *)annotations;

//
// protocol implementation
/// Get the Title of the cluster.
- (NSString *)title;
/// Set the Title of the cluster.
- (void)setTitle:(NSString *)text;


/// Get the Subtitle of the cluster.
- (NSString *)subtitle;
/// Set the Subitle of the cluster.
- (void)setSubtitle:(NSString *)text;

/// Get the GroupTag of the cluster.
- (NSString *)groupTag;
/// Set the GroupTag of the cluster.
- (void)setGroupTag:(NSString *)tag;

/// Get the coordinate of the cluster.
- (CLLocationCoordinate2D)coordinate;
/// Set the coordinate of the cluster.
- (void)setCoordinate:(CLLocationCoordinate2D)coord;

@end
