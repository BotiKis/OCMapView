//
//  OEDistance.h
//  openClusterMapView
//
//  Created by Botond Kis on 14.02.11.
//

#import "OCDistance.h"

#define kDegreesToRadians (M_PI / 180.0)

/// calculates the distance between two given coordinates in meters
double CLLocationCoordinateDistance(CLLocationCoordinate2D a, CLLocationCoordinate2D b)
{
    double earthRadius = 6371.01; // Earth's radius in Kilometers
    
	// Get the difference between our two points then convert the difference into radians
	double nDLat = (a.latitude - b.latitude) * kDegreesToRadians;
	double nDLon = (a.longitude - b.longitude) * kDegreesToRadians;
    
	double fromLat =  b.latitude * kDegreesToRadians;
	double toLat =  a.latitude * kDegreesToRadians;
    
	double nA =	pow ( sin(nDLat/2), 2 ) + cos(fromLat) * cos(toLat) * pow ( sin(nDLon/2), 2 );
    
	double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
	double nD = earthRadius * nC;
    
	return nD * 1000; // Return our calculated distance in meters
}

/// Calculates x = (pt + k*modul) such that x is in [0, modul) and k is a natural number
static double modulo(double pt, double modul)
{
    while(pt < 0) {
        pt += modul;
    }
    while(pt >= modul) {
        pt -= modul;
    }
    return pt;
}

/// Returns YES if and only if value is contained in the intervall [pt-range/2, pt+range/2]
/// all calculations are done in R/(modul*N)
/// or equivalently: x and (x+modul) are treated as equivalent values forall x in R
/// (R=real numbers, N=natural numbers)
static BOOL rangeContainsValueModulo(double pt, double range, double value, double modul)
{
    double halfRange = range * 0.5;
    pt = modulo(pt, modul);
    double start = modulo(pt-halfRange, modul);
    double end = modulo(pt+halfRange, modul);
    if(start <= end) {
        return start <= value && value <= end;
    } else {
        return end <= value || value <= start;
    }
    return NO;
}

BOOL MKCoordinateRegionContainsPoint(MKCoordinateRegion region, CLLocationCoordinate2D pt)
{
    return rangeContainsValueModulo(region.center.longitude, region.span.longitudeDelta, pt.longitude, 360.0) &&
    rangeContainsValueModulo(region.center.latitude, region.span.latitudeDelta, pt.latitude, 180.0);
}

BOOL MKCoordinateRegionContainsRegion(MKCoordinateRegion a, MKCoordinateRegion b)
{
    double bHalfLatDelta = b.span.latitudeDelta*0.5;
    double bHalfLonDelta = b.span.longitudeDelta*0.5;
    CLLocationCoordinate2D b_northWest = CLLocationCoordinate2DMake(b.center.latitude-bHalfLatDelta, b.center.longitude-bHalfLonDelta);
    CLLocationCoordinate2D b_southEast = CLLocationCoordinate2DMake(b.center.latitude+bHalfLatDelta, b.center.longitude+bHalfLonDelta);
    if(!MKCoordinateRegionContainsPoint(a, b_northWest))
        return NO;
    if(!MKCoordinateRegionContainsPoint(a, b_southEast))
        return NO;
    
    return YES;
}
