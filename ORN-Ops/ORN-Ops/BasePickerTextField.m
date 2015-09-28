//
//  BasePickerTextField.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-21.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "BasePickerTextField.h"


#
# pragma mark - Constants
#

#define ARROW_BUTTON_WIDTH	30


#
# pragma mark - Interface
#

#define SHADOW_RADIUS	0.5


#
# pragma mark - Interface
#

@interface BasePickerTextField ()

@property (nonatomic) id<UITextFieldDelegate> externalDelegate; // NOTE: Original delegate wired internally

@end


#
# pragma mark - Implementation
#


@implementation BasePickerTextField


#
# pragma mark Property Accessors
#


- (id<UITextFieldDelegate>)delegate {

	return self.externalDelegate;
}


- (void)setDelegate:(id<UITextFieldDelegate>)delegate {

	self.externalDelegate = delegate;
}


#
# pragma mark Initializers
#


- (instancetype)initWithCoder:(NSCoder*)coder {
	self = [super initWithCoder:coder];
	
	if (self) {
		
		// Intercept delegate internally
		// NOTE: Delegate messages will manually be passed on to external delegate
		super.delegate = self;

		// Make room for shadow outside bounds
		self.layer.masksToBounds = NO;
		
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


- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
	
	BOOL shouldBeginEditing = !self.externalDelegate || [self.externalDelegate textFieldShouldBeginEditing:textField];
	
	if (shouldBeginEditing) {
		
	 	// Add shadow, since hiding caret
		textField.layer.shadowOpacity = 1.0;
		textField.layer.shadowRadius = SHADOW_RADIUS; // default 3.0
		textField.layer.shadowOffset = CGSizeMake(SHADOW_RADIUS, SHADOW_RADIUS); // default (0.0, -3.0)
		textField.layer.shadowColor = [UIColor blueColor].CGColor;
	}
	
	return shouldBeginEditing;
}


- (void)textFieldDidBeginEditing:(UITextField*)textField {

	[self.externalDelegate textFieldDidBeginEditing:textField];
}


- (BOOL)textFieldShouldEndEditing:(UITextField*)textField {

	BOOL shouldEndEditing = !self.externalDelegate || [self.externalDelegate textFieldShouldEndEditing:textField];
	
	return shouldEndEditing;
}


- (void)textFieldDidEndEditing:(UITextField*)textField {

	[self.externalDelegate textFieldDidEndEditing:textField];
	
	// Remove shadow
	textField.layer.shadowOpacity = 0.0;
}


- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
	
	BOOL shouldChangeCharacters = !self.externalDelegate || [self.externalDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];

	// Disable input via external keyboard
	// NOTE: Ignore external delegate
	(void)shouldChangeCharacters;
	return NO;
}


- (BOOL)textFieldShouldClear:(UITextField*)textField {

	BOOL shouldClear = !self.externalDelegate || [self.externalDelegate textFieldShouldClear:textField];
	
	return shouldClear;
}


- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	
	BOOL shouldReturn = !self.externalDelegate || [self.externalDelegate textFieldShouldReturn:textField];

	return shouldReturn;
}


#
# pragma mark Action Handlers
#


- (IBAction)arrowPressed:(UIButton*)sender {
	// NOTE: Wired programmatically
	
	[self becomeFirstResponder];
}


@end
