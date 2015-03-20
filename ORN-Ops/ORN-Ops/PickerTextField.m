//
//  PickerTextField.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-17.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "PickerTextField.h"


#
# pragma mark - Interface
#

@interface PickerTextField ()

@property (readonly, nonatomic) UIPickerView* pickerView;

@end


#
# pragma mark - Implementation
#


@implementation PickerTextField


#
# pragma mark Initializers
#


- (instancetype)initWithCoder:(NSCoder*)coder {
	self = [super initWithCoder:coder];
	
	if (self) {
		
		self.delegate = self;
		
		UIButton* rightViewDownArrowButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[rightViewDownArrowButton setTitle:@"▼" forState:UIControlStateNormal];
		self.rightView = rightViewDownArrowButton;
		self.rightViewMode = UITextFieldViewModeAlways;

		_pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
		_pickerView.delegate = self;
		_pickerView.showsSelectionIndicator = YES;
		self.inputView = _pickerView;
	}
	
	return self;
}


#
# pragma mark Property Accessors
#


- (void)setTitles:(NSArray*)titles {

	_titles = titles;
}


- (NSInteger)selectedRow {
	
	return [self.pickerView selectedRowInComponent:0];
}


- (void)setSelectedRow:(NSInteger)selectedRow {
	
	[self.pickerView selectRow:selectedRow inComponent:0 animated:NO];
	self.attributedText = [self pickerView:self.pickerView attributedTitleForRow:selectedRow forComponent:0];
}


#
# pragma mark UIView
#


- (void)setTag:(NSInteger)tag {
	[super setTag:tag];
	
	_pickerView.tag = tag;
}


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

	// Right-hand side of text field for down arrow button
	return CGRectMake(bounds.size.width - 30, 0, 30, bounds.size.height);
}


#
# pragma mark <UITextFieldDelegate>
#


- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
	
	// Disable input via external keyboard
	return NO;
}


#
# pragma mark <UIPickerViewDataSource>
#


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
	
	return 1;
}


- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {

	return self.titles.count;
}


#
# pragma mark <UIPickerViewDelegate>
#


- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	self.text = [self pickerView:self.pickerView titleForRow:row forComponent:component];
}


- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	return self.titles[row];
}


- (NSAttributedString*)pickerView:(UIPickerView*)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	// Left-align titles
	NSString* title = [self pickerView:pickerView titleForRow:row forComponent:component];
	NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.alignment = NSTextAlignmentLeft;
	NSMutableAttributedString* attributedTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
	
	return attributedTitle;
}


- (UIView*)pickerView:(UIPickerView*)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView*)view {

	UILabel* label = (UILabel*)view;
	if (!label) {
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:component].width - 16, [pickerView rowSizeForComponent:component].height)];
		
		label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
		label.backgroundColor = [UIColor whiteColor];
		label.font = [UIFont fontWithName:label.font.fontName size:20];
	}
	
	return label;
}


@end
