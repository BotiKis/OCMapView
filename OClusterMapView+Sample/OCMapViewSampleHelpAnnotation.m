//
//  OCMapViewSampleHelpAnnotation.m
//  openClusterMapView
//
//  Created by Botond Kis on 17.07.11.
//

#import "OCMapViewSampleHelpAnnotation.h"

@implementation OCMapViewSampleHelpAnnotation

// memory
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    self = [super init];
    if (self) {
        coordinate = aCoordinate;
        title = subtitle = nil;
    }
    
    return self;
}

- (void)dealloc {
    [title release];
    [subtitle release];
    
    [super dealloc];
}

// Properties
- (NSString *)title{
    return title;
}

- (void)setTitle:(NSString *)text{
    [text retain];
    [title release];
    title = text;
}

- (NSString *)subtitle{
    return subtitle;
}

- (void)setSubtitle:(NSString *)text{
    [text retain];
    [subtitle release];
    subtitle = text;
}

- (CLLocationCoordinate2D)coordinate{
    return coordinate;
}

@end
