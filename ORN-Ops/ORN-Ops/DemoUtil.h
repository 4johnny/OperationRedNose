//
//  DemoUtil.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Ride+RideHelpers.h"
#import "Team+TeamHelpers.h"


#
# pragma mark - Interface
#

@interface DemoUtil : NSObject

#
# pragma mark Class Methods
#

// NOTE: Caller is responsible for saving to persistent store

+ (void)loadDemoRides;
+ (void)loadDemoTeams;
+ (void)loadDemoAssignTeams:(NSArray<Team*>*)teams toRides:(NSArray<Ride*>*)rides;
+ (void)loadDemoAssignTeamsSelector:(NSDictionary<NSString*,NSArray<__kindof NSManagedObject*>*>*)args;

@end
