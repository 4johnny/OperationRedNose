//
//  Team+TeamHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-03.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "Team+TeamHelpers.h"
#import "Ride+RideHelpers.h"


#
# pragma mark - Constants
#

#define TEAM_CREATED_NOTIFICATION_NAME					@"teamCreated"
#define TEAM_DELETED_NOTIFICATION_NAME					@"teamDeleted"
#define TEAM_UPDATED_NOTIFICATION_NAME					@"teamUpdated"

#define TEAM_UPDATED_LOCATION_NOTIFICATION_KEY			@"teamUpdatedLocation"
#define TEAM_UPDATED_MASCOT_NOTIFICATION_KEY			@"teamUpdatedMascot"
#define TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY	@"teamUpdatedRidesAssigned"


#
# pragma mark - Implementation
#


@implementation Team (TeamHelpers)


#
# pragma mark Initializers
#


- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	self = [super initWithEntity:[NSEntityDescription entityForName:TEAM_ENTITY_NAME inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	//	if (self) {
	//
	//	}
	return self;
}


- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel*)managedObjectModel {
	
	self = [super initWithEntity:managedObjectModel.entitiesByName[TEAM_ENTITY_NAME] insertIntoManagedObjectContext:nil];
	//	if (self) {
	//
	//	}
	return self;
}


+ (instancetype)teamWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	return [[Team alloc] initWithManagedObjectContext:managedObjectContext];
}


+ (instancetype)teamWithManagedObjectModel:(NSManagedObjectModel*)managedObjectModel {

	return [[Team alloc] initWithManagedObjectModel:managedObjectModel];
}


#
# pragma mark <ORNDataObject>
#


- (NSString*)getTitle {
	
	NSAssert(self.teamID, @"Team ID must exist");
	
	NSString* teamIDText = self.teamID.stringValue;
	
	if (teamIDText.length > 0 && self.members.length <= 0) return teamIDText;
	if (teamIDText.length <= 0 && self.members.length > 0) return self.members;
	if (teamIDText.length > 0 && self.members.length > 0) return [NSString stringWithFormat:@"%@: %@", self.teamID, self.members];
	
	return TEAM_TITLE_DEFAULT;
}


- (void)delete {
	
	if (self.isDeleted) return;
	
	// Remove any assigned rides, including route recalculations and notifications
	for (Ride* rideAssigned in [self.ridesAssigned mutableCopy]) {
		
		[rideAssigned assignTeam:nil withSender:self];
	}
	
	[self.managedObjectContext deleteObject:self];
	
	[self postNotificationDeletedWithSender:self];
}


#
# pragma mark Notifications
#


+ (void)addCreatedObserver:(id)observer withSelector:(SEL)selector {
	
	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:TEAM_CREATED_NOTIFICATION_NAME object:nil];
}


+ (void)addUpdatedObserver:(id)observer withSelector:(SEL)selector {
	
	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:TEAM_UPDATED_NOTIFICATION_NAME object:nil];
}


+ (void)addDeletedObserver:(id)observer withSelector:(SEL)selector {
	
	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:TEAM_DELETED_NOTIFICATION_NAME object:nil];
}


+ (Team*)teamFromNotification:(NSNotification*)notification {
	
	return notification.userInfo[TEAM_ENTITY_NAME];
}


+ (BOOL)isUpdatedLocationFromNotification:(NSNotification*)notification {

	return [Util isValueFromNotification:notification withKey:TEAM_UPDATED_LOCATION_NOTIFICATION_KEY];
}


+ (BOOL)isUpdatedMascotFromNotification:(NSNotification*)notification {
	
	return [Util isValueFromNotification:notification withKey:TEAM_UPDATED_MASCOT_NOTIFICATION_KEY];
}


+ (BOOL)isUpdatedRidesAssignedFromNotification:(NSNotification*)notification {
	
	return [Util isValueFromNotification:notification withKey:TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY];
}


- (void)postNotificationCreatedWithSender:(id)sender {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_CREATED_NOTIFICATION_NAME object:sender userInfo:
	 @{
	   TEAM_ENTITY_NAME : self,
	   TEAM_UPDATED_LOCATION_NOTIFICATION_KEY : @YES,
	   }];
}


- (void)postNotificationDeletedWithSender:(id)sender {	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_DELETED_NOTIFICATION_NAME object:sender userInfo:
	 @{
	   TEAM_ENTITY_NAME : self,
	   TEAM_UPDATED_LOCATION_NOTIFICATION_KEY : @YES,
	   }
	 ];
}


- (void)postNotificationUpdatedWithSender:(id)sender {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:sender userInfo:
	 @{
	   TEAM_ENTITY_NAME : self,
	   }
	 ];
}


- (void)postNotificationUpdatedWithSender:(id)sender
					   andUpdatedLocation:(BOOL)updatedLocation {

	[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:sender userInfo:
	 @{
	   TEAM_ENTITY_NAME : self,
	   TEAM_UPDATED_LOCATION_NOTIFICATION_KEY : @(updatedLocation),
	   }];
}


- (void)postNotificationUpdatedWithSender:(id)sender
					   andUpdatedLocation:(BOOL)updatedLocation
						 andUpdatedMascot:(BOOL)updatedMascot {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:sender userInfo:
	 @{
	   TEAM_ENTITY_NAME : self,
	   TEAM_UPDATED_LOCATION_NOTIFICATION_KEY : @(updatedLocation),
	   TEAM_UPDATED_MASCOT_NOTIFICATION_KEY : @(updatedMascot),
	   }];
}


- (void)postNotificationUpdatedWithSender:(id)sender
				  andUpdatedRidesAssigned:(BOOL)updatedRidesAssigned {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:sender userInfo:
	 @{
	   TEAM_ENTITY_NAME : self,
	   TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY : @(updatedRidesAssigned),
	   }
	 ];
}


- (void)postNotificationUpdatedWithSender:(id)sender
					   andUpdatedLocation:(BOOL)updatedLocation
				  andUpdatedRidesAssigned:(BOOL)updatedRidesAssigned {

	[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:sender userInfo:
	 @{
	   TEAM_ENTITY_NAME : self,
	   TEAM_UPDATED_LOCATION_NOTIFICATION_KEY : @(updatedLocation),
	   TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY : @(updatedRidesAssigned),
	   }
	 ];
}


#
# pragma mark Instance Helpers
#


- (void)updateCurrentLocationWithLatitudeNumber:(NSNumber*)latitude
							 andLongitudeNumber:(NSNumber*)longitude
									  andStreet:(NSString*)street
										andCity:(NSString*)city
									   andState:(NSString*)state
									 andAddress:(NSString*)address
										andTime:(NSDate*)time {

	self.locationCurrentLatitude = latitude;
	self.locationCurrentLongitude = longitude;
	self.locationCurrentStreet = street;
	self.locationCurrentCity = city;
	self.locationCurrentState = state;
	
	if (!address && (street && city)) {
		address = [NSString stringWithFormat:@"%@, %@", street, city];
	}
	self.locationCurrentAddress = address;
	
	if (!time && ((latitude && longitude) || (street && city) || (address))) {
		time = [NSDate date];
	}
	self.locationCurrentTime = time;
	
	// NOTE: Always manual for now
	self.locationCurrentIsManual = @YES;
}


- (void)updateCurrentLocationWithLatitude:(CLLocationDegrees)latitude
							 andLongitude:(CLLocationDegrees)longitude
								andStreet:(NSString*)street
								  andCity:(NSString*)city
								 andState:(NSString*)state
							   andAddress:(NSString*)address
								  andTime:(NSDate*)time {
	
	[self updateCurrentLocationWithLatitudeNumber:@(latitude)
							   andLongitudeNumber:@(longitude)
										andStreet:street
										  andCity:city
										 andState:state
									   andAddress:address
										  andTime:time];
}


- (void)updateCurrentLocationWithPlacemark:(CLPlacemark*)placemark {
	
	[self updateCurrentLocationWithLatitude:placemark.location.coordinate.latitude
							   andLongitude:placemark.location.coordinate.longitude
								  andStreet:[placemark getAddressStreet]
									andCity:placemark.locality
								   andState:[placemark getAddressState]
								 andAddress:[placemark getAddressString]
									andTime:nil];
}


- (void)clearCurrentLocation {
	
	[self updateCurrentLocationWithLatitudeNumber:nil andLongitudeNumber:nil andStreet:nil andCity:nil andState:nil andAddress:nil andTime:nil];
}


- (void)persistCurrentLocationWithSender:(id)sender {
	
	[Util saveManagedObjectContext];
	[self postNotificationUpdatedWithSender:sender andUpdatedLocation:YES];
	
	Ride* firstSortedActiveRideAssigned = [self getSortedActiveRidesAssigned].firstObject; // Maybe nil
	[firstSortedActiveRideAssigned postNotificationUpdatedWithSender:self];
	
	NSLog(@"Team: %@", self);
	
	// Try to recalculate prep route
	[firstSortedActiveRideAssigned tryUpdatePrepRouteWithLatitude:self.locationCurrentLatitude andLongitude:self.locationCurrentLongitude andIsFirst:YES andSender:self]; // async
}


/*
 Geocode given address string relative to jurisdiction, asynchronously
 */
- (void)tryUpdateCurrentLocationWithAddressString:(NSString*)addressString
									  andGeocoder:(CLGeocoder*)geocoder
										andSender:(id)sender {
	
	addressString = [addressString trimAll];
	
	CLCircularRegion* jurisdictionRegion = [[CLCircularRegion alloc] initWithCenter:JURISDICTION_COORDINATE radius:JURISDICTION_SEARCH_RADIUS identifier:@"ORN Jurisdication Region"];
	
	[geocoder geocodeAddressString:addressString inRegion:jurisdictionRegion completionHandler:^(NSArray<CLPlacemark*>* _Nullable placemarks, NSError* _Nullable error) {
		
		// NOTE: Completion block executes on main thread
		
		// If there is a problem, log it; alert the user; and we are done.
		if (error || placemarks.count < 1) {
			
			if (error) {
				NSLog(@"Geocode Error: %@ %@", error.localizedDescription, error.userInfo);
			} else if (placemarks.count < 1) {
				NSLog(@"Geocode Error: No placemarks for address string: %@", addressString);
			}
			
			return;
		}
		
		// Use first placemark resolved from address as location
		CLPlacemark* placemark = placemarks[0];
		[self updateCurrentLocationWithPlacemark:placemark];
		NSLog(@"Geocode location: %@", placemark.location);
		NSLog(@"Geocode locality: %@", placemark.locality);
		NSLog(@"Geocode address: %@", placemark.addressDictionary);
		
		// Persist and notify
		[self persistCurrentLocationWithSender:sender];
	}];
}


/*
 Calculate route for team per active assigned rides, asynchronously
 */
- (void)tryUpdateActiveAssignedRideRoutesWithSender:(id)sender {
	
	NSNumber* sourceLatitude = self.locationCurrentLatitude; // Maybe nil
	NSNumber* sourceLongitude = self.locationCurrentLongitude; // Maybe nil
	
	BOOL isFirst = YES;
	for (Ride* sortedActiveRideAssigned in [self getSortedActiveRidesAssigned]) {

		[sortedActiveRideAssigned tryUpdatePrepRouteWithLatitude:sourceLatitude andLongitude:sourceLongitude andIsFirst:isFirst andSender:sender]; // async
		if (isFirst) {
			isFirst = NO;
		}

		// Best effort to determine source location for next prep route
		
		if (sortedActiveRideAssigned.locationEndLatitude &&
			sortedActiveRideAssigned.locationEndLongitude) {
			
			sourceLatitude = sortedActiveRideAssigned.locationEndLatitude;
			sourceLongitude = sortedActiveRideAssigned.locationEndLongitude;
			continue;
		}
		
		if (sortedActiveRideAssigned.locationStartLatitude &&
			sortedActiveRideAssigned.locationStartLongitude) {
			
			sourceLatitude = sortedActiveRideAssigned.locationStartLatitude;
			sourceLongitude = sortedActiveRideAssigned.locationStartLongitude;
			continue;
		}
	}
}


- (CLLocationCoordinate2D)getLocationCurrentCoordinate {
	
	return CLLocationCoordinate2DMake(self.locationCurrentLatitude.doubleValue,
									  self.locationCurrentLongitude.doubleValue);
}


- (MKMapItem*)mapItemForCurrentLocation {
	
	if (!self.locationCurrentLatitude || !self.locationCurrentLongitude) return nil;
	
	NSDictionary<NSString*,NSString*>* addressDictionary =
	[CLPlacemark addressDictionary:nil
						withStreet:self.locationCurrentStreet
						   andCity:self.locationCurrentCity
						  andState:self.locationCurrentState
							andZIP:nil
						andCountry:CANADA_COUNTRY_NAME
					andCountryCode:CANADA_COUNTRY_CODE];
	
	MKPlacemark* placemark = [[MKPlacemark alloc] initWithCoordinate:[self getLocationCurrentCoordinate] addressDictionary:addressDictionary];
	
	return [[MKMapItem alloc] initWithPlacemark:placemark];
}


- (NSString*)getStatusText {

	NSMutableString* status = [NSMutableString string];
	
	if (!self.isActive.boolValue) {
		[status appendString:@"Inactive"];
	}
	if (self.isMascot.boolValue) {
		
		if (status.length > 0) {
			[status appendString:@","];
		}
		[status appendString:@"Mascot"];
	}

	return status;
}


- (NSSet<Ride*>*)getActiveRidesAssigned {
	
	if (self.ridesAssigned.count <= 0) return self.ridesAssigned;
	
	NSSet<Ride*>* activeRidesAssigned = [self.ridesAssigned filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Ride* _Nonnull ride, NSDictionary<NSString*,id>* _Nullable bindings) {
		
		return [ride isActive];
	}]];
	
	return activeRidesAssigned;
}


- (NSArray<Ride*>*)getSortedActiveRidesAssigned {

	if (!self.ridesAssigned) return nil;
	
	NSSet<Ride*>* activeRidesAssigned = [self getActiveRidesAssigned];
	if (activeRidesAssigned.count <= 0) return @[];
	
	NSArray<Ride*>* sortedActiveRidesAssigned =
	[activeRidesAssigned sortedArrayUsingDescriptors:
	 @[
	   [NSSortDescriptor sortDescriptorWithKey:RIDE_FETCH_SORT_KEY1 ascending:RIDE_FETCH_SORT_ASC1],
	   [NSSortDescriptor sortDescriptorWithKey:RIDE_FETCH_SORT_KEY2 ascending:RIDE_FETCH_SORT_ASC2],
	   ]];

	return sortedActiveRidesAssigned;
}


- (NSTimeInterval)getDurationWithSortedActiveRidesAssigned:(NSArray<Ride*>*)sortedActiveRidesAssigned {
	
	// NOTE: Accept assigned rides as parm to avoid recalculating repeatedly
	
	if (sortedActiveRidesAssigned.count <= 0) {
		
		sortedActiveRidesAssigned = [self getSortedActiveRidesAssigned];
	}
	
	// Accumulate duration for all active rides assigned
	NSTimeInterval duration = 0; // seconds
	BOOL isFirst = YES;
	for (Ride* sortedActiveRideAssigned in sortedActiveRidesAssigned) {

		duration += sortedActiveRideAssigned.routePrepDuration.doubleValue;
		
		// Skip main route for first ride if transporting
		if (!isFirst || ![sortedActiveRideAssigned isTransporting]) {
			
			duration += sortedActiveRideAssigned.routeMainDuration.doubleValue;
		}
		
		if (isFirst) {
			isFirst = NO;
		}
	}

	return duration;
}


- (CLLocationDistance)getDistanceWithSortedActiveRidesAssigned:(NSArray<Ride*>*)sortedActiveRidesAssigned {

	// NOTE: Accept assigned rides as parm to avoid recalculating repeatedly
	
	if (sortedActiveRidesAssigned.count <= 0) {
		
		sortedActiveRidesAssigned = [self getSortedActiveRidesAssigned];
	}
	
	// Accumulate distance for all active rides assigned
	CLLocationDistance distance = 0; // meters
	BOOL isFirst = YES;
	for (Ride* sortedActiveRideAssigned in sortedActiveRidesAssigned) {
		
		distance += sortedActiveRideAssigned.routePrepDistance.doubleValue;
		
		// Skip main route for first ride if transporting
		if (!isFirst || ![sortedActiveRideAssigned isTransporting]) {
			
			distance += sortedActiveRideAssigned.routeMainDistance.doubleValue;
		}
		
		if (isFirst) {
			isFirst = NO;
		}
	}
	
	return distance;
}


- (NSDecimalNumber*)getDonationsAssigned {
	
	// Accumulate donations for all rides assigned
	NSDecimalNumber* donations = [NSDecimalNumber zero] ; // CAD$
	for (Ride* rideAssigned in self.ridesAssigned) {
		
		if (!rideAssigned.donationAmount) continue;
		
		donations = [donations decimalNumberByAdding:rideAssigned.donationAmount];
	}
	
	return donations;
}


@end
