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


- (instancetype)dateWithCalendarUnit:(NSCalendarUnit)calendarUnit {
	
	NSCalendar* currentCalendar = [NSCalendar currentCalendar];
	
	NSDateComponents* dateComponents = [currentCalendar components:calendarUnit fromDate:self];
	
	return [currentCalendar dateFromComponents:dateComponents];
}


- (instancetype)dateByFlooringToMinute {
	
	const NSCalendarUnit calendarUnit =
	(
	 NSCalendarUnitEra |
	 NSCalendarUnitYear |
	 NSCalendarUnitMonth |
	 NSCalendarUnitDay |
	 NSCalendarUnitHour |
	 NSCalendarUnitMinute
	 );
	
	return [self dateWithCalendarUnit:calendarUnit];
}


- (instancetype)dateByFlooringToDay {
	
	const NSCalendarUnit calendarUnit =
	(
	 NSCalendarUnitEra |
	 NSCalendarUnitYear |
	 NSCalendarUnitMonth |
	 NSCalendarUnitDay
	 );
	
	return [self dateWithCalendarUnit:calendarUnit];
}


- (instancetype)dateByFlooringToYear {
	
	const NSCalendarUnit calendarUnit =
	(
	 NSCalendarUnitEra |
	 NSCalendarUnitYear
	 );
	
	return [self dateWithCalendarUnit:calendarUnit];
}


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

	// Round seconds into minutes directly
	// NOTE: Not worrying about leap-seconds
	if (dateComponents.second >= SECONDS_PER_MINUTE / 2) {
		
		dateComponents.minute++;
	}
	dateComponents.second = 0;

	// Determine minutes duration to add back into date
	NSDateComponents* offsetComponents = [[NSDateComponents alloc] init];
	offsetComponents.minute = floor((dateComponents.minute + minuteInterval / 2.0) / minuteInterval) * minuteInterval;
	dateComponents.minute = 0;

	return [currentCalendar dateByAddingComponents:offsetComponents toDate:[currentCalendar dateFromComponents:dateComponents] options:kNilOptions];
}


- (BOOL)isOlderThanMinutes:(NSInteger)minutes {

	NSTimeInterval minutesSinceNow = [self timeIntervalSinceNow] / (NSTimeInterval)SECONDS_PER_MINUTE;
	
	return (minutesSinceNow <= -minutes);
}


#
# pragma mark Class Methods
#


+ (instancetype)dateWithYear:(NSInteger)year {
	
	NSInteger commonEra = 1;
	return [[NSCalendar currentCalendar] dateWithEra:commonEra year:year month:0 day:0 hour:0 minute:0 second:0 nanosecond:0];
}


+ (BOOL)compareDate:(NSDate*)firstDate toDate:(NSDate*)secondDate {
	
	return (!firstDate && !secondDate) || [firstDate isEqualToDate:secondDate];
}


@end
