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

#define TEAM_UPDATED_NOTIFICATION_NAME					@"teamUpdated"
#define TEAM_UPDATED_LOCATION_NOTIFICATION_KEY			@"teamUpdatedLocation"
#define TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY	@"teamUpdatedRidesAssigned"

#
# pragma mark - Interface
#

@interface Team (TeamHelpers)

#
# pragma mark Initializers
#

+ (instancetype)teamWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

#
# pragma mark Helpers
#

- (NSString*)getTeamTitle;

@end
