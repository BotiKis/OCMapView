//
//  OClusterMapView_SampleViewController.m
//  OClusterMapView+Sample
//
//  Created by Botond Kis on 25.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OClusterMapView_SampleViewController.h"
#import "OCMapViewSampleHelpAnnotation.h"

static NSString *const kTYPE1 = @"Banana";
static NSString *const kTYPE2 = @"Orange";
static CGFloat kDEFAULTCLUSTERSIZE = 0.2;

@implementation OClusterMapView_SampleViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    self.labelNumberOfAnnotations.text = @"Number of Annotations: 0";
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        for (UIButton *button in self.view.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                [button setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
            }
        }
        [self.view performSelector:@selector(setTintColor:) withObject:[UIColor cyanColor]];
        self.mapView.frame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
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
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    self.labelNumberOfAnnotations.text = @"Number of Annotations: 0";
}

- (IBAction)addButtonTouchUpInside:(id)sender {
    [self.mapView removeOverlays:self.mapView.overlays];
    NSArray *randomLocations = [[NSArray alloc] initWithArray:[self randomCoordinatesGenerator:100]];
    NSMutableSet *annotationsToAdd = [[NSMutableSet alloc] init];
    
    for (CLLocation *loc in randomLocations) {
        OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc] initWithCoordinate:loc.coordinate];
        [annotationsToAdd addObject:annotation];
        
        // add to group if specified
        if (annotationsToAdd.count < (randomLocations.count)/2) {
            annotation.groupTag = kTYPE1;
        }
        else{
            annotation.groupTag = kTYPE2;
        }
        
    }
    
    [self.mapView addAnnotations:[annotationsToAdd allObjects]];
    self.labelNumberOfAnnotations.text = [NSString stringWithFormat:@"Number of Annotations: %zd", [self.mapView.annotations count]];
}

- (IBAction)clusteringButtonTouchUpInside:(UIButton *)sender {
    [self.mapView removeOverlays:self.mapView.overlays];
    if (self.mapView.clusteringEnabled) {
        [sender setTitle:@"turn clustering on" forState:UIControlStateNormal];
        [sender setTitle:@"turn clustering on" forState:UIControlStateSelected];
        [sender setTitle:@"turn clustering on" forState:UIControlStateHighlighted];
        self.mapView.clusteringEnabled = NO;
    }
    else{
        [sender setTitle:@"turn clustering off" forState:UIControlStateNormal];
        [sender setTitle:@"turn clustering off" forState:UIControlStateSelected];
        [sender setTitle:@"turn clustering off" forState:UIControlStateHighlighted];
        self.mapView.clusteringEnabled = YES;
    }
    [self.mapView doClustering];
}

- (IBAction)addOneButtonTouchupInside:(id)sender {
    [self.mapView removeOverlays:self.mapView.overlays];
    NSArray *randomLocations = [[NSArray alloc] initWithArray:[self randomCoordinatesGenerator:1]];
    CLLocationCoordinate2D loc = ((CLLocation *)[randomLocations objectAtIndex:0]).coordinate;
    OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc] initWithCoordinate:loc];
    
    [self.mapView addAnnotation:annotation];
    self.labelNumberOfAnnotations.text = [NSString stringWithFormat:@"Number of Annotations: %zd", [self.mapView.annotations count]];
}

- (IBAction)changeClusterMethodButtonTouchUpInside:(UIButton *)sender {    
    [self.mapView removeOverlays:self.mapView.overlays];
    if (self.mapView.clusteringMethod == OCClusteringMethodBubble) {
        [sender setTitle:@"Bubble cluster" forState:UIControlStateNormal];
        [sender setTitle:@"Bubble cluster" forState:UIControlStateSelected];
        [sender setTitle:@"Bubble cluster" forState:UIControlStateHighlighted];
        self.mapView.clusteringMethod = OCClusteringMethodGrid;
    }
    else{
        [sender setTitle:@"Grid cluster" forState:UIControlStateNormal];
        [sender setTitle:@"Grid cluster" forState:UIControlStateSelected];
        [sender setTitle:@"Grid cluster" forState:UIControlStateHighlighted];
        self.mapView.clusteringMethod = OCClusteringMethodBubble;
    }
    [self.mapView doClustering];
}

- (IBAction)infoButtonTouchUpInside:(UIButton *)sender {
    [[[UIAlertView alloc] initWithTitle:@"Info"
                                message:@"The size of a cluster-annotation represents the number of annotations it contains and not its size."
                               delegate:nil
                      cancelButtonTitle:@"great!"
                      otherButtonTitles:nil] show];
}

- (IBAction)buttonGroupByTagTouchUpInside:(UIButton *)sender {
    self.mapView.clusterByGroupTag = ! self.mapView.clusterByGroupTag;
    if(self.mapView.clusterByGroupTag){
        [sender setTitle:@"turn groups off" forState:UIControlStateNormal];
        self.mapView.clusterSize = kDEFAULTCLUSTERSIZE * 2.0;
    }
    else{
        [sender setTitle:@"turn groups on" forState:UIControlStateNormal];
        self.mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    }
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView doClustering];
}

// ==============================
#pragma mark - map delegate
- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation{
    MKAnnotationView *annotationView;
    
    // if it's a cluster
    if ([annotation isKindOfClass:[OCAnnotation class]]) {
        
        OCAnnotation *clusterAnnotation = (OCAnnotation *)annotation;
        
        annotationView = (MKAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"ClusterView"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ClusterView"];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        //calculate cluster region
        CLLocationDistance clusterRadius = self.mapView.region.span.longitudeDelta * self.mapView.clusterSize * 111000 / 2.0f; //static circle size of cluster
        //CLLocationDistance clusterRadius = self.mapView.region.span.longitudeDelta/log(self.mapView.region.span.longitudeDelta*self.mapView.region.span.longitudeDelta) * log(pow([clusterAnnotation.annotationsInCluster count], 4)) * self.mapView.clusterSize * 50000; //circle size based on number of annotations in cluster
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:clusterAnnotation.coordinate radius:clusterRadius * cos([annotation coordinate].latitude * M_PI / 180.0)];
        [circle setTitle:@"background"];
        [self.mapView addOverlay:circle];
        
        MKCircle *circleLine = [MKCircle circleWithCenterCoordinate:clusterAnnotation.coordinate radius:clusterRadius * cos([annotation coordinate].latitude * M_PI / 180.0)];
        [circleLine setTitle:@"line"];
        [self.mapView addOverlay:circleLine];
        
        // set title
        clusterAnnotation.title = @"Cluster";
        clusterAnnotation.subtitle = [NSString stringWithFormat:@"Containing annotations: %zd", [clusterAnnotation.annotationsInCluster count]];
        
        // set its image
        annotationView.image = [UIImage imageNamed:@"regular.png"];
        
        // change pin image for group
        if (self.mapView.clusterByGroupTag) {
            if ([clusterAnnotation.groupTag isEqualToString:kTYPE1]) {
                annotationView.image = [UIImage imageNamed:@"bananas.png"];
            }
            else if([clusterAnnotation.groupTag isEqualToString:kTYPE2]){
                annotationView.image = [UIImage imageNamed:@"oranges.png"];
            }
            clusterAnnotation.title = clusterAnnotation.groupTag;
        }
    }
    // If it's a single annotation
    else if([annotation isKindOfClass:[OCMapViewSampleHelpAnnotation class]]){
        OCMapViewSampleHelpAnnotation *singleAnnotation = (OCMapViewSampleHelpAnnotation *)annotation;
        annotationView = (MKAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"singleAnnotationView"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:singleAnnotation reuseIdentifier:@"singleAnnotationView"];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        singleAnnotation.title = singleAnnotation.groupTag;
        
        if ([singleAnnotation.groupTag isEqualToString:kTYPE1]) {
            annotationView.image = [UIImage imageNamed:@"banana.png"];
        }
        else if([singleAnnotation.groupTag isEqualToString:kTYPE2]){
            annotationView.image = [UIImage imageNamed:@"orange.png"];
        }
    }
    // Error
    else{
        annotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"errorAnnotationView"];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"errorAnnotationView"];
            annotationView.canShowCallout = NO;
            ((MKPinAnnotationView *)annotationView).pinColor = MKPinAnnotationColorRed;
        }
    }
    
    return annotationView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
    MKCircle *circle = overlay;
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];
    
    if ([circle.title isEqualToString:@"background"])
    {
        circleView.fillColor = [UIColor yellowColor];
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
        circleView.lineWidth = 0.5;
    }
    
    return circleView;
}

- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView doClustering];
}

// ==============================
#pragma mark - logic

//
// Help method which returns an array of random CLLocations
// You can specify the number of coordinates by setting numberOfCoordinates
- (NSArray *)randomCoordinatesGenerator:(int)numberOfCoordinates
{
    MKCoordinateRegion visibleRegion = self.mapView.region;
    visibleRegion.span.latitudeDelta *= 0.8;
    visibleRegion.span.longitudeDelta *= 0.8;
    
    numberOfCoordinates = MAX(0,numberOfCoordinates);
    NSMutableArray *coordinates = [[NSMutableArray alloc] initWithCapacity:numberOfCoordinates];
    for (int i = 0; i < numberOfCoordinates; i++) {
        
        // start with top left corner
        CLLocationDistance longitude = visibleRegion.center.longitude - visibleRegion.span.longitudeDelta/2.0;
        CLLocationDistance latitude  = visibleRegion.center.latitude + visibleRegion.span.latitudeDelta/2.0;
        
        // Get random coordinates within current map rect
        NSInteger max = NSIntegerMax;
        longitude += (arc4random()%max)/(CGFloat)max * visibleRegion.span.longitudeDelta;
        latitude  -= (arc4random()%max)/(CGFloat)max * visibleRegion.span.latitudeDelta;
        
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        [coordinates addObject:loc];
    }
    return  coordinates;
}

@end
