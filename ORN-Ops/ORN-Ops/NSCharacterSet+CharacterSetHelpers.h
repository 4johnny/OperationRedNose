//
//  NSCharacterSet+CharacterSetHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-10-11.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#
# pragma mark - Interface
#

@interface NSCharacterSet (CharacterSetHelpers)

#
# pragma mark Methods
#

+ (NSCharacterSet*)phoneNumberCharacterSet;
+ (NSCharacterSet*)phoneNumberCharacterSetInverted;

+ (NSCharacterSet*)monetaryCharacterSet;
+ (NSCharacterSet*)monetaryCharacterSetInverted;

@end
