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
        _groupTag = title = subtitle = [[NSString stringWithFormat:@""] retain];
        coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
        annotationsInCluster = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithAnnotation:(id <MKAnnotation>) annotation{
    [annotation retain];
    
    self = [super init];
    if (self) {
        coordinate = [annotation coordinate];
        annotationsInCluster = [[NSMutableArray alloc] init];
        [annotationsInCluster addObject:annotation];
        
        title = [annotation.title retain];
        subtitle = [annotation.title retain];
        _groupTag = [[NSString stringWithFormat:@""] retain];
    }
    [annotation release];
    
    return self;
}

- (void)dealloc {
    [annotationsInCluster release];
    
    [title release];
    [subtitle release];
    [_groupTag release];
    
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
    [annotation retain];
    
    //calculate new cluster coordinate
    float annotationCount = (float)[annotationsInCluster count];
    coordinate.latitude = (coordinate.latitude * annotationCount + annotation.coordinate.latitude) / (annotationCount + 1);
    coordinate.longitude = (coordinate.longitude * annotationCount + annotation.coordinate.longitude) / (annotationCount + 1);
    
    // Add annotation to the cluster
    [annotationsInCluster addObject:annotation];
    [annotation release];
}

- (void)addAnnotations:(NSArray *)annotations{
    [annotations retain];
    for (id<MKAnnotation> annotation in annotations) {
        [self addAnnotation: annotation];
    }
    [annotations release];
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation{
    [annotation retain];
    
    //calculate new cluster coordinate
    float annotationCount = (float)[annotationsInCluster count];
    coordinate.latitude = (coordinate.latitude * annotationCount - annotation.coordinate.latitude) / (annotationCount - 1);
    coordinate.longitude = (coordinate.longitude * annotationCount - annotation.coordinate.longitude) / (annotationCount - 1);
    
    // Remove annotation from cluster
    [annotationsInCluster removeObject:annotation];
    
    [annotation release];
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
    [subtitle release];
    subtitle = text;
}

- (NSString *)groupTag{
    return _groupTag;
}

- (void)setGroupTag:(NSString *)tag{
    [tag retain];
    [_groupTag release];
    _groupTag = tag;
}

- (CLLocationCoordinate2D)coordinate{
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coord{
    coordinate = coord;
}

@end
