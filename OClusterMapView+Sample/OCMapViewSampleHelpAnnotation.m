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

@end
