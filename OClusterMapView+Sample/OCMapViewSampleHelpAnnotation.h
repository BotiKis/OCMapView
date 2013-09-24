//
//  OCMapViewSampleHelpAnnotation.h
//  openClusterMapView
//
//  Created by Botond Kis on 17.07.11.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "OCGrouping.h"

@interface OCMapViewSampleHelpAnnotation : NSObject <MKAnnotation, OCGrouping>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *groupTag;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
