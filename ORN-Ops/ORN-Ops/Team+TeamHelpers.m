//
//  Team+TeamHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-03.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "Team+TeamHelpers.h"


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
# pragma mark Helpers
#


- (NSString*)getTeamTitle {

	// If name or members are empty, return other one
	if (!self.name || self.name.length <= 0) return self.members;
	if (!self.members || self.members.length <= 0) return self.name;
	
	// Combine name and members
	return [NSString stringWithFormat:@"%@: %@", self.name, self.members];
}


@end
