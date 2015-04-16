//
//  Ride+RideHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

//#import <AddressBookUI/AddressBookUI.h>
#import "Ride+RideHelpers.h"
#import "Team+TeamHelpers.h"


#
# pragma mark - Constants
#

#define RIDE_CREATED_NOTIFICATION_NAME					@"rideCreated"
#define RIDE_UPDATED_NOTIFICATION_NAME					@"rideUpdated"

#define RIDE_UPDATED_LOCATION_START_NOTIFICATION_KEY	@"rideUpdatedLocationStart"
#define RIDE_UPDATED_LOCATION_END_NOTIFICATION_KEY		@"rideUpdatedLocationEnd"
#define RIDE_UPDATED_TEAM_ASSIGNED_NOTIFICATION_KEY		@"rideUpdatedTeamAssigned"


#
# pragma mark - Implementation
#


@implementation Ride (RideHelpers)


#
# pragma mark Initializers
#

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext andDateTime:(NSDate*)dateTime andPlacemark:(CLPlacemark*)placemark andRideLocationType:(RideLocationType)rideLocationType {

	self = [super initWithEntity:[NSEntityDescription entityForName:RIDE_ENTITY_NAME	 inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	
	if (self) {

		if (rideLocationType == RideLocationType_Start) {
			self.dateTimeStart = dateTime;
		}
		
		if (placemark && rideLocationType != RideLocationType_None) {
			
			[self updateLocationWithPlacemark:placemark andRideLocationType:rideLocationType];
		}
	}
	
	return self;
}


- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	return [self initWithManagedObjectContext:managedObjectContext andDateTime:nil andPlacemark:nil andRideLocationType:RideLocationType_None];
}


+ (instancetype)rideWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext andDateTime:(NSDate*)dateTime andPlacemark:(CLPlacemark*)placemark andRideLocationType:(RideLocationType)rideLocationType {
	
	return [[Ride alloc] initWithManagedObjectContext:managedObjectContext andDateTime:dateTime andPlacemark:placemark andRideLocationType:rideLocationType];
}


+ (instancetype)rideWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	return [[Ride alloc] initWithManagedObjectContext:managedObjectContext];
}


#
# pragma mark Notifications
#


+ (void)addCreatedObserver:(id)observer withSelector:(SEL)selector {

	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:RIDE_CREATED_NOTIFICATION_NAME object:nil];
}


+ (void)addUpdatedObserver:(id)observer withSelector:(SEL)selector {
	
	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:RIDE_UPDATED_NOTIFICATION_NAME object:nil];
}


+ (Ride*)rideFromNotification:(NSNotification*)notification {
	
	return notification.userInfo[RIDE_ENTITY_NAME];
}


+ (BOOL)isUpdatedLocationStartFromNotification:(NSNotification*)notification {
	
	return [Util isValueFromNotification:notification withKey:RIDE_UPDATED_LOCATION_START_NOTIFICATION_KEY];
}


+ (BOOL)isUpdatedLocationEndFromNotification:(NSNotification*)notification {
	
	return [Util isValueFromNotification:notification withKey:RIDE_UPDATED_LOCATION_END_NOTIFICATION_KEY];
}


+ (BOOL)isUpdatedTeamAssignedFromNotification:(NSNotification*)notification {
	
	return [Util isValueFromNotification:notification withKey:RIDE_UPDATED_TEAM_ASSIGNED_NOTIFICATION_KEY];
}


- (void)postNotificationCreatedWithSender:(id)sender  {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RIDE_CREATED_NOTIFICATION_NAME object:sender userInfo:
	 @{RIDE_ENTITY_NAME : self,
	   RIDE_UPDATED_LOCATION_START_NOTIFICATION_KEY : [NSNumber numberWithBool:YES],
	   RIDE_UPDATED_LOCATION_END_NOTIFICATION_KEY : [NSNumber numberWithBool:YES]
	   }];
}


- (void)postNotificationUpdatedWithSender:(id)sender {

	[[NSNotificationCenter defaultCenter] postNotificationName:RIDE_UPDATED_NOTIFICATION_NAME object:sender userInfo:@{RIDE_ENTITY_NAME : self}];
}


- (void)postNotificationUpdatedWithSender:(id)sender andUpdatedLocationStart:(BOOL)updatedLocationStart andUpdatedLocationEnd:(BOOL)updatedLocationEnd {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RIDE_UPDATED_NOTIFICATION_NAME object:sender userInfo:
	 @{RIDE_ENTITY_NAME : self,
	   RIDE_UPDATED_LOCATION_START_NOTIFICATION_KEY : [NSNumber numberWithBool:updatedLocationStart],
	   RIDE_UPDATED_LOCATION_END_NOTIFICATION_KEY : [NSNumber numberWithBool:updatedLocationEnd]
	   }];
}


- (void)postNotificationUpdatedWithSender:(id)sender andUpdatedTeamAssigned:(BOOL)updatedTeamAssigned {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RIDE_UPDATED_NOTIFICATION_NAME object:sender userInfo:
	 @{RIDE_ENTITY_NAME : self,
	   RIDE_UPDATED_TEAM_ASSIGNED_NOTIFICATION_KEY : [NSNumber numberWithBool:updatedTeamAssigned]
	   }];
}


- (void)postNotificationUpdatedWithSender:(id)sender andUpdatedLocationStart:(BOOL)updatedLocationStart andUpdatedLocationEnd:(BOOL)updatedLocationEnd andUpdatedTeamAssigned:(BOOL)updatedTeamAssigned {

	[[NSNotificationCenter defaultCenter] postNotificationName:RIDE_UPDATED_NOTIFICATION_NAME object:sender userInfo:
	 @{RIDE_ENTITY_NAME : self,
	   RIDE_UPDATED_LOCATION_START_NOTIFICATION_KEY : [NSNumber numberWithBool:updatedLocationStart],
	   RIDE_UPDATED_LOCATION_END_NOTIFICATION_KEY : [NSNumber numberWithBool:updatedLocationEnd],
	   RIDE_UPDATED_TEAM_ASSIGNED_NOTIFICATION_KEY : [NSNumber numberWithBool:updatedTeamAssigned]
	   }];
}


#
# pragma mark Instance Helpers
#


/*
 Assign team to ride, including route recalculations and notifications
 */
- (void)assignTeam:(Team*)team withSender:(id)sender {
	
	[self clearPrepRoute];
	
	Team* existingTeamAssigned = self.teamAssigned; // Maybe nil
	
	self.teamAssigned = team;
	
	if (existingTeamAssigned) {
		
		[existingTeamAssigned tryUpdateAssignedRideRoutesWithSender:sender];
		[existingTeamAssigned postNotificationUpdatedWithSender:sender andUpdatedRidesAssigned:YES];
	}
	
	if (team) {
		
		[team tryUpdateAssignedRideRoutesWithSender:sender];
		[team postNotificationUpdatedWithSender:sender andUpdatedRidesAssigned:YES];
	}
	
	[self postNotificationUpdatedWithSender:sender andUpdatedTeamAssigned:YES];
}


- (void)updateLocationWithLatitudeNumber:(NSNumber*)latitude andLogitudeNumber:(NSNumber*)longitude andAddress:(NSString*)address andCity:(NSString*)city andRideLocationType:(RideLocationType)rideLocationType {
	
	switch (rideLocationType) {
			
		default:
		case RideLocationType_Start:
			
			self.locationStartLatitude = latitude;
			self.locationStartLongitude = longitude;
			self.locationStartAddress = address;
			self.locationStartCity = city;
			
			break;
			
		case RideLocationType_End:
			
			self.locationEndLatitude = latitude;
			self.locationEndLongitude = longitude;
			self.locationEndAddress = address;
			self.locationEndCity = city;
			
			break;
	}
}


- (void)updateLocationWithLatitude:(CLLocationDegrees)latitude andLogitude:(CLLocationDegrees)longitude andAddress:(NSString*)address andCity:(NSString*)city andRideLocationType:(RideLocationType)rideLocationType {
	
	[self updateLocationWithLatitudeNumber:[NSNumber numberWithDouble:latitude] andLogitudeNumber:[NSNumber numberWithDouble:longitude] andAddress:address andCity:city andRideLocationType:rideLocationType];
}


- (void)updateLocationWithPlacemark:(CLPlacemark*)placemark andRideLocationType:(RideLocationType)rideLocationType {
	
	[self updateLocationWithLatitude:placemark.location.coordinate.latitude andLogitude:placemark.location.coordinate.longitude andAddress:[Ride getAddressStringWithPlacemark:placemark] andCity:placemark.locality andRideLocationType:rideLocationType];
}


- (void)clearLocationWithRideLocationType:(RideLocationType)rideLocationType {
	
	[self updateLocationWithLatitudeNumber:nil andLogitudeNumber:nil andAddress:nil andCity:nil andRideLocationType:rideLocationType];
}


/*
 Geocode given address string relative to jurisdiction, asynchronously
 */
- (void)tryUpdateLocationWithAddressString:(NSString*)addressString andRideLocationType:(RideLocationType)rideLocationType andGeocoder:(CLGeocoder*)geocoder andSender:(id)sender {
	
	addressString = [addressString trimAll];
	
	CLCircularRegion* jurisdictionRegion = [[CLCircularRegion alloc] initWithCenter:JURISDICTION_COORDINATE radius:JURISDICTION_SEARCH_RADIUS identifier:@"ORN Jurisdication Region"];
	
	[geocoder geocodeAddressString:addressString inRegion:jurisdictionRegion completionHandler:^(NSArray* placemarks, NSError* error) {
		
		// NOTES: Completion block executes on main thread. Do not run more than one geocode simultaneously.
		
		// If there is a problem, log it; alert the user; and we are done.
		if (error || placemarks.count < 1) {
			
			if (error) {
				NSLog(@"Geocode Error: %@ %@", error.localizedDescription, error.userInfo);
			} else if (placemarks.count < 1) {
				NSLog(@"Geocode Error: No placemarks for address string: %@", addressString);
			}
			
			[Util presentOKAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Cannot geocode address: %@", addressString]];
			
			return;
		}
		
		// Use first placemark resolved from address as location
		CLPlacemark* placemark = placemarks[0];
		[self updateLocationWithPlacemark:placemark andRideLocationType:rideLocationType];
		NSLog(@"Geocode location: %@", placemark.location);
		NSLog(@"Geocode locality: %@", placemark.locality);
		NSLog(@"Geocode address: %@", placemark.addressDictionary);

		// Try to recalculate main route
		[self tryUpdateMainRouteWithSender:sender]; // async
		
		// Persist and notify
		[Util saveManagedObjectContext];
		[self postNotificationUpdatedWithSender:sender andUpdatedLocationStart:(rideLocationType == RideLocationType_Start) andUpdatedLocationEnd:(rideLocationType == RideLocationType_End)];
		[self.teamAssigned postNotificationUpdatedWithSender:sender];
		NSLog(@"Ride: %@", self);
	}];
}


/*
 Calculate ride main route, asynchronously
 */
- (void)tryUpdateMainRouteWithSender:(id)sender {

	// If cannot get main directions request, we are done
	MKDirectionsRequest* directionsRequest = [self getMainDirectionsRequest];
	if (!directionsRequest) return;
	
	// Update main route duration, distance, and polyline with directions
	MKDirections* directions = [[MKDirections alloc] initWithRequest:directionsRequest];
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse* response, NSError* error) {
		
		// NOTE: Completion block executes on main thread
		// NOTE: Run only one directions calculation simultaneously on this object
		if (error) {
			NSLog(@"Directions Error: %@ %@", error.localizedDescription, error.userInfo);
			return;
		}
		
		// Use first directions route as main
		// NOTE: Should be exactly 1, since we did not request alternate routes
		MKRoute* route = response.routes.firstObject;
		self.routeMainDuration = [NSNumber numberWithDouble:route.expectedTravelTime]; // seconds
		self.routeMainDistance = [NSNumber numberWithDouble:route.distance]; // meters
		self.routeMainPolyline = route.polyline;
		NSLog(@"Main Duration: %.0f sec -> %.2f min", route.expectedTravelTime, route.expectedTravelTime / (NSTimeInterval)SECONDS_PER_MINUTE);
		NSLog(@"Main Distance: %.0f m -> %.2f km", route.distance, route.distance / (CLLocationDistance)METERS_PER_KILOMETER);
		NSLog(@"Main Polyline: %@", route.polyline);
	
		// Try to recalculate prep routes for team assigned, if any
		[self.teamAssigned tryUpdateAssignedRideRoutesWithSender:sender]; // async
		
		// Persist to store and notify
		[Util saveManagedObjectContext];
		[self postNotificationUpdatedWithSender:sender];
		[self.teamAssigned postNotificationUpdatedWithSender:sender];
		NSLog(@"Ride: %@", self);
	}];
}


/*
 Calculate ride prep route, asynchronously
 */
- (void)tryUpdatePrepRouteWithLatitude:(NSNumber*)latitude andLongitude:(NSNumber*)longitude andSender:(id)sender {
	
	// Capture prep location
	self.locationPrepLatitude = latitude;
	self.locationPrepLongitude = longitude;
	
	// If cannot get prep directions request, we are done
	MKDirectionsRequest* directionsRequest = [self getPrepDirectionsRequest];
	if (!directionsRequest) return;
	
	// Update prep route duration, distance, and polyline with directions
	MKDirections* directions = [[MKDirections alloc] initWithRequest:directionsRequest];
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse* response, NSError* error) {
		
		// NOTE: Completion block executes on main thread
		// NOTE: Run only one directions calculation simultaneously on this object
		if (error) {
			NSLog(@"Directions Error: %@ %@", error.localizedDescription, error.userInfo);
			return;
		}
		
		// User first directions route as prep
		// NOTE: Should be exactly 1, since we did not request alternate routes
		MKRoute* route = response.routes.firstObject;
		self.routePrepDuration = [NSNumber numberWithDouble:route.expectedTravelTime]; // seconds
		self.routePrepDistance = [NSNumber numberWithDouble:route.distance]; // meters
		self.routePrepPolyline = route.polyline;
		NSLog(@"Prep Duration: %.0f sec -> %.2f min", route.expectedTravelTime, route.expectedTravelTime / (NSTimeInterval)SECONDS_PER_MINUTE);
		NSLog(@"Prep Distance: %.0f m -> %.2f km", route.distance, route.distance / (CLLocationDistance)METERS_PER_KILOMETER);
		NSLog(@"Prep Polyline: %@", route.polyline);

		// Persist to store and notify
		[Util saveManagedObjectContext];
		[self postNotificationUpdatedWithSender:sender];
		[self.teamAssigned postNotificationUpdatedWithSender:sender];
		NSLog(@"Ride: %@", self);
	}];
}


/*
 Calculate ride route duration, asynchronously
 
 NOTE: Just ETA part of directions
 */
/*
- (void)tryUpdateMainRouteDurationWithSender:(id)sender {
	
	// If cannot get directions request, we are done
	MKDirectionsRequest* directionsRequest = [self getMainDirectionsRequest];
	if (!directionsRequest) return;
	
	// Update ride duration with ETA for route
	MKDirections* directions = [[MKDirections alloc] initWithRequest:directionsRequest];
	[directions calculateETAWithCompletionHandler:^(MKETAResponse* response, NSError* error) {
		
		// NOTE: Completion block executes on main thread
		// NOTE: Run only one ETA calculation simultaneously on this object
		if (error) {
			NSLog(@"ETA Error: %@ %@", error.localizedDescription, error.userInfo);
			return;
		}
		
		// Grab expected travel time
		self.routeMainDuration = [NSNumber numberWithDouble:response.expectedTravelTime]; // seconds
		NSLog(@"ETA: %.0f sec -> %.2f min", response.expectedTravelTime, response.expectedTravelTime / (NSTimeInterval)SECONDS_PER_MINUTE);
		
		// Persist to store and notify
		[Util saveManagedObjectContext];
		[self postNotificationUpdatedWithSender:sender];
		[self.teamAssigned postNotificationUpdatedWithSender:sender];
		NSLog(@"Ride: %@", self);
	}];
}
*/


- (MKDirectionsRequest*)getMainDirectionsRequest {
	
	return [Ride directionsRequestWithStartDate:self.dateTimeStart
							   andStartLatitude:self.locationStartLatitude
							  andStartLongitude:self.locationStartLongitude
								 andEndLatitude:self.locationEndLatitude
								andEndLongitude:self.locationEndLongitude];
}


- (MKDirectionsRequest*)getPrepDirectionsRequest {
	
	// NOTE: Ride start time good enough here
	return [Ride directionsRequestWithStartDate:self.dateTimeStart
							   andStartLatitude:self.locationPrepLatitude
							  andStartLongitude:self.locationPrepLongitude
								 andEndLatitude:self.locationStartLatitude
								andEndLongitude:self.locationStartLongitude];
}


- (void)clearMainRoute {
	
	self.routeMainDuration = nil;
	self.routeMainDistance = nil;
	self.routeMainPolyline = nil;
}


- (void)clearPrepRoute {
	
	self.routePrepDuration = nil;
	self.routePrepDistance = nil;
	self.routePrepPolyline = nil;
}


- (NSString*)getPassengerName {
	
	// If first or last name is empty return other one
	if (!self.passengerNameLast || self.passengerNameLast.length <= 0) return self.passengerNameFirst;
	if (!self.passengerNameFirst || self.passengerNameFirst.length <= 0) return self.passengerNameLast;
	
	// Combine first and last name
	return [NSString stringWithFormat:@"%@ %@", self.passengerNameFirst, self.passengerNameLast];
}


- (NSString*)getTitle {
	
	NSString* passengerName = [self getPassengerName];
	
	return passengerName.length > 0 ? passengerName : RIDE_TITLE_DEFAULT;
}


- (NSDate*)getRouteDateTimeEnd {

	return self.dateTimeStart && self.routeMainDuration ? [NSDate dateWithTimeInterval:self.routeMainDuration.doubleValue sinceDate:self.dateTimeStart] : nil;
}


- (NSNumber*)latitudeWithRideLocationType:(RideLocationType)rideLocationType {

	return rideLocationType == RideLocationType_End ? self.locationEndLatitude : self.locationStartLatitude;
}


- (NSNumber*)longitudeWithRideLocationType:(RideLocationType)rideLocationType {
	
	return rideLocationType == RideLocationType_End ? self.locationEndLongitude : self.locationStartLongitude;
}


- (MKPolyline*)polylineWithRideRouteType:(RideRouteType)rideRouteType {
	
	switch (rideRouteType) {
			
		case RideRouteType_Main:
			return self.routeMainPolyline;
			
		case RideRouteType_Prep:
			return self.routePrepPolyline;
			
		default:
		case RideRouteType_None:
		case RideRouteType_Wait:
			return nil;
	}
}


- (NSTimeInterval)durationWithRideRouteType:(RideRouteType)rideRouteType {
	
	switch (rideRouteType) {
			
		case RideRouteType_Main:
			return self.routeMainDuration.doubleValue;
			
		case RideRouteType_Prep:
			return self.routePrepDuration.doubleValue;
			
		case RideRouteType_Wait: {
			
			// Accumulate wait duration up to current ride, inclusive
			NSTimeInterval duration = self.routePrepDuration.doubleValue; // seconds
			for (Ride* rideAssigned in [self.teamAssigned getSortedRidesAssigned]) {
				
				if (rideAssigned == self) break;
				
				duration += rideAssigned.routePrepDuration.doubleValue + rideAssigned.routeMainDuration.doubleValue;
			}
			
			return duration;
		}
			
		default:
		case RideRouteType_None:
			return -1;
	}
}


- (CLLocationDistance)distanceWithRideRouteType:(RideRouteType)rideRouteType {

	switch (rideRouteType) {
			
		case RideRouteType_Main:
			return self.routeMainDistance.doubleValue;
			
		case RideRouteType_Prep:
			return self.routePrepDistance.doubleValue;
			
		case RideRouteType_Wait: {
			
			// Accumulate wait distance up to current ride, inclusive
			CLLocationDistance distance = self.routePrepDistance.doubleValue; // meters
			for (Ride* rideAssigned in [self.teamAssigned getSortedRidesAssigned]) {
				
				if (rideAssigned == self) break;
				
				distance += rideAssigned.routePrepDistance.doubleValue + rideAssigned.routeMainDistance.doubleValue;
			}
			
			return distance;
		}
			
		default:
		case RideRouteType_None:
			return -1;
	}
}


#
# pragma mark Class Helpers
#


+ (void)tryCreateRideWithAddressString:(NSString*)addressString andGeocoder:(CLGeocoder*)geocoder andSender:(id)sender {
	
	addressString = [addressString trimAll];
	
	CLCircularRegion* jurisdictionRegion = [[CLCircularRegion alloc] initWithCenter:JURISDICTION_COORDINATE radius:JURISDICTION_SEARCH_RADIUS identifier:@"ORN Jurisdication Region"];
	
	[geocoder geocodeAddressString:addressString inRegion:jurisdictionRegion completionHandler:^(NSArray* placemarks, NSError* error) {
		
		// NOTE: Completion block executes on main thread
		// NOTE: Run only one geocode simultaneously on this object
		
		// If there is a problem, log it; alert the user; and we are done.
		if (error || placemarks.count < 1) {
			
			if (error) {
				NSLog(@"Geocode Error: %@ %@", error.localizedDescription, error.userInfo);
			} else if (placemarks.count < 1) {
				NSLog(@"Geocode Error: No placemarks for address string: %@", addressString);
			}
			
			[Util presentOKAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Cannot geocode address: %@", addressString]];
			
			return;
		}
		
		// Use first placemark as start location for new ride
		CLPlacemark* placemark = placemarks[0];
		Ride* ride = [Ride rideWithManagedObjectContext:[Util managedObjectContext] andDateTime:[NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL] andPlacemark:placemark andRideLocationType:RideLocationType_Start];
		NSLog(@"Geocode location: %@", placemark.location);
		NSLog(@"Geocode locality: %@", placemark.locality);
		NSLog(@"Geocode address: %@", placemark.addressDictionary);
		
		// Persist to store and notify
		[Util saveManagedObjectContext];
		[ride postNotificationCreatedWithSender:sender];
		NSLog(@"Ride: %@", ride);
	}];
}


//+ (NSString*)stringFromStatus:(RideStatus)status {
//	
//	switch (status) {
//			
//		case RideStatus_New:
//			return RIDE_STATUS_STRING_NEW;
//			
//		case RideStatus_Confirmed:
//			return RIDE_STATUS_STRING_CONFIRMED;
//			
//		case RideStatus_Progressing:
//			return RIDE_STATUS_STRING_PROGRESSING;
//			
//		case RideStatus_Completed:
//			return RIDE_STATUS_STRING_COMPLETED;
//
//		case RideStatus_Cancelled:
//			return RIDE_STATUS_STRING_CANCELLED;
//			
//		default:
//		case RideStatus_None:
//			return RIDE_STATUS_STRING_NONE;
//	}
//}
//
//
//+ (RideStatus)statusFromString:(NSString*)statusString {
//	
//	if (!statusString || statusString.length <= 0) return RideStatus_None;
//	
//	if ([statusString isEqualToString:RIDE_STATUS_STRING_NEW]) return RideStatus_New;
//	if ([statusString isEqualToString:RIDE_STATUS_STRING_CONFIRMED]) return RideStatus_Confirmed;
//	if ([statusString isEqualToString:RIDE_STATUS_STRING_PROGRESSING]) return RideStatus_Progressing;
//	if ([statusString isEqualToString:RIDE_STATUS_STRING_COMPLETED]) return RideStatus_Completed;
//	
//	if ([statusString isEqualToString:RIDE_STATUS_STRING_CANCELLED]) return RideStatus_Cancelled;
//	
//	return RideStatus_None;
//}


+ (MKDirectionsRequest*)directionsRequestWithStartDate:(NSDate*)startDate
									  andStartLatitude:(NSNumber*)startLatitude
									 andStartLongitude:(NSNumber*)startLongitude
										andEndLatitude:(NSNumber*)endLatitude
									   andEndLongitude:(NSNumber*)endLongitude {
	
	if (!startDate || !startLatitude || !startLongitude || !endLatitude || !endLongitude) return nil;
	
	// Create placemarks for ride start and end locations
	MKPlacemark* startPlacemark = [Util placemarkWithLatitude:startLatitude.doubleValue andLongitude:startLongitude.doubleValue];
	MKPlacemark* endPlacemark = [Util placemarkWithLatitude:endLatitude.doubleValue andLongitude:endLongitude.doubleValue];
	
	// Create directions request for route by car for ride start time
	return [Util directionsRequestWithDepartureDate:startDate andSourcePlacemark:startPlacemark andDestinationPlacemark:endPlacemark];
}


+ (NSString*)getAddressStringWithPlacemark:(CLPlacemark*)placemark {
	
	NSString* street = placemark.addressDictionary[@"Street"];
	NSString* city = placemark.addressDictionary[@"City"];
	
	if (street && city) return [NSString stringWithFormat:@"%@, %@", street, city];
	
	return [NSString stringWithFormat:@"%@ (%.3f,%.3f)", placemark.name, placemark.location.coordinate.latitude, placemark.location.coordinate.longitude];
	
	//	return ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
}


@end
