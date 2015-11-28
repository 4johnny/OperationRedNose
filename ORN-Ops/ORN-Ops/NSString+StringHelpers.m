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


- (NSArray<NSString*>*)componentsTrimAll {

	NSArray<NSString*>* stringComponents = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	return [stringComponents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
}


- (NSArray<NSString*>*)componentsTrimAllNewline {
	
	NSArray<NSString*>* stringComponents = [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	return [stringComponents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
}


- (NSString*)trim {
	
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (NSString*)trimAllNewline {
	
	return [[self componentsTrimAllNewline] componentsJoinedByString:@" "];
}


- (NSString*)trimAll {
	
	return [[self componentsTrimAll] componentsJoinedByString:@" "];
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
