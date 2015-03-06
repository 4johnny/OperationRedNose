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

#define TEAM_ENTITY_NAME							@"Team"

#define TEAM_UPDATED_NOTIFICATION_NAME				@"teamUpdated"
#define TEAM_DID_LOCATION_CHANGE_NOTIFICATION_KEY	@"teamDidLocationChange"


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
