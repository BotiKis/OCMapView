//
//  OCAnnotation.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCAnnotation.h"

static CLLocationDegrees const OCMinimumInvalidDegree = 400.0;

@interface OCAnnotation ()

@property (nonatomic, strong) NSMutableArray *annotationsInCluster;
@property (nonatomic, assign) CLLocationCoordinate2D minCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D maxCoordinate;

@end

@implementation OCAnnotation

- (id)init
{
    self = [super init];
    if (self) {
        _annotationsInCluster = [[NSMutableArray alloc] init];
        _minCoordinate.latitude = OCMinimumInvalidDegree;
        _maxCoordinate.latitude = OCMinimumInvalidDegree;
    }
    return self;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;
{
    self = [self init];
    if (self) {
        CLLocationCoordinate2D annotationCoordinate = [annotation coordinate];
        _minCoordinate = annotationCoordinate;
        _maxCoordinate = annotationCoordinate;
        _coordinate = annotationCoordinate;
        [_annotationsInCluster addObject:annotation];
        
        if ([annotation respondsToSelector:@selector(title)]) {
            self.title = [annotation title];
        }
        if ([annotation respondsToSelector:@selector(subtitle)]) {
            self.subtitle = [annotation subtitle];
        }
    }
    
    return self;
}

//
// List of annotations in the cluster
// read only
- (NSArray*)annotationsInCluster;
{
    return [_annotationsInCluster copy];
}

#pragma mark add / remove annotations

- (void)addAnnotation:(id<MKAnnotation>)annotation;
{
    CLLocationCoordinate2D annotationCoordinate = annotation.coordinate;
    // check if min and max have been set
    if (self.minCoordinate.latitude >= OCMinimumInvalidDegree) {
        _minCoordinate = annotationCoordinate;
    }
    if (self.maxCoordinate.latitude >= OCMinimumInvalidDegree) {
        _maxCoordinate = annotationCoordinate;
    }

    // Add annotation to the cluster
    [_annotationsInCluster addObject:annotation];

    // recompute center coordinate
    _minCoordinate.latitude = MIN(_minCoordinate.latitude, annotationCoordinate.latitude);
    _minCoordinate.longitude = MIN(_minCoordinate.longitude,annotationCoordinate.longitude);
    _maxCoordinate.latitude = MAX(_maxCoordinate.latitude, annotationCoordinate.latitude);
    _maxCoordinate.longitude = MAX(_maxCoordinate.longitude, annotationCoordinate.longitude);

    _coordinate.latitude = _minCoordinate.latitude + (_maxCoordinate.latitude-_minCoordinate.latitude)/2.0;
    _coordinate.longitude = _minCoordinate.longitude + (_maxCoordinate.longitude-_minCoordinate.longitude)/2.0;
}

- (void)addAnnotations:(NSArray *)annotations;
{
    for (id<MKAnnotation> annotation in annotations) {
        [self addAnnotation: annotation];
    }
}

- (void)removeAnnotation:(id<MKAnnotation>)annotation;
{
    // Remove annotation from cluster
    [_annotationsInCluster removeObject:annotation];
}

- (void)removeAnnotations:(NSArray*)annotations;
{
    for (id<MKAnnotation> annotation in annotations) {
        [self removeAnnotation: annotation];
    }
}

#pragma mark equality

- (BOOL)isEqual:(OCAnnotation*)annotation;
{
    if (![annotation isKindOfClass:[OCAnnotation class]]) {
        return NO;
    }
    
    return (self.coordinate.latitude == annotation.coordinate.latitude &&
            self.coordinate.longitude == annotation.coordinate.longitude &&
            [self.title isEqualToString:annotation.title] &&
            [self.subtitle isEqualToString:annotation.subtitle] &&
            [self.groupTag isEqualToString:annotation.groupTag] &&
            [self.annotationsInCluster isEqual:annotation.annotationsInCluster]);
}

@end

