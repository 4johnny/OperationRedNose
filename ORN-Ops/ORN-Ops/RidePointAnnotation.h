//
//  RidePointAnnotation.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Ride+RideHelpers.h"

#
# pragma mark - Interface
#

@interface RidePointAnnotation : MKPointAnnotation <RideModelSource>

#
# pragma mark Properties
#

@property (weak, nonatomic) Ride* ride;
@property (nonatomic) RideLocationType rideLocationType;
@property (nonatomic) BOOL needsAnimatesDrop;

#
# pragma mark Initializers
#

- (instancetype)initWithRide:(Ride*)ride andRideLocationType:(RideLocationType)rideLocationType andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop;
- (instancetype)init;

+ (instancetype)ridePointAnnotationWithRide:(Ride*)ride andRideLocationType:(RideLocationType)rideLocationType andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop;
+ (instancetype)ridePointAnnotation:(RidePointAnnotation*)ridePointAnnotation withRide:(Ride*)ride andRideLocationType:(RideLocationType)rideLocationType andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop;

@end
