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

@property (weak, nonatomic) id<UITextFieldDelegate, UIPickerViewDelegate> externalDelegate; // NOTE: Original delegate wired internally

@end


#
# pragma mark - Implementation
#


@implementation BasePickerTextField


#
# pragma mark Property Accessors
#


- (id<UITextFieldDelegate, UIPickerViewDelegate>)delegate {

	return self.externalDelegate;
}


- (void)setDelegate:(id<UITextFieldDelegate, UIPickerViewDelegate>)delegate {

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
		UIButton* arrowButton = [UIButton downArrowSystemButton];
		[arrowButton addTarget:self action:@selector(arrowPressed:) forControlEvents:UIControlEventTouchUpInside];
		self.rightView = arrowButton;
		self.rightViewMode = UITextFieldViewModeAlways;
		
		// Next button on input accessory toolbar
		UIBarButtonItem* flexibleButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem* nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(nextPressed:)];
		UIToolbar* toolbar = [UIToolbar new];
		toolbar.items = @[ flexibleButton, nextButton ];
		[toolbar sizeToFit];
		self.inputAccessoryView = toolbar;
	}
	
	return self;
}


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
	
	BOOL shouldBeginEditing =
	![self.externalDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)] ||
	[self.externalDelegate textFieldShouldBeginEditing:textField];
	
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

	if ([self.externalDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
		
		[self.externalDelegate textFieldDidBeginEditing:textField];
	}
}


- (BOOL)textFieldShouldEndEditing:(UITextField*)textField {

	BOOL shouldEndEditing =
	![self.externalDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)] ||
	[self.externalDelegate textFieldShouldEndEditing:textField];
	
	return shouldEndEditing;
}


- (void)textFieldDidEndEditing:(UITextField*)textField {

	// Remove shadow
	textField.layer.shadowOpacity = 0.0;
	
	if ([self.externalDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {

		[self.externalDelegate textFieldDidEndEditing:textField];
	}
}


- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString*)string {
	
	BOOL shouldChangeCharacters =
	![self.externalDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)] ||
 	[self.externalDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];

	// Disable input via external keyboard
	// NOTE: Ignore external delegate
	(void)shouldChangeCharacters;
	return NO;
}


- (BOOL)textFieldShouldClear:(UITextField*)textField {

	BOOL shouldClear =
	![self.externalDelegate respondsToSelector:@selector(textFieldShouldClear:)] ||
	[self.externalDelegate textFieldShouldClear:textField];
	
	return shouldClear;
}


- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	
	BOOL shouldReturn =
	![self.externalDelegate respondsToSelector:@selector(textFieldShouldReturn:)] ||
	[self.externalDelegate textFieldShouldReturn:textField];

	return shouldReturn;
}


#
# pragma mark Action Handlers
#


- (IBAction)arrowPressed:(UIButton*)sender {
	// NOTE: Wired programmatically
	
	[self becomeFirstResponder];
}


- (IBAction)nextPressed:(UIBarButtonItem*)sender {
	// NOTE: Wired programmatically

	[self.delegate textFieldShouldReturn:self];
}


@end
