//
//  OCMapView.h
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OCDistance.h"
#import "OCAnnotation.h"
#import "OCAlgorithms.h"

#import <dispatch/dispatch.h>

/// MapView which should be used instead of MKMapView
/** OCMapView works like the standard MKMapView but creates clusters form its containing Annotations.*/
@interface OCMapView : MKMapView{
    // Data
    NSMutableSet *allAnnotations;
    NSMutableSet *annotationsToIgnore;
    
    // Clustering
    // read properties for explanation
    BOOL clusteringEnabled;
    OCClusteringMethod clusteringMethod;
    CLLocationDistance clusterSize;    
    BOOL clusterByGroupTag;
    CLLocationDegrees minLongitudeDeltaToCluster;
    
    // Backround Clustering
    dispatch_queue_t backgroundClusterQueue;
}

// ======================================
// Overwrite the methods of the mapview

/// Adds the specified annotation to the map view.
/** The annotation object to add to the receiver. This object must conform to the MKAnnotation protocol.*/
- (void)addAnnotation:(id < MKAnnotation >)annotation;

/// Adds an array of annotations to the map view.
/** An array of annotation objects. Each object in the array must conform to the MKAnnotation protocol.*/
- (void)addAnnotations:(NSArray *)annotations;

/// Removes the specified annotation object from the map view.
/** The annotation object to remove. This object must conform to the MKAnnotation protocol.*/
- (void)removeAnnotation:(id < MKAnnotation >)annotation;

/// Removes the specified annotation objects from the map view.
/** The array of annotations to remove. Objects in the array must conform to the MKAnnotation protocol.*/
- (void)removeAnnotations:(NSArray *)annotations;


// ======================================
// Properties

//
/// The complete list of annotations associated with the receiver. (read-only)
/** The objects in this array must adopt the @see MKAnnotation protocol. If no annotations are associated with the map view, the value of this property is nil.*/
@property(nonatomic, readonly) NSArray *annotations;
- (NSArray *)annotations;

//
/// List of annotations which will be ignored by the clustering algorithm.
/** The objects in this array must adopt the @see MKAnnotation protocol.
 The clustering algorithms will automatically ignore this annotations.*/
@property(nonatomic, retain) NSMutableSet *annotationsToIgnore;

//
/// The complete list of annotations displayed on the map including clusters (read-only).
/** The objects in this array must adopt the @see MKAnnotation protocol. It contains all annotations as they are on the MapView.*/
@property(nonatomic, readonly) NSArray *displayedAnnotations;
- (NSArray *)displayedAnnotations;

//
/// enables or disables clustering.
/** Setting this property will automatical call doClustering
 @see doClustering.
 
 default: YES*/
@property(nonatomic, assign) BOOL clusteringEnabled;
- (void)setClusteringEnabled:(BOOL)enabled;

//
/// Defines the clustering algorithm which should be used.
/** @see OCClusteringMethod for more information
 
 default: OCClusteringMethodBubble*/
@property(nonatomic, assign) OCClusteringMethod clusteringMethod;


//
/// Defines the cluster size in units of the map width.
/** eg. clusterSize 0.5 is the half of the map.
default: 0.2*/
@property(nonatomic, assign) CLLocationDistance clusterSize;

//
/// Enables multiple Clusters
/** If enabled, tha mapview will generate different clusters for Tags implemented by the OCGrouping protocol.
 default: NO*/
@property(nonatomic, assign) BOOL clusterByGroupTag;

//
/// Defines the "zoom" from where the map should start clustering.
/** If the map is zoomed below this value it won't cluster.
 default: 0.0 (no min. zoom)*/
@property(nonatomic, assign) CLLocationDegrees minLongitudeDeltaToCluster;

//
/// Clusters all annotations, even if they are outside of the visible MKCoordinateRegion
/* default: NO (checks for boundaries)*/
@property BOOL clusterInvisibleViews;

// ======================================
// Clustering

/// Start the clustering of annotations.
/**
 Handles the ignoreList of annotations, calls the defined clustering algorithm and adds the clustered annotations to the map.
 */
- (void)doClustering;

// ======================================
// Help Methods

/// Filters annotations for visibleMapRect.
/** This method filters the annotations for the visibleMapRect.*/
- (NSArray *)filterAnnotationsForVisibleMap:(NSArray *)annotationsToFilter;

@end
