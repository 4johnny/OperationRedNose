//
//  NSDate+DateHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-21.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "NSDate+DateHelpers.h"


#
# pragma mark - Implementation
#


@implementation NSDate (DateHelpers)


#
# pragma mark Initializers
#


+ (instancetype)dateRoundedToMinuteInterval:(NSInteger)minuteInterval {

	return [[NSDate date] roundToMinuteInterval:minuteInterval];
}


#
# pragma mark Methods
#


- (NSDate*)roundToMinuteInterval:(NSInteger)minuteInterval {
	
	NSCalendar* currentCalendar = [NSCalendar currentCalendar];
	
	NSCalendarUnit unitFlags =
	(
	 NSCalendarUnitEra |
	 NSCalendarUnitYear |
	 NSCalendarUnitMonth |
	 NSCalendarUnitDay |
	 NSCalendarUnitHour |
	 NSCalendarUnitMinute |
	 NSCalendarUnitSecond
	 );
	
	NSDateComponents* dateComponents = [currentCalendar components:unitFlags fromDate:self];

	if (dateComponents.second >= SECONDS_PER_MINUTE / 2.0) {
		
		dateComponents.minute++;
		dateComponents.second = 0;
	}
	
	NSInteger remainder = dateComponents.minute % minuteInterval;
	
	NSDateComponents* offsetComponents = [[NSDateComponents alloc] init];
	offsetComponents.minute = (remainder >= minuteInterval / 2.0) ? minuteInterval - remainder : -remainder;
	
	return [currentCalendar dateByAddingComponents:offsetComponents toDate:[currentCalendar dateFromComponents:dateComponents] options:0];
}


#
# pragma mark Class Methods
#


+ (BOOL)compareDate:(NSDate*)firstDate toDate:(NSDate*)secondDate {
	
	return (!firstDate && !secondDate) || [firstDate isEqualToDate:secondDate];
}


@end
