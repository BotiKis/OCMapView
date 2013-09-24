//
//  OCMapViewSampleHelpAnnotation.m
//  openClusterMapView
//
//  Created by Botond Kis on 17.07.11.
//

#import "OCMapViewSampleHelpAnnotation.h"

@implementation OCMapViewSampleHelpAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    self = [super init];
    if (self) {
        _coordinate = aCoordinate;
    }
    return self;
}

#pragma mark equality

- (BOOL)isEqual:(OCMapViewSampleHelpAnnotation*)annotation;
{
    if (![annotation isKindOfClass:[OCMapViewSampleHelpAnnotation class]]) {
        return NO;
    }
    
    return (self.coordinate.latitude == annotation.coordinate.latitude &&
            self.coordinate.longitude == annotation.coordinate.longitude &&
            [self.title isEqualToString:annotation.title] &&
            [self.subtitle isEqualToString:annotation.subtitle] &&
            [self.groupTag isEqualToString:annotation.groupTag]);
}

@end
