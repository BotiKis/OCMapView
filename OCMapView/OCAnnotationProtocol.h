//
//  OCGrouping.h
//  OClusterMapView+Sample
//
//  Created by Fedya Skitsko on 13.02.12.
//  Copyright (c) 2012 Skitsko. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Protocol which is needed to use clusters
/** Implement this protocol to in an annotation to enable cluster*/
@protocol OCAnnotationProtocol <NSObject>
- (NSArray *)annotationsInCluster;
- (void)addAnnotation:(id < MKAnnotation >)annotation;

- (CLLocationCoordinate2D)coordinate;
- (void)setCoordinate:(CLLocationCoordinate2D)coord;
@end