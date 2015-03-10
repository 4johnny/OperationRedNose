//
//  Ride+RideHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "Ride+RideHelpers.h"
#import "Team+TeamHelpers.h"


#
# pragma mark - Implementation
#


@implementation Ride (RideHelpers)


#
# pragma mark Initializers
#

- (instancetype)initWithEntity:(NSEntityDescription*)entityDescription
insertIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
   withLocationStartCoordinate:(CLLocationCoordinate2D)locationStartCoordinate
	   andLocationStartAddress:(NSString*)locationStartAddress
		  andLocationStartCity:(NSString*)locationStartCity {
	
	self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];
	if (self) {
		
		self.dateTimeStart = [NSDate date];
		
		self.locationStartLatitude = [NSNumber numberWithDouble:locationStartCoordinate.latitude];
		self.locationStartLongitude = [NSNumber numberWithDouble:locationStartCoordinate.longitude];
		self.locationStartAddress = locationStartAddress;
		self.locationStartCity = locationStartCity;
	}
	
	return self;
}


+ (instancetype)rideWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
				  andLocationStartCoordinate:(CLLocationCoordinate2D)locationStartCoordinate
					 andLocationStartAddress:(NSString*)locationStartAddress
						andLocationStartCity:(NSString*)locationStartCity {
	
	return [[Ride alloc] initWithEntity:[NSEntityDescription entityForName:RIDE_ENTITY_NAME inManagedObjectContext:managedObjectContext]
		 insertIntoManagedObjectContext:managedObjectContext
			withLocationStartCoordinate:locationStartCoordinate
				andLocationStartAddress:locationStartAddress
				   andLocationStartCity:locationStartCity];
}


+ (instancetype)rideWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext andPlacemark:(CLPlacemark*)placemark {
	
	return [Ride rideWithManagedObjectContext:managedObjectContext
				   andLocationStartCoordinate:placemark.location.coordinate
					  andLocationStartAddress:[Ride addressStringWithPlacemark:placemark]
						 andLocationStartCity:placemark.locality];
}


+ (NSString*)addressStringWithPlacemark:(CLPlacemark*)placemark {
	
	NSString* street = placemark.addressDictionary[@"Street"];
	NSString* city = placemark.addressDictionary[@"City"];
	
	if (street && city) return [NSString stringWithFormat:@"%@, %@", street, city];
	
	return [NSString stringWithFormat:@"%@ (%.3f,%.3f)", placemark.name, placemark.location.coordinate.latitude, placemark.location.coordinate.longitude];
	
	//	return ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
}


#
# pragma mark Helpers
#


- (NSString*)getPassengerName {
	
	// If first or last name is empty return other one
	if (!self.passengerNameLast || self.passengerNameLast.length <= 0) return self.passengerNameFirst;
	if (!self.passengerNameFirst || self.passengerNameFirst.length <= 0) return self.passengerNameLast;
	
	// Combine first and last name
	return [NSString stringWithFormat:@"%@ %@", self.passengerNameFirst, self.passengerNameLast];
}


- (MKDirectionsRequest*)getDirectionsRequest {
	
	if (!self.locationStartLatitude || !self.locationStartLongitude ||
		!self.locationEndLatitude || !self.locationEndLongitude) return nil;
	
	// Create placemarks for ride start and end locations
	MKPlacemark* startPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.locationStartLatitude.doubleValue, self.locationStartLongitude.doubleValue) addressDictionary:nil];
	MKPlacemark* endPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.locationEndLatitude.doubleValue, self.locationEndLongitude.doubleValue) addressDictionary:nil];
	
	// Create directions request for route by car for given time of day
	MKDirectionsRequest* directionsRequest = [[MKDirectionsRequest alloc] init];
	directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
	directionsRequest.destination = [[MKMapItem alloc] initWithPlacemark:endPlacemark];
	directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
	directionsRequest.departureDate = self.dateTimeStart;
	directionsRequest.requestsAlternateRoutes = NO;
	
	return directionsRequest;
}


// Calculate ride duration and end time asynchronously
- (void)calculateDateTimeEnd {
	
	// If cannot get directions request, we are done with this ride
	MKDirectionsRequest* directionsRequest = self.getDirectionsRequest;
	if (!directionsRequest) return;
	
	// Update ride duration and end time with ETA calculation for route
	MKDirections* directions = [[MKDirections alloc] initWithRequest:directionsRequest];
	[directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
		
		// NOTES: Completion block executes on main thread. Do not run more than one ETA calculation simultaneously on this object.
		if (error) {
			NSLog(@"ETA Error: %@ %@", error.localizedDescription, error.userInfo);
			return;
		}
		
		// Expected travel time calculated successfully, so store it
		self.duration = [NSNumber numberWithDouble:response.expectedTravelTime]; // seconds
		NSLog(@"ETA: %.0f sec -> %.2f min", response.expectedTravelTime, response.expectedTravelTime / (double)SECONDS_PER_MINUTE);
		
		// Determine end time by adding ETA seconds to start time
		self.dateTimeEnd = [NSDate dateWithTimeInterval:response.expectedTravelTime sinceDate:self.dateTimeStart];
		
		// Notify that ride and assigned team have updated
		[[NSNotificationCenter defaultCenter] postNotificationName:RIDE_UPDATED_NOTIFICATION_NAME object:self userInfo:@{RIDE_ENTITY_NAME:self}];
		if (self.teamAssigned) {
			[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:self userInfo:@{TEAM_ENTITY_NAME:self.teamAssigned}];
		}
	}];
}


+ (NSString*)stringFromStatus:(RideStatus)status {
	
	switch (status) {
			
		case RideStatus_New:
			return RIDE_STATUS_STRING_NEW;
			
		case RideStatus_Confirmed:
			return RIDE_STATUS_STRING_CONFIRMED;
			
		case RideStatus_Progressing:
			return RIDE_STATUS_STRING_PROGRESSING;
			
		case RideStatus_Completed:
			return RIDE_STATUS_STRING_COMPLETED;

		case RideStatus_Cancelled:
			return RIDE_STATUS_STRING_CANCELLED;
			
		default:
		case RideStatus_None:
			return RIDE_STATUS_STRING_NONE;
	}
}


+ (RideStatus)statusFromString:(NSString*)statusString {
	
	if (!statusString || statusString.length <= 0) return RideStatus_None;
	
	if ([statusString isEqualToString:RIDE_STATUS_STRING_NEW]) return RideStatus_New;
	if ([statusString isEqualToString:RIDE_STATUS_STRING_CONFIRMED]) return RideStatus_Confirmed;
	if ([statusString isEqualToString:RIDE_STATUS_STRING_PROGRESSING]) return RideStatus_Progressing;
	if ([statusString isEqualToString:RIDE_STATUS_STRING_COMPLETED]) return RideStatus_Completed;
	
	if ([statusString isEqualToString:RIDE_STATUS_STRING_CANCELLED]) return RideStatus_Cancelled;
	
	return RideStatus_None;
}


@end
