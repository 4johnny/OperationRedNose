//
//  NSNumber+NumberHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-09-21.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "NSNumber+NumberHelpers.h"


#
# pragma mark - Implementation
#


@implementation NSNumber (NumberHelpers)


- (NSString*)boolStringValue {

	return self.boolValue ? @"Yes" : @"No";
}


@end
