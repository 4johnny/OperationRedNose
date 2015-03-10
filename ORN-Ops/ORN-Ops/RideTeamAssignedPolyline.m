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
# pragma mark - Interface
#


@interface RideTeamAssignedPolyline ()

@property (nonatomic) MKPolyline* polyline;

@end


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
			
			_polyline = [MKPolyline polylineWithCoordinates:locationCoordinates count:2];
			
		} else {
			
			_polyline = [MKPolyline polylineWithCoordinates:NULL count:0];
		}
	}
	
	return self;
}


- (instancetype)init {
	
	return [self initWithRide:nil andStartCoordinate:NULL];
}


+ (instancetype)rideTeamPolylineWithRide:(Ride*)ride andStartCoordinate:(CLLocationCoordinate2D*)startCoordinate {
	
	return [[RideTeamAssignedPolyline alloc] initWithRide:ride andStartCoordinate:startCoordinate];
}


#
# pragma mark <MKOverlay>
#


- (CLLocationCoordinate2D)coordinate {
	
	return _polyline.coordinate;
}


- (MKMapRect)boundingMapRect {

	return _polyline.boundingMapRect;
}


- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
	
	return [_polyline intersectsMapRect:mapRect];
}


#
# pragma mark MKMultiPoint
#
// NOTE: Required for rendering by MKPolylineRenderer


- (MKMapPoint*)points {
	
	return [_polyline points];
}


- (NSUInteger)pointCount {
	
	return [_polyline pointCount];
}


- (void)getCoordinates:(CLLocationCoordinate2D*)coords range:(NSRange)range {
	
	return [_polyline getCoordinates:coords range:range];
}


@end
