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


+ (BOOL)compareDate:(NSDate*)firstDate toDate:(NSDate*)secondDate {
	
	return (!firstDate && !secondDate) || [firstDate isEqualToDate:secondDate];
}


@end
