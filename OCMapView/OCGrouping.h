//
//  OCGrouping.h
//  OClusterMapView+Sample
//
//  Created by Botond Kis on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

/// Protocol which is needed to use different groups of clusters
/** Implement this protocol in an annotation to enable clustering of groups
 */
@protocol OCGrouping <MKAnnotation>
@property (nonatomic, readonly, copy) NSString *groupTag;
@end
