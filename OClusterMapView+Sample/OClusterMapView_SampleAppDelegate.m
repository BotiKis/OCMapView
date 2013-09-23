//
//  OClusterMapView_SampleAppDelegate.m
//  OClusterMapView+Sample
//
//  Created by Botond Kis on 25.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OClusterMapView_SampleAppDelegate.h"

#import "OClusterMapView_SampleViewController.h"

@implementation OClusterMapView_SampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = window;
    [window release];
    
    NSString *nibName = @"OClusterMapView_SampleViewController-iPhone";
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        nibName = @"OClusterMapView_SampleViewController-iPad";
    }
    
    OClusterMapView_SampleViewController *controller = [[OClusterMapView_SampleViewController alloc]
                                                        initWithNibName:nibName bundle:nil];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    [controller release];
    
    return YES;
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
