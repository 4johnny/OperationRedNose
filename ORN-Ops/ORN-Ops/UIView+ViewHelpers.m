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


- (void)animateDropFromHeight:(CGFloat)dropHeight
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
		
		// Animate squash, completing with un-squash
		[UIView animateWithDuration:0.05 animations:^{
			
			self.transform = CGAffineTransformMakeScale(1.0, 0.8);
			
		} completion:^(BOOL finished){
			
			[UIView animateWithDuration:0.1 animations:^{
				
				self.transform = CGAffineTransformIdentity;
			}];
		}];
	}];
}


- (void)animateMoveToCenterPoint:(CGPoint)centerPoint
					 andDuration:(NSTimeInterval)duration
						andDelay:(NSTimeInterval)delay
				  andNeedsSquash:(BOOL)needsSquash
					  completion:(void (^)(void))completion {

	[UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
		
		self.center = centerPoint;
		
	} completion:^(BOOL finished) {
		
		if (!needsSquash) {
			
			if (completion) completion();
			return;
		}
		
		// Animate squash, completing with un-squash
		[UIView animateWithDuration:0.05 animations:^{
			
			self.transform = CGAffineTransformMakeScale(0.9, 0.9);
			
		} completion:^(BOOL finished){
			
			[UIView animateWithDuration:0.1 animations:^{
				
				self.transform = CGAffineTransformIdentity;
				
			} completion:^(BOOL finished) {
				
				if (completion) completion();
			}];
		}];
	}];
}


@end
