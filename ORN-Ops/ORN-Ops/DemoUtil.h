//
//  DemoUtil.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


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
+ (void)loadDemoAssignTeams:(NSArray*)teams toRides:(NSArray*)rides;
+ (void)loadDemoAssignTeamsSelector:(NSDictionary*)args;

@end
