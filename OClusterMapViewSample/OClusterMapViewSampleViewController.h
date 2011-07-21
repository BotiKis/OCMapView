//
//  OClusterMapViewSampleViewController.h
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OCMapView.h"

@interface OClusterMapViewSampleViewController : UIViewController <MKMapViewDelegate> {
    OCMapView *mapView;
    IBOutlet UILabel *labelNumberOfAnnotations;
}

@property (nonatomic, strong) IBOutlet OCMapView *mapView;
- (IBAction)removeButtonTouchUpInside:(id)sender;
- (IBAction)addButtonTouchUpInside:(id)sender;
- (IBAction)clusteringButtonTouchUpInside:(UIButton *)sender;
- (IBAction)addOneButtonTouchupInside:(id)sender;
- (IBAction)changeClusterMethodButtonTouchUpInside:(UIButton *)sender;

- (NSArray *)randomCoordinatesGenerator:(int) numberOfCoordinates;

@end
