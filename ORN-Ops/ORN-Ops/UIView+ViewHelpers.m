//
//  UIView+ViewHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-22.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "UIView+ViewHelpers.h"


#
# pragma mark - Implementation
#


@implementation UIView (ViewHelpers)


- (CGFloat)cornerRadius {
	
	return self.layer.cornerRadius;
}


- (void)setCornerRadius:(CGFloat)cornerRadius {
	
	self.layer.cornerRadius = cornerRadius;
	self.layer.masksToBounds = cornerRadius > 0;
}


- (CGFloat)borderWidth {
	
	return self.layer.borderWidth;
}


- (void)setBorderWidth:(CGFloat)borderWidth {
	
	self.layer.borderWidth = borderWidth;
}


- (UIColor*)borderColor {
	
	return [UIColor colorWithCGColor:self.layer.borderColor];
}


- (void)setBorderColor:(UIColor*)color {
	
	self.layer.borderColor = color.CGColor;
}


- (void)makeNextTaggedViewFirstResponderWithCurrentTaggedView:(UIView*)taggedView
												 andIsAddmode:(BOOL)isAddMode {
	
	if (![taggedView isKindOfClass:UITextField.class] && !isAddMode) return;
	
	// Put focus on next field, if needs keyboard
	UIView* nextView = [self viewWithTag:(taggedView.tag + 1)];
	if (![nextView becomeFirstResponder]) {
		
		// Remove focus and keyboard from current field
		[taggedView resignFirstResponder];
	}
}


@end
