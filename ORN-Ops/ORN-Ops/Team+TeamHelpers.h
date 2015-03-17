//
//  Team+TeamHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-03.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "Team.h"

#
# pragma mark - Constants
#

#define TEAM_ENTITY_NAME	@"Team"
#define TEAM_TITLE_DEFAULT	@"(Team)"
#define TEAM_TITLE_NONE		@"-None-"

#
# pragma mark - Interface
#

@interface Team (TeamHelpers)

#
# pragma mark Initializers
#

+ (instancetype)teamWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

#
# pragma mark Notifications
#

+ (void)addCreatedObserver:(id)observer withSelector:(SEL)selector;
+ (void)addUpdatedObserver:(id)observer withSelector:(SEL)selector;

+ (Team*)teamFromNotification:(NSNotification*)notification;
+ (BOOL)isUpdatedLocationFromNotification:(NSNotification*)notification;
+ (BOOL)isUpdatedRidesAssignedFromNotification:(NSNotification*)notification;

- (void)postNotificationCreatedWithSender:(id)sender;
- (void)postNotificationUpdatedWithSender:(id)sender;

- (void)postNotificationUpdatedWithSender:(id)sender andUpdatedLocation:(BOOL)updatedLocation;
- (void)postNotificationUpdatedWithSender:(id)sender andUpdatedRidesAssigned:(BOOL)updatedRidesAssigned;

#
# pragma mark Helpers
#

- (NSString*)getTitle;

@end
