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
