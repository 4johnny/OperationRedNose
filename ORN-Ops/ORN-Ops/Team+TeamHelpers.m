//
//  Team+TeamHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-03.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "Team+TeamHelpers.h"

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
	   TEAM_UPDATED_LOCATION_NOTIFICATION_KEY : [NSNumber numberWithBool:YES]
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


#
# pragma mark Helpers
#


- (NSString*)getTitle {

	if (self.name.length > 0 && self.members.length == 0) return self.name;
	if (self.name.length == 0 && self.members.length > 0) return self.members;
	if (self.name.length > 0 && self.members.length > 0) return [NSString stringWithFormat:@"%@: %@", self.name, self.members];

	return TEAM_TITLE_DEFAULT;
}


@end
