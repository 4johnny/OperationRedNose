//
//  PickerTextField.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-17.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "PickerTextField.h"


#
# pragma mark - Constants
#

#define TITLE_FONT_SIZE		24
#define ROW_HEIGHT_BUFFER	8

#
# pragma mark - Interface
#

@interface PickerTextField ()

@property (weak, nonatomic) id<UITextFieldDelegate, UIPickerViewDelegate> externalDelegate; // NOTE: Original delegate wired internally; inherited from parent class

@property (nonatomic) NSInteger initialSelectedRow;

@property (nonatomic) CGFloat maxTitleLabelWidth;

@end


#
# pragma mark - Implementation
#


@implementation PickerTextField


#
# pragma mark Property Accessors
#


- (void)setTitles:(NSArray<NSString*>*)titles {
	
	_titles = titles;
	
	self.maxTitleLabelWidth = -1;
}


- (NSInteger)selectedRow {
	
	return [self.pickerView selectedRowInComponent:0];
}


- (void)setSelectedRow:(NSInteger)selectedRow withAnimated:(BOOL)animated {
	
	if ([self.pickerView selectedRowInComponent:0] <= 0) {
		
		self.initialSelectedRow = selectedRow;
	}
	
	[self.pickerView selectRow:selectedRow inComponent:0 animated:animated];
	[self pickerView:self.pickerView didSelectRow:selectedRow inComponent:0];
}


- (void)setSelectedRow:(NSInteger)selectedRow {
	
	[self setSelectedRow:selectedRow withAnimated:NO];
}


- (CGFloat)maxTitleLabelWidth {

	if (!(_maxTitleLabelWidth < 0)) return _maxTitleLabelWidth;
	
	NSString* longestTitle = [NSString longestStringInStrings:self.titles];
	UILabel* longestTitleLabel = [PickerTextField labelWithAttributedTitle:[[NSAttributedString alloc] initWithString:longestTitle]];
	_maxTitleLabelWidth = [longestTitleLabel sizeThatFits:CG_SIZE_MAX].width;
	
	return _maxTitleLabelWidth;
}


#
# pragma mark Initializers
#


- (instancetype)initWithCoder:(NSCoder*)coder {
	self = [super initWithCoder:coder];
	
	if (self) {
		
		// Create picker view to be decorated - wire up delegate
		_pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
		_pickerView.showsSelectionIndicator = YES;
		_pickerView.delegate = self;
		self.inputView = _pickerView;
	}
	
	return self;
}


#
# pragma mark UIView
#


- (void)setTag:(NSInteger)tag {
	[super setTag:tag];
	
	_pickerView.tag = tag;
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
	
	if (row == self.initialSelectedRow || self.pickableStatuses[row].boolValue) {
		
		self.text = [self pickerView:self.pickerView titleForRow:row forComponent:component];
		
	} else {

		row = self.initialSelectedRow;
		[self setSelectedRow:row withAnimated:YES];
	}
	
	if ([self.externalDelegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
	
		[self.externalDelegate pickerView:pickerView didSelectRow:row inComponent:component];
	}
}


- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	return self.titles[row];
}


- (NSAttributedString*)pickerView:(UIPickerView*)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	NSAssert(self.titles.count == self.pickableStatuses.count, @"Must have pickable status for each title");
	NSAssert(0 <= row && row < self.titles.count, @"Row must be in range of titles");
	
	// Show non-pickable titles in red
	UIColor* titleColor = self.pickableStatuses[row].boolValue ? [UIColor blackColor] : [UIColor redColor];
	
	// Left-align titles
	NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.alignment = NSTextAlignmentLeft;
	
	NSAttributedString* attributedTitle =
 	[[NSAttributedString alloc] initWithString:self.titles[row] attributes:
	@{
	  NSForegroundColorAttributeName : titleColor,
	  NSParagraphStyleAttributeName : paragraphStyle,
	  }];
	
	return attributedTitle;
}


- (CGFloat)pickerView:(UIPickerView*)pickerView rowHeightForComponent:(NSInteger)component {
	
	return TITLE_FONT_SIZE + ROW_HEIGHT_BUFFER;
}


- (UIView*)pickerView:(UIPickerView*)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView*)view {

	UILabel* label = (UILabel*)view;
	if (!label) {

		label = [PickerTextField labelWithAttributedTitle:[self pickerView:pickerView attributedTitleForRow:row forComponent:component]];
		CGFloat labelWidth = MIN(self.maxTitleLabelWidth, pickerView.bounds.size.width);
		label.frame = CGRectMake(0, 0, labelWidth, [self pickerView:pickerView rowHeightForComponent:component]);
	}
	
	return label;
}


#
# pragma mark Helpers
#


+ (UILabel*)labelWithAttributedTitle:(NSAttributedString*)attributedTitle {

	UILabel* label = [[UILabel alloc] init];
	label.attributedText = attributedTitle;
	label.font = [UIFont fontWithName:label.font.fontName size:TITLE_FONT_SIZE];
	
	return label;
}


@end
