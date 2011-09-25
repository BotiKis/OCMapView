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
        coordinate = aCoordinate;
    }
    
    return self;
}

- (NSString *)title{
    return @"";
}

- (NSString *)subtitle{
    return @"";
}

- (CLLocationCoordinate2D)coordinate{
    return coordinate;
}

@end
