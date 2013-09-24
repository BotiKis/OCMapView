//
//  OEDistance.h
//  openClusterMapView
//
//  Created by Botond Kis on 14.02.11.
//

#import "OCDistance.h"

//
// calculates the distance between two given coordinates
double CLLocationCoordinateDistance(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2)
{
    return sqrt(pow(c1.latitude  - c2.latitude , 2.0) +
                pow(c1.longitude - c2.longitude, 2.0));
}
