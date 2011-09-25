//
//  OCAnnotation.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCAnnotation.h"

@implementation OCAnnotation
@synthesize coordinate;


// Memory
- (id)init
{
    self = [super init];
    if (self) {
        title = subtitle = @"";
        coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
        annotationsInCluster = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithAnnotation:(id <MKAnnotation>) annotation{
    [annotation retain];
    
    self = [self init];
    coordinate = [annotation coordinate];
    [annotationsInCluster addObject:annotation];
    
    [annotation release];
    
    return self;
}

- (void)dealloc {
    [annotationsInCluster release];
    [super dealloc];
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
    self.title = [NSString stringWithFormat:@"%d", [annotationsInCluster count]];
}

- (void)addAnnotations:(NSArray *)annotations{
    [annotations retain];
    for (id<MKAnnotation> annotation in annotations) {
        [self addAnnotation: annotation];
    }
    [annotations release];
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation{
    // Remove annotation from cluster
    [annotationsInCluster removeObject:annotation];
    self.title = [NSString stringWithFormat:@"%d", [annotationsInCluster count]];
}

- (void)removeAnnotations:(NSArray *)annotations{
    [annotations retain];
    for (id<MKAnnotation> annotation in annotations) {
        [self removeAnnotation: annotation];
    }
    [annotations release];
}

//
// protocoll implementation
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
    [title release];
    subtitle = text;
}

- (CLLocationCoordinate2D)coordinate{
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coord{
    coordinate = coord;
}

@end
