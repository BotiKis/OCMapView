//
//  OClusterMapView_SampleAppDelegate.m
//  OClusterMapView+Sample
//
//  Created by Botond Kis on 25.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OClusterMapView_SampleAppDelegate.h"

#import "OClusterMapView_SampleViewController.h"
#import "OCDistanceCalculationPerformance.h"

@implementation OClusterMapView_SampleAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *nibName = @"OClusterMapView_SampleViewController-iPhone";
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        nibName = @"OClusterMapView_SampleViewController-iPad";
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[OClusterMapView_SampleViewController alloc]
                                      initWithNibName:nibName bundle:nil];
    [self.window makeKeyAndVisible];
    
//    [OCDistanceCalculationPerformance testDistanceCalculationPerformance];
    
    return YES;
}


@end
