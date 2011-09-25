//
//  OClusterMapView_SampleAppDelegate.h
//  OClusterMapView+Sample
//
//  Created by Botond Kis on 25.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OClusterMapView_SampleViewController;

@interface OClusterMapView_SampleAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet OClusterMapView_SampleViewController *viewController;

@end
