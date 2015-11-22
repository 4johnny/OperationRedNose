//
//  UIFont+FontHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-11-21.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#import "UIFont+FontHelpers.h"


#
# pragma mark - Implementation
#


@implementation UIFont (FontHelpers)


#
# pragma mark Methods
#


- (BOOL)isBold {
	
	return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold);
}


- (UIFont*)fontBolded {
	
	if ([self isBold]) return self;
	
	// Get bolded version of font - if none, return existing font
	UIFontDescriptor* fontDescriptor = [self.fontDescriptor fontDescriptorWithSymbolicTraits:self.fontDescriptor.symbolicTraits | UIFontDescriptorTraitBold];
	if (!fontDescriptor) {
		NSLog(@"Bold trait not available on font: %@", self.fontName);
		return self;
	}
	
	// NOTE: Size of zero means same size
	UIFont* font = [UIFont fontWithDescriptor:fontDescriptor size:0];
	NSLog(@"Bolded font: %@; from descriptor: %@", font, fontDescriptor);
	
	return font;
}


- (UIFont*)fontUnbolded {
	
	if (![self isBold]) return self;
	
	// Get unbolded version of font - if none, return existing font
	UIFontDescriptor* fontDescriptor = [self.fontDescriptor fontDescriptorWithSymbolicTraits:self.fontDescriptor.symbolicTraits & ~UIFontDescriptorTraitBold];
	NSAssert(fontDescriptor, @"Font must exist without bold");
	
	// NOTE: Size of zero means same size
	UIFont* font = [UIFont fontWithDescriptor:fontDescriptor size:0];
	NSLog(@"Unbolded font: %@; from descriptor: %@", font, fontDescriptor);
	
	return font;
}


- (BOOL)isItalic {
	
	return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitItalic);
}


- (UIFont*)fontItalicized {
	
	if ([self isItalic]) return self;
	
	// Get italicized version of font - if none, return existing font
	UIFontDescriptor* fontDescriptor = [self.fontDescriptor fontDescriptorWithSymbolicTraits:self.fontDescriptor.symbolicTraits | UIFontDescriptorTraitItalic];
	if (!fontDescriptor) {
		NSLog(@"Italic trait not available on font: %@", self.fontName);
		return self;
	}
	
	// NOTE: Size of zero means same size
	UIFont* font = [UIFont fontWithDescriptor:fontDescriptor size:0];
	NSLog(@"Italicized font: %@; from descriptor: %@", font, fontDescriptor);
	
	return font;
}


- (UIFont*)fontUnitalicized {
	
	if (![self isItalic]) return self;
	
	// Get unitalicized version of font - if none, return existing font
	UIFontDescriptor* fontDescriptor = [self.fontDescriptor fontDescriptorWithSymbolicTraits:self.fontDescriptor.symbolicTraits & ~UIFontDescriptorTraitItalic];
	NSAssert(fontDescriptor, @"Font must exist without italic");
	
	// NOTE: Size of zero means same size
	UIFont* font = [UIFont fontWithDescriptor:fontDescriptor size:0];
	NSLog(@"Unitalicized font: %@; from descriptor: %@", font, fontDescriptor);
	
	return font;
}


- (UIFont*)fontWithName:(NSString*)fontName {
	
	if ([self.fontName isEqualToString:fontName]) return self;
	
	// Get new font with same traits as existing font - if none, return just basic new font
	UIFont* font = [UIFont fontWithName:fontName size:self.pointSize];
	UIFontDescriptor* fontDescriptor = [font.fontDescriptor fontDescriptorWithSymbolicTraits:self.fontDescriptor.symbolicTraits];
	if (!fontDescriptor) {
		NSLog(@"Traits: 0x%X; not available for font: %@", self.fontDescriptor.symbolicTraits, font.fontName);
		return font;
	}
	
	// NOTE: Size of zero means same size
	font = [UIFont fontWithDescriptor:fontDescriptor size:0];
	NSLog(@"New font: %@; from name: %@", font, fontName);
	
	return font;
}


#
# pragma mark Logging
#


#ifdef SMART_LOG_FONT

+ (void)logAllFonts {
	
	SmartLogFont(@"All Loaded Fonts:");
	
	for (NSString* familyName in [[UIFont familyNames] sortedArrayUsingSelector:@selector(compare:)]) {
		
		SmartLogFont(@"%@", familyName);
		
		for (NSString* fontName in [[UIFont fontNamesForFamilyName:familyName] sortedArrayUsingSelector:@selector(compare:)]) {
			
			SmartLogFont(@"  %@", fontName);
		}
	}
}

#endif


@end
