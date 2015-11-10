//
//  RidePointAnnotation.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "RidePointAnnotation.h"


#
# pragma mark - Implementation
#


@implementation RidePointAnnotation


#
# pragma mark Initializers
#


- (instancetype)initWithRide:(Ride*)ride
		 andRideLocationType:(RideLocationType)rideLocationType
		andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop {
	
	self = [super init];
	if (self) {

		_ride = ride;
		_rideLocationType = rideLocationType;
		_needsAnimatesDrop = needsAnimatesDrop;
		
		NSString* titlePrefix = [ride getRideStatusTextShort];
		
		switch (_rideLocationType) {
				
			case RideLocationType_Start:
				self.coordinate = [_ride getLocationStartCoordinate];
				self.subtitle = _ride.locationStartAddress;
				break;
				
			case RideLocationType_End:
				self.coordinate = [_ride getLocationEndCoordinate];
				self.subtitle = _ride.locationEndAddress;
				break;
				
			default:
			case RideLocationType_None:
				break;
		}
		
		self.title = [NSString stringWithFormat:@"%@: %@", titlePrefix, [_ride getTitle]];
	}
	
	return self;
}


- (instancetype)init {
	
	return [self initWithRide:nil andRideLocationType:RideLocationType_None andNeedsAnimatesDrop:NO];
}


+ (instancetype)ridePointAnnotationWithRide:(Ride*)ride
						andRideLocationType:(RideLocationType)rideLocationType
					   andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop {

	return [[RidePointAnnotation alloc] initWithRide:ride
								 andRideLocationType:rideLocationType
								andNeedsAnimatesDrop:needsAnimatesDrop];
}


+ (instancetype)ridePointAnnotation:(RidePointAnnotation*)ridePointAnnotation
						   withRide:(Ride*)ride
				andRideLocationType:(RideLocationType)rideLocationType
			   andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop {

	return ridePointAnnotation
	? [ridePointAnnotation initWithRide:ride
					andRideLocationType:rideLocationType
				   andNeedsAnimatesDrop:needsAnimatesDrop]
	: [RidePointAnnotation ridePointAnnotationWithRide:ride
								   andRideLocationType:rideLocationType
								  andNeedsAnimatesDrop:needsAnimatesDrop];
}


@end
