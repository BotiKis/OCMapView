//
//  OCAlgorithmDelegate.h
//  OClusterMapView+Sample
//
//  Created by Markus on 24.09.13.
//
//

#import <Foundation/Foundation.h>

/// Protocol for notifying on Cluster events. NOT in use yet.
/** Implement this protocol if you are using asynchronous clustering algorithms.
 In fact, there isn't one yet. This just demonstrates where this class will develop to in future.*/
@protocol OCAlgorithmDelegate <NSObject>
@required
/// Called when an algorithm finishes a block of calculations
- (NSArray *)algorithmClusteredPartially;
@optional
/// Called when algorithm starts calculating.
- (void)algorithmDidBeganClustering;
/// Called when algorithm finishes calculating.
- (void)algorithmDidFinishClustering;
@end

