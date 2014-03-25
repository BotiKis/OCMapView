//
//  OCDistanceCalculationPerformance.m
//  OClusterMapView+Sample
//
//  Created by Markus on 25.09.13.
//
//

#import <MapKit/MapKit.h>
#include <sys/sysctl.h>

#import "OCDistanceCalculationPerformance.h"

void show(NSString *string);
void show(NSString *string)
{
    CFShow((__bridge CFTypeRef)string);
}

double CLLocationCoordinateDistanceM(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2);
double CLLocationCoordinateDistanceM(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2)
{
    CLLocationDegrees deltaLat = c1.latitude - c2.latitude;
    CLLocationDegrees deltaLong = c1.longitude - c2.longitude;
    return sqrt(deltaLat*deltaLat + deltaLong*deltaLong);
}

double CLLocationCoordinateDistancePow(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2);
double CLLocationCoordinateDistancePow(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2)
{
    return sqrt(pow(c1.latitude  - c2.latitude , 2.0) +
                pow(c1.longitude - c2.longitude, 2.0));
}

@implementation OCDistanceCalculationPerformance

+ (void)testDistanceCalculationPerformance;
{
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    // Performance Test
    @autoreleasepool {
        NSDate *startDate = [NSDate date];
        int count = 250000, runs = 500;
        CLLocation *randomLoc = [self randomCoordinatesGenerator:1][0];
        NSArray *otherLocs = [self randomCoordinatesGenerator:count];
        
        show([NSString stringWithFormat:@"Device/OS: '%@', iOS %@", [self platform], [[UIDevice currentDevice] systemVersion]]);
        show([NSString stringWithFormat:@"Testing %zd runs of distance calculation per method with %@ coords", runs, [numFormatter stringFromNumber:@(count)]]);
        show([NSString stringWithFormat:@">> This will be %@ distance calculations.", [numFormatter stringFromNumber:@(count*runs)]]);
        CGFloat firstDuration = 0;
        for (int type=0; type<2; type++) {
            NSDate *dateForType = [NSDate date];
            for (int i=0; i<runs; i++) {
                CGFloat maxDistance = 0;
                for (CLLocation *location in otherLocs) {
                    CGFloat distance = 0;
                    if (type == 0) {
                        distance = CLLocationCoordinateDistanceM(location.coordinate, randomLoc.coordinate);
                    } else {
                        distance = CLLocationCoordinateDistancePow(location.coordinate, randomLoc.coordinate);
                    }
                    maxDistance = MAX(distance, maxDistance);
                }
            }
            
            NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:dateForType];
            duration /= runs;
            
            NSString *method = (type==0)?@"MULTIPLY":@"POW";
            show([NSString stringWithFormat:@"== %@: AVERAGE DURATION IN %zd RUNS: %.5fs/run ====", method, runs, duration]);
            
            if (type == 1) {
                show([NSString stringWithFormat: @"Difference: %.7fs/run", ABS(firstDuration-duration)]);
                if (duration > firstDuration) {
                    show([NSString stringWithFormat: @"POW was %.3f%% faster.", duration/firstDuration - 1.0]);
                } else {
                    show([NSString stringWithFormat: @"MULTIPLY was %.3f%% faster.", firstDuration/duration - 1.0]);
                }
            } else {
                firstDuration = duration;
            }
        }
        show([NSString stringWithFormat: @"This needed %.2fs in total.", [[NSDate date] timeIntervalSinceDate:startDate]]);
    }
}

//
// Help method which returns an array of random CLLocations
// You can specify the number of coordinates by setting numberOfCoordinates
+ (NSArray *)randomCoordinatesGenerator:(int)numberOfCoordinates
{
    MKCoordinateRegion sampleRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(52.0,13.0), MKCoordinateSpanMake(20.0, 20.0));
    
    numberOfCoordinates = MAX(0,numberOfCoordinates);
    NSMutableArray *coordinates = [[NSMutableArray alloc] initWithCapacity:numberOfCoordinates];
    for (int i = 0; i < numberOfCoordinates; i++) {
        
        // start with top left corner
        CLLocationDistance longitude = sampleRegion.center.longitude - sampleRegion.span.longitudeDelta/2.0;
        CLLocationDistance latitude  = sampleRegion.center.latitude + sampleRegion.span.latitudeDelta/2.0;
        
        // Get random coordinates within current map rect
        NSInteger max = NSIntegerMax;
        longitude += (arc4random()%max)/(CGFloat)max * sampleRegion.span.longitudeDelta;
        latitude  -= (arc4random()%max)/(CGFloat)max * sampleRegion.span.latitudeDelta;
        
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        [coordinates addObject:loc];
    }
    return  coordinates;
}

#pragma mark device info

+ (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

+ (NSString *) platform
{
    return [self getSysInfoByName:"hw.machine"];
}

@end
