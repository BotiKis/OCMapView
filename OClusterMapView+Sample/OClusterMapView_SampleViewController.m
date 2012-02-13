//
//  OClusterMapView_SampleViewController.m
//  OClusterMapView+Sample
//
//  Created by Botond Kis on 25.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OClusterMapView_SampleViewController.h"
#import "OCMapViewSampleHelpAnnotation.h"
#import <math.h>

#define ARC4RANDOM_MAX 0x100000000

@implementation OClusterMapView_SampleViewController

@synthesize mapView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    mapView.delegate = self;
    mapView.clusterSize = 0.2;
    labelNumberOfAnnotations.text = @"Number of Annotations: 0";
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

// ==============================
#pragma mark - UI actions

- (IBAction)removeButtonTouchUpInside:(id)sender {
    [mapView removeAnnotations:mapView.annotations];
    [mapView removeOverlays:mapView.overlays];
    labelNumberOfAnnotations.text = @"Number of Annotations: 0";
}

- (IBAction)addButtonTouchUpInside:(id)sender {
    [mapView removeOverlays:mapView.overlays];
    NSArray *randomLocations = [[NSArray alloc] initWithArray:[self randomCoordinatesGenerator:100]];
    NSMutableSet *annotationsToAdd = [[NSMutableSet alloc] init];
    
    for (CLLocation *loc in randomLocations) {
        OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc] initWithCoordinate:loc.coordinate];
        [annotationsToAdd addObject:annotation];
        
        // add to group if specified
        if (annotationsToAdd.count < (randomLocations.count)/2) {
            annotation.groupTag = @"first half";
        }
        else{
            annotation.groupTag = @"second half";
        }
        
        [annotation release];
    }
    
    [mapView addAnnotations:[annotationsToAdd allObjects]];
    labelNumberOfAnnotations.text = [NSString stringWithFormat:@"Number of Annotations: %d", [mapView.annotations count]];
    
    // clean
    [randomLocations release];
    [annotationsToAdd release];
}

- (IBAction)clusteringButtonTouchUpInside:(UIButton *)sender {
    [mapView removeOverlays:mapView.overlays];
    if (mapView.clusteringEnabled) {
        [sender setTitle:@"turn clustering on" forState:UIControlStateNormal];
        [sender setTitle:@"turn clustering on" forState:UIControlStateSelected];
        [sender setTitle:@"turn clustering on" forState:UIControlStateHighlighted];
        mapView.clusteringEnabled = NO;
    }
    else{
        [sender setTitle:@"turn clustering off" forState:UIControlStateNormal];
        [sender setTitle:@"turn clustering off" forState:UIControlStateSelected];
        [sender setTitle:@"turn clustering off" forState:UIControlStateHighlighted];
        mapView.clusteringEnabled = YES;
    }
}

- (IBAction)addOneButtonTouchupInside:(id)sender {
    [mapView removeOverlays:mapView.overlays];
    NSArray *randomLocations = [[NSArray alloc] initWithArray:[self randomCoordinatesGenerator:1]];
    CLLocationCoordinate2D loc = ((CLLocation *)[randomLocations objectAtIndex:0]).coordinate;
    OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc] initWithCoordinate:loc];
    
    [mapView addAnnotation:annotation];
    labelNumberOfAnnotations.text = [NSString stringWithFormat:@"Number of Annotations: %d", [mapView.annotations count]];
    
    // clean
    [randomLocations release];
    [annotation release];
}

- (IBAction)changeClusterMethodButtonTouchUpInside:(UIButton *)sender {    
    [mapView removeOverlays:mapView.overlays];
    if (mapView.clusteringMethod == OCClusteringMethodBubble) {
        [sender setTitle:@"Bubble cluster" forState:UIControlStateNormal];
        [sender setTitle:@"Bubble cluster" forState:UIControlStateSelected];
        [sender setTitle:@"Bubble cluster" forState:UIControlStateHighlighted];
        mapView.clusteringMethod = OCClusteringMethodGrid;
    }
    else{
        [sender setTitle:@"Grid cluster" forState:UIControlStateNormal];
        [sender setTitle:@"Grid cluster" forState:UIControlStateSelected];
        [sender setTitle:@"Grid cluster" forState:UIControlStateHighlighted];
        mapView.clusteringMethod = OCClusteringMethodBubble;
    }
    [mapView doClustering];
}

- (IBAction)infoButtonTouchUpInside:(UIButton *)sender{
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Info" message:@"The size of a cluster-annotation represents the number of annotations it contains and not its size." delegate:nil cancelButtonTitle:@"great!" otherButtonTitles:nil];
    [a show];
    [a release];
}

- (IBAction)buttonGroupByTagTouchUpInside:(UIButton *)sender {
    mapView.clusterByGroupTag = ! mapView.clusterByGroupTag;
    if(mapView.clusterByGroupTag){
        [sender setTitle:@"group by tag on" forState:UIControlStateNormal];
    }
    else{
        [sender setTitle:@"group by tag off" forState:UIControlStateNormal];
    }
    
    [mapView removeOverlays:mapView.overlays];
    [mapView doClustering];
}

// ==============================
#pragma mark - map delegate
- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation{
    MKPinAnnotationView *annotationView;
    
    // if it's a cluster
    if ([annotation isKindOfClass:[OCAnnotation class]]) {
        
        OCAnnotation *clusterAnnotation = (OCAnnotation *)annotation;
        
        annotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"ClusterView"];
        [annotationView retain];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ClusterView"];
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorPurple;
        }
        //calculate cluster region
        //CLLocationDistance clusterRadius = mapView.region.span.longitudeDelta * mapView.clusterSize * 111000; //static circle size of cluster
        CLLocationDistance clusterRadius = mapView.region.span.longitudeDelta/log(mapView.region.span.longitudeDelta*mapView.region.span.longitudeDelta) * log(pow([clusterAnnotation.annotationsInCluster count], 4)) * mapView.clusterSize * 50000; //circle size based on number of annotations in cluster
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:clusterAnnotation.coordinate radius:clusterRadius * cos([annotation coordinate].latitude * M_PI / 180.0)];
        [circle setTitle:@"background"];
        [mapView addOverlay:circle];
        
        MKCircle *circleLine = [MKCircle circleWithCenterCoordinate:clusterAnnotation.coordinate radius:clusterRadius * cos([annotation coordinate].latitude * M_PI / 180.0)];
        [circleLine setTitle:@"line"];
        [mapView addOverlay:circleLine];
        
        // set title
        clusterAnnotation.title = @"Cluster";
        clusterAnnotation.subtitle = [NSString stringWithFormat:@"Containing annotations: %d", [clusterAnnotation.annotationsInCluster count]];
        
        // change pincolor for group
        annotationView.pinColor = MKPinAnnotationColorPurple;
        if (mapView.clusterByGroupTag) {
            if ([clusterAnnotation.groupTag isEqualToString:@"second half"]) {
                annotationView.pinColor = MKPinAnnotationColorRed;
            }
            clusterAnnotation.title = clusterAnnotation.groupTag;
        }
    }
    // If it's a single annotation
    else if([annotation isKindOfClass:[OCMapViewSampleHelpAnnotation class]]){
        OCMapViewSampleHelpAnnotation *singleAnnotation = (OCMapViewSampleHelpAnnotation *)annotation;
        annotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"singleAnnotationView"];
        [annotationView retain];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:singleAnnotation reuseIdentifier:@"singleAnnotationView"];
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorGreen;
        }
        singleAnnotation.title = @"Single annotation";
    }
    // Error
    else{
        annotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"errorAnnotationView"];
        [annotationView retain];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"errorAnnotationView"];
            annotationView.canShowCallout = NO;
            annotationView.pinColor = MKPinAnnotationColorRed;
        }
    }
    
    return [annotationView autorelease];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
    MKCircle *circle = overlay;
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];
    
    if ([circle.title isEqualToString:@"background"])
    {
        circleView.fillColor = [UIColor purpleColor];
        circleView.alpha = 0.25;
    }
    else if ([circle.title isEqualToString:@"helper"])
    {
        circleView.fillColor = [UIColor redColor];
        circleView.alpha = 0.25;
    }
    else
    {
        circleView.strokeColor = [UIColor blackColor];
        circleView.lineWidth = 1.0;
    }
    
    return [circleView autorelease];
}

- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated{
    [mapView removeOverlays:mapView.overlays];
    [mapView doClustering];
}

// ==============================
#pragma mark - logic

//
// Help method which returns an array of random CLLocations
// You can specify the number of coordinates by setting numberOfCoordinates
- (NSArray *)randomCoordinatesGenerator:(int) numberOfCoordinates{
    
    numberOfCoordinates = (numberOfCoordinates < 0) ? 0 : numberOfCoordinates;
    
    NSMutableArray *coordinates = [[NSMutableArray alloc] initWithCapacity:numberOfCoordinates];
    for (int i = 0; i < numberOfCoordinates; i++) {
        
        //Get random coordinates
        CLLocationDistance latitude = ((float)arc4random() / ARC4RANDOM_MAX) * 180.0 - 90.0;    // the latitude goes from +90° - 0 - -90°
        CLLocationDistance longitude = ((float)arc4random() / ARC4RANDOM_MAX) * 360.0 - 180.0;  // the longitude goes from +180° - 0 - -180°
        
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        [coordinates addObject:loc];
        [loc release];
    }
    return  [coordinates autorelease];
}

- (void)dealloc {
    [super dealloc];
}
@end
