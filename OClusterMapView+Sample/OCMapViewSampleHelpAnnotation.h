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
    NSString *title;
    NSString *subtitle;
}
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

//
// protocoll implementation
- (NSString *)title;
- (void)setTitle:(NSString *)text;

- (NSString *)subtitle;
- (void)setSubtitle:(NSString *)text;

- (CLLocationCoordinate2D)coordinate;

@end
