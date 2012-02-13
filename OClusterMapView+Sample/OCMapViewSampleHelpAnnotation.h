//
//  OCMapViewSampleHelpAnnotation.h
//  openClusterMapView
//
//  Created by Botond Kis on 17.07.11.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "OCGrouping.h"

@interface OCMapViewSampleHelpAnnotation : NSObject <MKAnnotation, OCGrouping>{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    NSString *_groupTag;
}
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

//
// protocoll implementation
- (NSString *)title;
- (void)setTitle:(NSString *)text;

- (NSString *)subtitle;
- (void)setSubtitle:(NSString *)text;

- (NSString *)groupTag;
- (void)setGroupTag:(NSString *)tag;

- (CLLocationCoordinate2D)coordinate;

@end
