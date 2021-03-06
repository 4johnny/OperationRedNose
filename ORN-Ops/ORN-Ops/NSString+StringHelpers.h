//
//  NSString+StringHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-14.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#
# pragma mark - Interface
#

@interface NSString (StringHelpers)

- (NSArray<NSString*>*)componentsTrimAll;
- (NSArray<NSString*>*)componentsTrimAllNewline;
- (NSString*)trim;
- (NSString*)trimAll;
- (NSString*)trimAllNewline;

+ (NSString*)longestStringInStrings:(NSArray<NSString*>*)strings;
+ (BOOL)compareString:(NSString*)firstString toString:(NSString*)secondString;

@end
