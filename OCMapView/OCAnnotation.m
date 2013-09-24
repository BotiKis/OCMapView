//
//  OCAnnotation.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCAnnotation.h"

@interface OCAnnotation ()
@property (nonatomic, strong) NSMutableArray *annotationsInCluster;
@end

@implementation OCAnnotation

- (id)init
{
    self = [super init];
    if (self) {
        self.groupTag = self.title = self.subtitle = @"";
        _coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
        _annotationsInCluster = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithAnnotation:(id <MKAnnotation>) annotation{
    
    self = [super init];
    if (self) {
        _coordinate = [annotation coordinate];
        _annotationsInCluster = [[NSMutableArray alloc] init];
        [_annotationsInCluster addObject:annotation];
        
        self.title = annotation.self.title;
        self.subtitle = annotation.self.title;
        self.groupTag = @"";
    }
    
    return self;
}

//
// List of annotations in the cluster
// read only
- (NSArray *)_annotationsInCluster{
    return [_annotationsInCluster copy];
}

#pragma mark add / remove annotations

- (void)addAnnotation:(id < MKAnnotation >)annotation{
    
    // Add annotation to the cluster
    [_annotationsInCluster addObject:annotation];
    
    // get the number of stored annotations
    float multiplier = 1.0f/(float)[_annotationsInCluster count];
    
    // calc delta vector
    CLLocationCoordinate2D deltaCoord;
    deltaCoord.latitude = (_coordinate.latitude - annotation.coordinate.latitude) * multiplier;
    deltaCoord.longitude = (_coordinate.longitude - annotation.coordinate.longitude) * multiplier;
    
    // recenter
    _coordinate.latitude = deltaCoord.latitude + annotation.coordinate.latitude;
    _coordinate.longitude = deltaCoord.longitude + annotation.coordinate.longitude;
    
}

- (void)addAnnotations:(NSArray *)annotations{
    for (id<MKAnnotation> annotation in annotations) {
        [self addAnnotation: annotation];
    }
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation{
    
    // get the number of stored annotations
    float multiplier = 1.0f/(float)[_annotationsInCluster count];
    
    // calc delta vector
    CLLocationCoordinate2D deltaCoord;
    deltaCoord.latitude = (_coordinate.latitude - annotation.coordinate.latitude) * multiplier;
    deltaCoord.longitude = (_coordinate.longitude - annotation.coordinate.longitude) * multiplier;
    
    // recenter
    _coordinate.latitude = deltaCoord.latitude - annotation.coordinate.latitude;
    _coordinate.longitude = deltaCoord.longitude - annotation.coordinate.longitude;
    
    // Remove annotation from cluster
    [_annotationsInCluster removeObject:annotation];
    
}

- (void)removeAnnotations:(NSArray *)annotations{
    for (id<MKAnnotation> annotation in annotations) {
        [self removeAnnotation: annotation];
    }
}

@end

