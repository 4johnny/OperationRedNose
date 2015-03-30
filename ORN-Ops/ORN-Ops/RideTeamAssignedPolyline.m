//
//  RideTeamAssignedPolyline.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-09.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "RideTeamAssignedPolyline.h"
#import "Team+TeamHelpers.h"


#
# pragma mark - Implementation
#


@implementation RideTeamAssignedPolyline


#
# pragma mark Initializers
#


- (instancetype)initWithRide:(Ride*)ride andStartCoordinate:(CLLocationCoordinate2D*)startCoordinate {
	
	if (ride.teamAssigned &&
		ride.teamAssigned.locationCurrentLatitude &&
		ride.teamAssigned.locationCurrentLongitude &&
		startCoordinate) {
		
		CLLocationCoordinate2D locationCoordinates[2] =
		{
			CLLocationCoordinate2DMake(ride.teamAssigned.locationCurrentLatitude.doubleValue, ride.teamAssigned.locationCurrentLongitude.doubleValue),
			*startCoordinate
		};
		
		MKPolyline* polyline = [MKPolyline polylineWithCoordinates:locationCoordinates count:2];
		
		self = [super initWithPolyline:polyline];
		
	} else {
		
		self = [super init];
	}

	if (self) {
		
		_ride = ride;
	}
	
	return self;
}


- (instancetype)init {
	
	return [self initWithRide:nil andStartCoordinate:NULL];
}


+ (instancetype)rideTeamAssignedPolylineWithRide:(Ride*)ride andStartCoordinate:(CLLocationCoordinate2D*)startCoordinate {
	
	return [[RideTeamAssignedPolyline alloc] initWithRide:ride andStartCoordinate:startCoordinate];
}


@end
