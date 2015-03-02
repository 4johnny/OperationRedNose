//
//  RidePointAnnotation.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Ride.h"


#
# pragma mark - Types
#

typedef NS_ENUM(NSInteger, RideLocationType) {

	RideLocationType_None = 0,
	
	RideLocationType_Start,
	RideLocationType_End
};

#
# pragma mark - Interface
#

@interface RidePointAnnotation : MKPointAnnotation

#
# pragma mark Properties
#

@property (nonatomic) Ride* ride;
@property (nonatomic) RideLocationType rideLocationType;

#
# pragma mark Initializers
#

- (instancetype)initWithRide:(Ride*)ride andRideLocationType:(RideLocationType)rideLocationType;
- (instancetype)init;
+ (instancetype)ridePointAnnotationWithRide:(Ride*)ride andRideLocationType:(RideLocationType)rideLocationType;


@end
