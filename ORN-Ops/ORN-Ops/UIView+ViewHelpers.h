//
//  UIView+ViewHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-22.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

#
# pragma mark - Interface
#

@interface UIView (ViewHelpers)

@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable UIColor* borderColor;

- (void)makeNextTaggedViewFirstResponderWithCurrentTaggedView:(UIView*)taggedView
												 andIsAddmode:(BOOL)isAddMode;

- (void)animateDropFromHeight:(CGFloat)dropHeight
				  andDuration:(NSTimeInterval)duration
					 andDelay:(NSTimeInterval)delay;

- (void)animateMoveToCenterPoint:(CGPoint)centerPoint
					 andDuration:(NSTimeInterval)duration
						andDelay:(NSTimeInterval)delay
				  andNeedsSquash:(BOOL)needsSquash
					  completion:(void (^)(void))completion;

@end
