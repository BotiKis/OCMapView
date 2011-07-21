//
//  OCMapViewSampleHelpAnnotation.h
//  openClusterMapView
//
//  Created by Botond Kis on 17.07.11.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface OCMapViewSampleHelpAnnotation : NSObject <MKAnnotation>{
    CLLocationCoordinate2D coordinate;
}
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

//
// protocoll implementation
- (NSString *)title;

- (NSString *)subtitle;

- (CLLocationCoordinate2D)coordinate;

@end
