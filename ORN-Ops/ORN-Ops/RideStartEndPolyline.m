//
//  RideStartEndPolyline.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-10.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "RideStartEndPolyline.h"


#
# pragma mark - Implementation
#


@implementation RideStartEndPolyline


#
# pragma mark Initializers
#


- (instancetype)initWithRide:(Ride*)ride andPolyline:(MKPolyline*)polyline {
	
	// If no polyline provided, construct basic one from ride itself
	if (!polyline &&
		ride.locationStartLatitude &&
		ride.locationStartLongitude &&
		ride.locationEndLatitude &&
		ride.locationEndLongitude
		) {

		CLLocationCoordinate2D locationCoordinates[2] =
		{
			CLLocationCoordinate2DMake(ride.locationStartLatitude.doubleValue, ride.locationStartLongitude.doubleValue),
			CLLocationCoordinate2DMake(ride.locationEndLatitude.doubleValue, ride.locationEndLongitude.doubleValue)
		};
		
		polyline = [MKPolyline polylineWithCoordinates:locationCoordinates count:2];
	}
	
	self = [super initWithPolyline:polyline];
	
	if (self) {
		
		_ride = ride;
	}
	
	return self;
}


- (instancetype)init {
	
	return [self initWithRide:nil andPolyline:nil];
}


+ (instancetype)rideStartEndPolylineWithRide:(Ride*)ride andPolyline:(MKPolyline*)polyline {

	return [[RideStartEndPolyline alloc] initWithRide:ride andPolyline:polyline];
}


@end
