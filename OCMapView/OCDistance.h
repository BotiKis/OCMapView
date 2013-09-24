//
//  OEDistance.h
//  openClusterMapView
//
//  Created by Botond Kis on 14.02.11.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

/** @fn double CLLocationCoordinateDistance(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2)
 @brief calculates the distance between two given coordinates (beware: not in meters)
 */
double CLLocationCoordinateDistance(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2);
