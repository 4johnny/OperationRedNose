//
//  RideStartEndPolyline.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-10.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "RidePolyline.h"
#import "Team+TeamHelpers.h"


#
# pragma mark - Implementation
#


@implementation RidePolyline


#
# pragma mark Initializers
#


- (instancetype)initWithPolyline:(MKPolyline*)polyline
						 andRide:(Ride*)ride
				andRideRouteType:(RideRouteType)rideRouteType {
	
	// If no polyline provided, construct basic one from ride itself based on ride route type
	
	if (!polyline) {
	
		switch (rideRouteType) {
				
			case RideRouteType_Main:
				
				if (ride.locationStartLatitude && ride.locationStartLongitude &&
					ride.locationEndLatitude && ride.locationEndLongitude) {
					
					CLLocationCoordinate2D locationCoordinates[2] =
					{
						[ride getLocationStartCoordinate],
						[ride getLocationEndCoordinate],
					};
					
					polyline = [MKPolyline polylineWithCoordinates:locationCoordinates count:2];
				}
				break;
				
			case RideRouteType_Prep:
				
				// If first ride is Transporting, create polyline to ride end, o/w to ride start
				if (ride.status.integerValue == RideStatus_Transporting &&
					ride == [ride.teamAssigned getSortedActiveRidesAssigned].firstObject) {

					if (ride.locationPrepLatitude && ride.locationPrepLongitude &&
						ride.locationEndLatitude && ride.locationEndLongitude) {
						
						CLLocationCoordinate2D locationCoordinates[2] =
						{
							[ride getLocationPrepCoordinate],
							[ride getLocationEndCoordinate],
						};
						
						polyline = [MKPolyline polylineWithCoordinates:locationCoordinates count:2];
					}
					
				} else {
				
					if (ride.locationPrepLatitude && ride.locationPrepLongitude &&
						ride.locationStartLatitude && ride.locationStartLongitude) {
						
						CLLocationCoordinate2D locationCoordinates[2] =
						{
							[ride getLocationPrepCoordinate],
							[ride getLocationStartCoordinate],
						};
						
						polyline = [MKPolyline polylineWithCoordinates:locationCoordinates count:2];
					}
				}
				break;
				
			case RideRouteType_Wait:
				
				// If first ride is Transporting, create polyline to ride end, o/w to ride start
				if (ride.status.integerValue == RideStatus_Transporting &&
					ride == [ride.teamAssigned getSortedActiveRidesAssigned].firstObject) {
					
					if (ride.teamAssigned.locationCurrentLatitude && ride.teamAssigned.locationCurrentLongitude &&
						ride.locationEndLatitude && ride.locationEndLongitude) {
						
						CLLocationCoordinate2D locationCoordinates[2] =
						{
							[ride.teamAssigned getLocationCurrentCoordinate],
							[ride getLocationEndCoordinate],
						};
						
						polyline = [MKPolyline polylineWithCoordinates:locationCoordinates count:2];
					}
					
				} else {
					
					if (ride.teamAssigned.locationCurrentLatitude && ride.teamAssigned.locationCurrentLongitude &&
						ride.locationStartLatitude && ride.locationStartLongitude) {
						
						CLLocationCoordinate2D locationCoordinates[2] =
						{
							[ride.teamAssigned getLocationCurrentCoordinate],
							[ride getLocationStartCoordinate],
						};
						
						polyline = [MKPolyline polylineWithCoordinates:locationCoordinates count:2];
					}
				}
				break;
				
			default:
			case RideRouteType_None:
				break;
		}
	}
	
	if (!polyline) return nil;
	
	self = [super initWithPolyline:polyline];
	
	if (self) {
		
		_ride = ride;
		_rideRouteType = rideRouteType;
	}
	
	return self;
}


- (instancetype)init {
	
	return [self initWithPolyline:nil andRide:nil andRideRouteType:RideRouteType_None];
}


+ (instancetype)ridePolylineWithPolyline:(MKPolyline*)polyline
								 andRide:(Ride*)ride
						andRideRouteType:(RideRouteType)rideRouteType {
	
	return [[RidePolyline alloc] initWithPolyline:polyline
										  andRide:ride
								 andRideRouteType:rideRouteType];
}

	
+ (instancetype)ridePolyline:(RidePolyline*)ridePolyline
				withPolyline:(MKPolyline*)polyline
					 andRide:(Ride*)ride
			andRideRouteType:(RideRouteType)rideRouteType {
	
	return ridePolyline
	? [ridePolyline initWithPolyline:polyline
							 andRide:ride
					andRideRouteType:rideRouteType]
	: [RidePolyline ridePolylineWithPolyline:polyline
									 andRide:ride
							andRideRouteType:rideRouteType];
}




@end
