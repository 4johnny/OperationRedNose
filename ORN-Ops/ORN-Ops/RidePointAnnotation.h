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

@interface RidePointAnnotation : MKPointAnnotation

#
# pragma mark Properties
#

// TODO: Consider whether ride property should be weak
@property (nonatomic) Ride* ride;
@property (nonatomic) RideLocationType rideLocationType;
@property (nonatomic) BOOL needsAnimatesDrop;

#
# pragma mark Initializers
#

- (instancetype)initWithRide:(Ride*)ride andRideLocationType:(RideLocationType)rideLocationType andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop;
- (instancetype)init;

+ (instancetype)ridePointAnnotationWithRide:(Ride*)ride andRideLocationType:(RideLocationType)rideLocationType andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop;

@end
