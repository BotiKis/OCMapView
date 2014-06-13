//
//  OCMapView.h
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import <MapKit/MapKit.h>

#import "OCDistance.h"
#import "OCAnnotation.h"
#import "OCAlgorithms.h"

/// MapView replacement for MKMapView
/** OCMapView works like the standard MKMapView but 
 creates clusters from all added annotations.*/
@interface OCMapView : MKMapView

//
/// List of annotations which will be ignored by the clustering algorithm.
/** The objects in this array must adopt the @see MKAnnotation protocol.
 The clustering algorithms will automatically ignore this annotations.*/
@property(nonatomic, strong) NSMutableSet *annotationsToIgnore;

/// The complete list of annotations displayed on the map including clusters (read-only).
/// The objects in this array adopt the @see MKAnnotation protocol.
/// It contains all annotations as they are on the MapView.
@property(nonatomic, readonly) NSArray *displayedAnnotations;

/// Enables or disables clustering.
@property(nonatomic, assign) BOOL clusteringEnabled;

//
/// Defines the clustering algorithm which should be used.
/** @see OCClusteringMethod for more information
 
 default: OCClusteringMethodBubble*/
@property(nonatomic, assign) OCClusteringMethod clusteringMethod;


//
/// Defines the cluster size in units of the map width.
/** eg. clusterSize 0.5 is the half of the map.
default: 0.2*/
@property(nonatomic, assign) float clusterSize;

//
/// Enables multiple clusters
/** If enabled, tha mapview will generate different clusters for Tags 
 implemented by the OCGrouping protocol.
 default: NO*/
@property(nonatomic, assign) BOOL clusterByGroupTag;

//
/// Defines the "zoom" from where the map should start clustering.
/** If the map is zoomed below this value it won't cluster.
 default: 0.0 (no min. zoom)*/
@property(nonatomic, assign) CLLocationDegrees minLongitudeDeltaToCluster;

//
/// Defines how many annotations are needed to build a cluster
/** If a cluster contains less annotations, they will shown as they are
 default: 0 (no minimum count)*/
@property(nonatomic, assign) NSUInteger minimumAnnotationCountPerCluster;

//
/// Clusters all annotations, even if they are outside of the visible MKCoordinateRegion
/* default: NO (checks for boundaries)*/
@property (nonatomic, assign) BOOL clusterInvisibleViews;

/// Handles the ignoreList of annotations, calls the defined clustering
/// algorithm and adds the clustered annotations to the map.
- (void)doClustering;

@end


