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


- (instancetype)initWithRide:(Ride*)ride andRideLocationType:(RideLocationType)rideLocationType {
	
	self = [super init];
	if (self) {

		_ride = ride;
		_rideLocationType = rideLocationType;
		
		switch (_rideLocationType) {
				
			case RideLocationType_Start:
				self.coordinate = CLLocationCoordinate2DMake(_ride.locationStartLatitude.doubleValue, _ride.locationStartLongitude.doubleValue);
				self.title = @"Ride Start";
  		  		break;
				
			case RideLocationType_End:
				self.coordinate = CLLocationCoordinate2DMake(_ride.locationEndLatitude.doubleValue, _ride.locationEndLongitude.doubleValue);
				self.title = @"Ride End";
				break;
				
			default:
			case RideLocationType_None:
			    break;
		}
		
		self.subtitle = _ride.locationStartAddress;
	}
	
	return self;
}


- (instancetype)init {
	
	return [self initWithRide:nil andRideLocationType:RideLocationType_None];
}


+ (instancetype)ridePointAnnotationWithRide:(Ride*)ride andRideLocationType:(RideLocationType)rideLocationType {

	return [[RidePointAnnotation alloc] initWithRide:ride andRideLocationType:rideLocationType];
}


@end
