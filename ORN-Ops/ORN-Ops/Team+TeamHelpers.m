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


- (NSString*)getTitle {

	if (self.name.length > 0 && self.members.length == 0) return self.name;
	if (self.name.length == 0 && self.members.length > 0) return self.members;
	if (self.name.length > 0 && self.members.length > 0) return [NSString stringWithFormat:@"%@: %@", self.name, self.members];

	return TEAM_TITLE_DEFAULT;
}


@end
