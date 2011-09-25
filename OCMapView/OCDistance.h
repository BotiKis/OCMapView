//
//  OEDistance.h
//  openClusterMapView
//
//  Created by Botond Kis on 14.02.11.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

/** @fn CLLocationDistance getDistance(CLLocationCoordinate2D firstLocation, CLLocationCoordinate2D secondLocation)
 @brief calculates the distance between two given coordinates.
 */
CLLocationDistance getDistance(CLLocationCoordinate2D firstLocation, CLLocationCoordinate2D secondLocation);

/** @fn BOOL isLocationNearToOtherLocation(CLLocationCoordinate2D firstLocation, CLLocationCoordinate2D secondLocation, CLLocationDistance distanceInGeoCoordinates)
 @brief determines either two locations are near or not.
 Returns true if the distance between two give locations is shorter or equal than the designated distance.
 The distance represents the cluster size.
 */
BOOL isLocationNearToOtherLocation(CLLocationCoordinate2D firstLocation, CLLocationCoordinate2D secondLocation, CLLocationDistance distanceInGeoCoordinates);
