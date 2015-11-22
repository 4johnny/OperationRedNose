//
//  DatePickerTextField.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-20.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "DatePickerTextField.h"


#
# pragma mark - Interface
#

@interface DatePickerTextField ()

@property (nonatomic, weak) id<UITextFieldDelegate, DatePickerTextFieldDelegate> externalDelegate;

@property (nonatomic) NSDateFormatter* dateFormatter;

@end


#
# pragma mark - Implementation
#


@implementation DatePickerTextField


#
# pragma mark Property Accessors
#


- (NSDate*)date {
	
	return self.datePicker.date;
}


- (void)setDate:(NSDate*)date {

	self.datePicker.date = date;
	self.text = [self.dateFormatter stringFromDate:date];
}


- (NSInteger)minuteInterval {
	
	return self.datePicker.minuteInterval;
}


- (void)setMinuteInterval:(NSInteger)minuteInterval {
	
	self.datePicker.minuteInterval = minuteInterval;
}


- (NSDate*)minimumDate {

	return self.datePicker.minimumDate;
}


- (void)setMinimumDate:(NSDate*)minimumDate {
	
	self.datePicker.minimumDate = minimumDate;
}


- (NSDate*)maximumDate {
	
	return self.datePicker.maximumDate;
}


- (void)setMaximumDate:(NSDate*)maximumDate {
	
	self.datePicker.maximumDate = maximumDate;
}


- (NSLocale*)locale {

	return self.datePicker.locale;
}


- (void)setLocale:(NSLocale*)locale {
	
	self.datePicker.locale = locale;
}


- (NSString*)dateFormat {
	
	return self.dateFormatter.dateFormat;
}


- (void)setDateFormat:(NSString*)dateFormat {
	
	self.dateFormatter.dateFormat = dateFormat;
}


#
# pragma mark Initializers
#


- (instancetype)initWithCoder:(NSCoder*)coder {
	self = [super initWithCoder:coder];
	
	if (self) {
		
		// Create date picker to be decorated - wire up action target
		_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
		_datePicker.datePickerMode = UIDatePickerModeDateAndTime; // default
		[_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
		self.inputView = _datePicker;
		
		// Create re-usable date formatter
		_dateFormatter = [[NSDateFormatter alloc] init];
		
		// Constrain
		[self constrain];
	}
	
	return self;
}


#
# pragma mark Action Handlers
#


- (IBAction)dateChanged:(UIDatePicker*)sender {
	// NOTE: Wired manually in initializer

	self.text = [self.dateFormatter stringFromDate:self.datePicker.date];
	
	if ([self.externalDelegate respondsToSelector:@selector(dateChanged:)]) {
		
		[self.externalDelegate dateChanged:sender];
	}
}


#
# pragma mark Helper Methods
#


- (void)constrain {
	
	// Basic config
	self.minuteInterval = TIME_MINUTE_INTERVAL;
	self.locale = [NSLocale localeWithLocaleIdentifier:DATE_PICKER_LOCALE];
	self.dateFormat = DATE_PICKER_DATETIME_FORMAT;
	
	// Get date-time for now
	self.date = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	
	// Minimum date-time is one day before now
	NSCalendar* currentCalendar = [NSCalendar currentCalendar];
	NSDateComponents* offsetComponents = [[NSDateComponents alloc] init];
	offsetComponents.day = -1;
	self.minimumDate = [currentCalendar dateByAddingComponents:offsetComponents toDate:self.date options:kNilOptions];
	
	// Maximum date-time is one day from now
	offsetComponents.day = 1;
	self.maximumDate = [currentCalendar dateByAddingComponents:offsetComponents toDate:self.date options:kNilOptions];
}


@end
