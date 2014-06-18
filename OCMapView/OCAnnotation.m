//
//  OCAnnotation.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCAnnotation.h"

/// Compares two objects using -isEqual:. For the border case where both objects
/// are nil, it returns YES too (whereas [nil isEqual:nil] == NO and this leads
/// to incorrect comparison behaviour...)
static BOOL eql(id a, id b)
{
    if(a == b) {
        return YES;
    } else {
        return [a isEqual:b];
    }
}

@interface OCAnnotation ()
@property (nonatomic, strong) NSMutableArray *annotationsInCluster;
@end



@implementation OCAnnotation

- (id)init
{
    self = [super init];
    if (self) {
        _annotationsInCluster = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;
{
    self = [self init];
    if (self) {
        _coordinate = [annotation coordinate];
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
    // Add annotation to the cluster
    [_annotationsInCluster addObject:annotation];
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

#pragma mark center coordinate

- (CLLocationCoordinate2D)coordinate;
{
    if (self.annotationsInCluster.count == 0) return CLLocationCoordinate2DMake(0, 0);
    
    // find max/min coords
    CLLocationCoordinate2D min = [self.annotationsInCluster[0] coordinate];
    CLLocationCoordinate2D max = [self.annotationsInCluster[0] coordinate];
    for (id<MKAnnotation> annotation in self.annotationsInCluster) {
        min.latitude = MIN(min.latitude, annotation.coordinate.latitude);
        min.longitude = MIN(min.longitude, annotation.coordinate.longitude);
        max.latitude = MAX(max.latitude, annotation.coordinate.latitude);
        max.longitude = MAX(max.longitude, annotation.coordinate.longitude);
    }
    
    // calc center
    CLLocationCoordinate2D center = min;
    center.latitude += (max.latitude-min.latitude)/2.0;
    center.longitude += (max.longitude-min.longitude)/2.0;
    
    return center;
}

#pragma mark equality

- (BOOL)isEqual:(OCAnnotation*)annotation;
{
    if (![annotation isKindOfClass:[OCAnnotation class]]) {
        return NO;
    }
    
    if(self.coordinate.latitude == annotation.coordinate.latitude &&
       self.coordinate.longitude == annotation.coordinate.longitude &&
       eql(self.title, annotation.title) &&
       eql(self.subtitle, annotation.subtitle) &&
       eql(self.groupTag, annotation.groupTag))
    {
        // I compare in two steps so the set computations don't have to be done so often.
        NSSet *a_annotationsInCluster = [[NSSet alloc] initWithArray:self.annotationsInCluster];
        NSSet *b_annotationsInCluster = [[NSSet alloc] initWithArray:annotation.annotationsInCluster];
        if([a_annotationsInCluster isEqual:b_annotationsInCluster]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSUInteger)hash
{
    return self.title.hash*97 + self.subtitle.hash*13 + (NSUInteger)(self.coordinate.latitude*999);
}

@end

