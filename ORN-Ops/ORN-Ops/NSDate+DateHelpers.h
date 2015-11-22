//
//  NSDate+DateHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-21.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#
# pragma mark - Interface
#

@interface NSDate (DateHelpers)

#
# pragma mark Initializers
#

+ (instancetype)dateRoundedToMinuteInterval:(NSInteger)minuteInterval;

#
# pragma mark Methods
#

- (instancetype)roundToMinuteInterval:(NSInteger)minuteInterval;

- (BOOL)isOlderThanMinutes:(NSInteger)minutes;

#
# pragma mark Class Methods
#

+ (BOOL)compareDate:(NSDate*)firstDate toDate:(NSDate*)secondDate;

@end
