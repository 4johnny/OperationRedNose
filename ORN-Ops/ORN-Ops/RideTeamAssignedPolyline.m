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
	
	self = [super init];
	if (self) {
		
		_ride = ride;
		
		if (_ride.teamAssigned && _ride.teamAssigned.locationCurrentLatitude && _ride.teamAssigned.locationCurrentLongitude && startCoordinate) {
			
			CLLocationCoordinate2D locationCoordinates[2] = { CLLocationCoordinate2DMake(ride.teamAssigned.locationCurrentLatitude.doubleValue, ride.teamAssigned.locationCurrentLongitude.doubleValue), *startCoordinate };
			
			self = [super initWithPolyline:[MKPolyline polylineWithCoordinates:locationCoordinates count:2]];
			
		} else {
			
			self = [super initWithPolyline:[MKPolyline polylineWithCoordinates:NULL count:0]];
		}
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
