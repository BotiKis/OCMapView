//
//  OCAnnotation.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCAnnotation.h"

@interface OCAnnotation ()
CLLocationCoordinate2D safeCoordinate (CLLocationCoordinate2D);
@end

@implementation OCAnnotation
@synthesize coordinate;


// Memory
- (id)init
{
    self = [super init];
    if (self) {
        _groupTag = title = subtitle = [NSString stringWithFormat:@""];
        coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
        annotationsInCluster = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithAnnotation:(id <MKAnnotation>) annotation{
    
    self = [super init];
    if (self) {
        coordinate = [annotation coordinate];
        annotationsInCluster = [[NSMutableArray alloc] init];
        [annotationsInCluster addObject:annotation];
        
        title = annotation.title;
        subtitle = annotation.title;
        _groupTag = [NSString stringWithFormat:@""];
    }
    
    return self;
}


//
// List of annotations in the cluster
// read only
- (NSArray *)annotationsInCluster{
    return annotationsInCluster;
}


//
// manipulate cluster
- (void)addAnnotation:(id < MKAnnotation >)annotation{
    
    // Add annotation to the cluster
    [annotationsInCluster addObject:annotation];
    
    // get the number of stored annotations
    float multiplier = 1.0f/(float)[annotationsInCluster count];
    
    // calc delta vector
    CLLocationCoordinate2D deltaCoord;
    deltaCoord.latitude = (coordinate.latitude - annotation.coordinate.latitude) * multiplier;
    deltaCoord.longitude = (coordinate.longitude - annotation.coordinate.longitude) * multiplier;
    
    // recenter
    coordinate.latitude = deltaCoord.latitude + annotation.coordinate.latitude;
    coordinate.longitude = deltaCoord.longitude + annotation.coordinate.longitude;
    
}

- (void)addAnnotations:(NSArray *)annotations{
    for (id<MKAnnotation> annotation in annotations) {
        [self addAnnotation: annotation];
    }
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation{
    
    // get the number of stored annotations
    float multiplier = 1.0f/(float)[annotationsInCluster count];
    
    // calc delta vector
    CLLocationCoordinate2D deltaCoord;
    deltaCoord.latitude = (coordinate.latitude - annotation.coordinate.latitude) * multiplier;
    deltaCoord.longitude = (coordinate.longitude - annotation.coordinate.longitude) * multiplier;
    
    // recenter
    coordinate.latitude = deltaCoord.latitude - annotation.coordinate.latitude;
    coordinate.longitude = deltaCoord.longitude - annotation.coordinate.longitude;
    
    // Remove annotation from cluster
    [annotationsInCluster removeObject:annotation];
    
}

- (void)removeAnnotations:(NSArray *)annotations{
    for (id<MKAnnotation> annotation in annotations) {
        [self removeAnnotation: annotation];
    }
}

//
// protocoll implementation
- (NSString *)title{
    return title;
}

- (void)setTitle:(NSString *)text{
    title = text;
}

- (NSString *)subtitle{
    return subtitle;
}

- (void)setSubtitle:(NSString *)text{
    subtitle = text;
}

- (NSString *)groupTag{
    return _groupTag;
}

- (void)setGroupTag:(NSString *)tag{
    _groupTag = tag;
}

- (CLLocationCoordinate2D)coordinate{
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coord{
    coordinate = coord;
}

//================
#pragma mark - private

CLLocationCoordinate2D safeCoordinate (CLLocationCoordinate2D coordinate){
    
    CLLocationCoordinate2D safeCoordinate = coordinate;
    
    safeCoordinate.latitude = MIN(90.0, safeCoordinate.latitude);
    safeCoordinate.latitude = MAX(-90.0, safeCoordinate.latitude);
    
    safeCoordinate.longitude = MIN(180.0, safeCoordinate.longitude);
    safeCoordinate.longitude = MAX(-180.0, safeCoordinate.longitude);
    
    return safeCoordinate;
}

@end
