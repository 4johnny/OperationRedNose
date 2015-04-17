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
#define TEAM_UPDATED_NOTIFICATION_NAME					@"teamUpdated"

#define TEAM_UPDATED_LOCATION_NOTIFICATION_KEY			@"teamUpdatedLocation"
#define TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY	@"teamUpdatedRidesAssigned"


#
# pragma mark - Implementation
#


@implementation Team (TeamHelpers)


#
# pragma mark Initializers
#


+ (instancetype)teamWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	return [[Team alloc] initWithEntity:[NSEntityDescription entityForName:TEAM_ENTITY_NAME inManagedObjectContext:managedObjectContext]
		 insertIntoManagedObjectContext:managedObjectContext];
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


+ (Team*)teamFromNotification:(NSNotification*)notification {
	
	return notification.userInfo[TEAM_ENTITY_NAME];
}


+ (BOOL)isUpdatedLocationFromNotification:(NSNotification*)notification {

	return [Util isValueFromNotification:notification withKey:TEAM_UPDATED_LOCATION_NOTIFICATION_KEY];
}


+ (BOOL)isUpdatedRidesAssignedFromNotification:(NSNotification*)notification {
	
	return [Util isValueFromNotification:notification withKey:TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY];
}


- (void)postNotificationCreatedWithSender:(id)sender  {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_CREATED_NOTIFICATION_NAME object:sender userInfo:
	 @{TEAM_ENTITY_NAME : self,
	   TEAM_UPDATED_LOCATION_NOTIFICATION_KEY : @YES
	   }];
}


- (void)postNotificationUpdatedWithSender:(id)sender {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:sender userInfo:@{TEAM_ENTITY_NAME : self}];
}


- (void)postNotificationUpdatedWithSender:(id)sender andUpdatedLocation:(BOOL)updatedLocation {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:sender userInfo:
	 @{TEAM_ENTITY_NAME : self,
	   TEAM_UPDATED_LOCATION_NOTIFICATION_KEY : [NSNumber numberWithBool:updatedLocation]
	   }];
}


- (void)postNotificationUpdatedWithSender:(id)sender andUpdatedRidesAssigned:(BOOL)updatedRidesAssigned {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:sender userInfo:
	 @{TEAM_ENTITY_NAME : self,
	   TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY : [NSNumber numberWithBool:updatedRidesAssigned]
	   }];
}


- (void)postNotificationUpdatedWithSender:(id)sender andUpdatedLocation:(BOOL)updatedLocation andUpdatedRidesAssigned:(BOOL)updatedRidesAssigned {

	[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:sender userInfo:
	 @{TEAM_ENTITY_NAME : self,
	   TEAM_UPDATED_LOCATION_NOTIFICATION_KEY : [NSNumber numberWithBool:updatedLocation],
	   TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY : [NSNumber numberWithBool:updatedRidesAssigned]
	   }];
}


#
# pragma mark Instance Helpers
#


/*
 Calculate route for team per assigned rides, asynchronously
 */
- (void)tryUpdateAssignedRideRoutesWithSender:(id)sender {
	
	NSNumber* sourceLatitude = self.locationCurrentLatitude; // Maybe nil
	NSNumber* sourceLongitude = self.locationCurrentLongitude; // Maybe nil
	
	for (Ride* rideAssigned in [self getSortedRidesAssigned]) {

		[rideAssigned tryUpdatePrepRouteWithLatitude:sourceLatitude andLongitude:sourceLongitude andSender:sender]; // async

		// Best effort to determine source location for next prep route
		
		if (rideAssigned.locationEndLatitude && rideAssigned.locationEndLongitude) {
			
			sourceLatitude = rideAssigned.locationEndLatitude;
			sourceLongitude = rideAssigned.locationEndLongitude;
			continue;
		}
		
		if (rideAssigned.locationStartLatitude && rideAssigned.locationStartLongitude) {
			
			sourceLatitude = rideAssigned.locationStartLatitude;
			sourceLongitude = rideAssigned.locationStartLongitude;
			continue;
		}
	}
}


- (NSString*)getTitle {

	if (self.name.length > 0 && self.members.length == 0) return self.name;
	if (self.name.length == 0 && self.members.length > 0) return self.members;
	if (self.name.length > 0 && self.members.length > 0) return [NSString stringWithFormat:@"%@: %@", self.name, self.members];

	return TEAM_TITLE_DEFAULT;
}


- (NSArray*)getSortedRidesAssigned {

	return [self.ridesAssigned sortedArrayUsingDescriptors:
			@[
			  [NSSortDescriptor sortDescriptorWithKey:RIDE_FETCH_SORT_KEY1 ascending:RIDE_FETCH_SORT_ASCENDING],
			  [NSSortDescriptor sortDescriptorWithKey:RIDE_FETCH_SORT_KEY2 ascending:RIDE_FETCH_SORT_ASCENDING]
			  ]];
}


- (NSTimeInterval)assignedDuration {
	
	// Accumulate duration for all assigned rides
	NSTimeInterval duration = 0; // seconds
	for (Ride* rideAssigned in self.ridesAssigned) {

		duration += rideAssigned.routePrepDuration.doubleValue + rideAssigned.routeMainDuration.doubleValue;
	}

	return duration;
}


- (CLLocationDistance)assignedDistance {

	// Accumulate distance for all assigned rides
	CLLocationDistance distance = 0; // meters
	for (Ride* rideAssigned in self.ridesAssigned) {
		
		distance += rideAssigned.routePrepDistance.doubleValue + rideAssigned.routeMainDistance.doubleValue;
	}
	
	return distance;
}


@end
