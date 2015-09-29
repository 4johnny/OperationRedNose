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


#
# pragma mark Class Methods
#


+ (BOOL)compareDate:(NSDate*)firstDate toDate:(NSDate*)secondDate {
	
	return (!firstDate && !secondDate) || [firstDate isEqualToDate:secondDate];
}


@end
