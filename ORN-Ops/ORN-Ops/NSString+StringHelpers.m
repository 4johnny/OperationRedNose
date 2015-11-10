//
//  NSString+StringHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-14.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "NSString+StringHelpers.h"


#
# pragma mark - Implementation
#


@implementation NSString (StringHelpers)


- (NSString*)trim {
	
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (NSString*)trimAll {
	
	NSArray<NSString*>* stringComponents = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	stringComponents = [stringComponents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
	return [stringComponents componentsJoinedByString:@" "];
}


+ (BOOL)compareString:(NSString*)firstString toString:(NSString*)secondString {
	
	// NOTE: Treat nil & empty as same - checking length covers nil as well
	return ((firstString.length <= 0 && secondString.length <= 0) || [firstString isEqualToString:secondString]);
}


+ (NSString*)longestStringInStrings:(NSArray<NSString*>*)strings {
	
	NSString* longestString = nil;
	
	for (NSString* string in strings) {
		
		if (string.length <= longestString.length) continue;
		
		longestString = string;
	}
	
	return longestString;
}


@end
