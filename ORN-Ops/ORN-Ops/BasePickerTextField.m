//
//  BasePickerTextField.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-21.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "BasePickerTextField.h"


#
# pragma mark - Interface
#

@interface BasePickerTextField ()

@end


#
# pragma mark - Implementation
#


@implementation BasePickerTextField


#
# pragma mark Initializers
#


- (instancetype)initWithCoder:(NSCoder*)coder {
	self = [super initWithCoder:coder];
	
	if (self) {
		
		// Wire up text field delegate
		self.delegate = self;
		
		// Arrow on right side of text field
		UIButton* arrowButton = [Util downArrowButton];
		[arrowButton addTarget:self action:@selector(arrowPressed:) forControlEvents:UIControlEventTouchUpInside];
		self.rightView = arrowButton;
		self.rightViewMode = UITextFieldViewModeAlways;
	}
	
	return self;
}


#
# pragma mark UIView
#

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#
# pragma mark UITextField
#


- (CGRect)caretRectForPosition:(UITextPosition*)position {
	
	// Hide caret
	return CGRectZero;
}


- (CGRect)rightViewRectForBounds:(CGRect)bounds {
	
	// Right-hand side of text field for down-arrow button
	return CGRectMake(bounds.size.width - ARROW_BUTTON_WIDTH, 0, ARROW_BUTTON_WIDTH, bounds.size.height);
}


#
# pragma mark <UITextFieldDelegate>
#


- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
	
	// Disable input via external keyboard
	return NO;
}


#
# pragma mark Action Handlers
#


- (IBAction)arrowPressed:(UIButton*)sender {
	
	[self becomeFirstResponder];
}


@end
