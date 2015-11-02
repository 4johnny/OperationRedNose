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


- (void)makeNextTaggedViewFirstResponderWithCurrentTaggedView:(UIView*)currentTaggedView
												 andIsAddmode:(BOOL)isAddMode {
	
	[self endEditing:YES];
	
	if (![currentTaggedView isKindOfClass:UITextField.class] && !isAddMode) return;
	
	UIView* nextTaggedView = [self viewWithTag:(currentTaggedView.tag + 1)];
	[nextTaggedView becomeFirstResponder];
}


- (void)animateDropWithHeight:(CGFloat)dropHeight
				  andDuration:(NSTimeInterval)duration
					 andDelay:(NSTimeInterval)delay {

	// Remember end frame for annotation
	CGRect endFrame = self.frame;
	
	// Move annotation out of view
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - dropHeight, self.frame.size.width, self.frame.size.height);
	
	// Animate drop, completing with squash effect
	[UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
		
		self.frame = endFrame;
		
	} completion:^(BOOL finished) {
		
		if (!finished) return; // Exit block
		
		// Animate squash, completing with un-squash
		[UIView animateWithDuration:0.05 animations:^{
			
			self.transform = CGAffineTransformMakeScale(1.0, 0.8);
			
		} completion:^(BOOL finished){
			
			if (!finished) return; // Exit block
			
			[UIView animateWithDuration:0.1 animations:^{
				
				self.transform = CGAffineTransformIdentity;
			}];
		}];
	}];
}


@end
