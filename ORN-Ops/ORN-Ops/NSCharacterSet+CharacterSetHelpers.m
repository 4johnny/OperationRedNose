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


+ (NSCharacterSet*)nonPhoneNumberCharacterSet {
	
	return [Util sharedUtil].nonPhoneNumberCharacterSet;
}


+ (NSCharacterSet*)monetaryCharacterSet {

	return [Util sharedUtil].monetaryCharacterSet;
}


+ (NSCharacterSet*)nonMonetaryCharacterSet {

	return [Util sharedUtil].nonMonetaryCharacterSet;
}


@end
