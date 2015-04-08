//
//  RideStartEndPolyline.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-10.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "RidePolyline.h"


#
# pragma mark - Implementation
#


@implementation RidePolyline


#
# pragma mark Initializers
#


- (instancetype)initWithPolyline:(MKPolyline*)polyline andRide:(Ride*)ride andRideRouteType:(RideRouteType)rideRouteType {
	
	// If no polyline provided, construct basic one from ride itself based on ride route type
	
	if (!polyline) {
	
		switch (rideRouteType) {
				
			case RideRouteType_Main:
				
				if (ride.locationStartLatitude &&
					ride.locationStartLongitude &&
					ride.locationEndLatitude &&
					ride.locationEndLongitude) {
					
					CLLocationCoordinate2D locationCoordinates[2] =
					{
						CLLocationCoordinate2DMake(ride.locationStartLatitude.doubleValue, ride.locationStartLongitude.doubleValue),
						CLLocationCoordinate2DMake(ride.locationEndLatitude.doubleValue, ride.locationEndLongitude.doubleValue)
					};
					
					polyline = [MKPolyline polylineWithCoordinates:locationCoordinates count:2];
				}
				break;
				
			case RideRouteType_Prep:
				
				if (ride.locationPrepLatitude &&
					ride.locationPrepLongitude &&
					ride.locationStartLatitude &&
					ride.locationStartLongitude) {
					
					CLLocationCoordinate2D locationCoordinates[2] =
					{
						CLLocationCoordinate2DMake(ride.locationPrepLatitude.doubleValue, ride.locationPrepLongitude.doubleValue),
						CLLocationCoordinate2DMake(ride.locationStartLatitude.doubleValue, ride.locationStartLongitude.doubleValue)
					};
					
					polyline = [MKPolyline polylineWithCoordinates:locationCoordinates count:2];
				}
				break;
				
			default:
			case RideRouteType_None:
				break;
		}
	}
	
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


+ (instancetype)ridePolylineWithPolyline:(MKPolyline*)polyline andRide:(Ride*)ride andRideRouteType:(RideRouteType)rideRouteType {

	return [[RidePolyline alloc] initWithPolyline:polyline andRide:ride andRideRouteType:rideRouteType];
}


@end
