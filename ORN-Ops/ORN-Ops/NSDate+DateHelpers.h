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

+ (BOOL)compareDate:(NSDate*)firstDate toDate:(NSDate*)secondDate;

@end
