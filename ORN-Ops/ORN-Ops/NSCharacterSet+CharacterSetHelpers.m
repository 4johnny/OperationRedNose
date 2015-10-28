//
//  NSCharacterSet+CharacterSetHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-10-11.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#import "NSCharacterSet+CharacterSetHelpers.h"


#
# pragma mark - Implementation
#


@implementation NSCharacterSet (CharacterSetHelpers)


#
# pragma mark Methods
#


+ (NSCharacterSet*)phoneNumberCharacterSet {
	
	return [Util sharedUtil].phoneNumberCharacterSet;
}


+ (NSCharacterSet*)phoneNumberCharacterSetInverted {
	
	return [Util sharedUtil].phoneNumberCharacterSetInverted;
}


+ (NSCharacterSet*)monetaryCharacterSet {

	return [Util sharedUtil].monetaryCharacterSet;
}


+ (NSCharacterSet*)monetaryCharacterSetInverted {

	return [Util sharedUtil].monetaryCharacterSetInverted;
}


@end
