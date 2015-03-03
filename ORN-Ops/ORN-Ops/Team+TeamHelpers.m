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


@end
