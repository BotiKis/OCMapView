//
//  OClusterMapView_SampleViewController.h
//  OClusterMapView+Sample
//
//  Created by Botond Kis on 25.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OCMapView.h"

@interface OClusterMapView_SampleViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *labelNumberOfAnnotations;
@property (nonatomic, strong) IBOutlet OCMapView *mapView;

- (IBAction)removeButtonTouchUpInside:(id)sender;
- (IBAction)addButtonTouchUpInside:(id)sender;
- (IBAction)clusteringButtonTouchUpInside:(UIButton *)sender;
- (IBAction)addOneButtonTouchupInside:(id)sender;
- (IBAction)changeClusterMethodButtonTouchUpInside:(UIButton *)sender;
- (IBAction)buttonGroupByTagTouchUpInside:(UIButton *)sender;

- (NSArray *)randomCoordinatesGenerator:(int)numberOfCoordinates;

@end
