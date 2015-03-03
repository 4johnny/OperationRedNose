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

#
# pragma mark - Interface
#

@interface Team (TeamHelpers)

#
# pragma mark Initializers
#

+ (instancetype)teamWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
