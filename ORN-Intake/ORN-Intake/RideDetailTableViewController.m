//
//  RideDetailTableViewController.m
//  ORN-Intake
//
//  Created by Johnny on 2015-12-03.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

// NOTE: Keep in sync with ORN-Ops

#import "RideDetailTableViewController.h"


#
# pragma mark - Constants
#

#define PHONE_TEXT_LENGTH_MAX	10


#
# pragma mark - Interface
#

@interface RideDetailTableViewController ()

@property (weak, nonatomic) UIResponder* currentResponder;

@end


#
# pragma mark - Implementation
#


@implementation RideDetailTableViewController


#
# pragma mark UIViewController
#


- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// Remove section footer
	self.tableView.sectionFooterHeight = 0;
	
	// Remove table footer
	self.tableView.tableFooterView = [UIView new];

	[self configureTagsForTabOrder];
}


- (void)viewDidAppear:(BOOL)animated {

	[[self initialResponder] becomeFirstResponder];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
	NSLog(@"Warning: Memory Low");
}


#
# pragma mark <UITableViewDelegate>
#


- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
		
	return 32.0;
}


#
# pragma mark <UITextFieldDelegate>
#


- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString*)string {
	
	// NOTE: String may be typed or pasted
	// NOTE: Cannot rely on keyboards to constrain input char types, since different devices show different keyboards for same text field
	// NOTE: Check fields in order of most likely used, since this method is called per char entered
	
	if (textField == self.phoneNumberTextField) {
	
		// Reject non-phone number chars
		if ([string rangeOfCharacterFromSet:[NSCharacterSet phoneNumberCharacterSetInverted]].location != NSNotFound) return NO;
		
		// Reject resulting string exceeding max length
		NSMutableString* newString = [textField.text mutableCopy];
		[newString replaceCharactersInRange:range withString:string];
		if (newString.length > PHONE_TEXT_LENGTH_MAX) return NO;
	}
	
	return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	
	self.currentResponder = textField;
	
	return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField*)textField {
	
	if (self.currentResponder == textField) {
		self.currentResponder = nil;
	}
	
	return YES;
}


#
# pragma mark <UITextViewDelegate>
#


- (void)textViewDidBeginEditing:(UITextView*)textView {

	self.currentResponder = textView;
}


- (void)textViewDidEndEditing:(UITextView*)textView {
	
	if (self.currentResponder == textView) {
		self.currentResponder = nil;
	}
}


/*
 User hit keyboard return key
 */
- (BOOL)textFieldShouldReturn:(UITextField*)textField {

	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:textField andIsAddmode:YES];
	
	return NO; // Do not perform default text-field behaviour
}


#
# pragma mark Action Handlers
#


- (IBAction)backgroundTapped:(UITapGestureRecognizer*)sender {
	
	[self.view endEditing:YES];
}


- (IBAction)clearPressed:(UIBarButtonItem*)sender {
	
	UIResponder* currentResponder = self.currentResponder; // Maybe nil
	[self.view endEditing:YES];
	
	UIAlertAction* clearAction = [UIAlertAction actionWithTitle:@"Clear" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* _Nonnull action) {
		
		[self clearFields];
	}];
	
	[Util presentActionAlertWithViewController:self
									  andTitle:@"Clear Form"
									andMessage:@"Cannot be undone! Are you sure?"
									 andAction:clearAction
									andCancelHandler:^(UIAlertAction* action) {
										[currentResponder becomeFirstResponder];
									}];
}


- (IBAction)submitPressed:(UIBarButtonItem*)sender {
	
	UIResponder* currentResponder = self.currentResponder; // Maybe nil
	[self.view endEditing:YES];

	UIAlertAction* submitAction = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* _Nonnull action) {
		
		[self submitFieldsWithCurrentResponder:currentResponder];
	}];
	
	[Util presentActionAlertWithViewController:self
									  andTitle:@"Submit Form"
									andMessage:@"Cannot be undone! Are you sure?"
									 andAction:submitAction
									andCancelHandler:^(UIAlertAction* action) {
										[currentResponder becomeFirstResponder];
									}];
}


- (IBAction)passengerCountValueChanged:(UISegmentedControl*)sender {
	
	self.currentResponder = nil;

	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:YES];
}


- (IBAction)transmissionValueChanged:(UISegmentedControl*)sender {
	
	self.currentResponder = nil;
	
	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:YES];
}


- (IBAction)seatBeltCountValueChanged:(UISegmentedControl*)sender {
	
	self.currentResponder = nil;
	
	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:YES];
}


#
# pragma mark Helpers
#


- (void)configureTagsForTabOrder {

	// Dispatch
	self.sourceTextField.tag =						0;
	self.idealTimeDatePickerTextField.tag =			1;
	
	// Passenger
	self.firstNameTextField.tag =					2;
	self.lastNameTextField.tag =					3;
	self.phoneNumberTextField.tag =					4;
	self.passengerCountSegmentedControl.tag =		5;
	
	// Location
	self.startAddressTextField.tag =				6;
	self.endAddressTextField.tag =					7;
	self.transferFromTextField.tag =				8;
	self.transferToTextField.tag =					9;
	
	// Vehicle
	self.vehicleDescriptionTextField.tag =			10;
	self.vehicleTransmissionSegmentedControl.tag =	11;
	self.seatBeltCountSegmentedControl.tag =		12;
	
	// Notes
	self.notesTextView.tag =						13;
}


- (UIResponder*)initialResponder {

	return self.firstNameTextField;
}


- (void)clearFields {

	// Clear all fields *except* for source, for user convenience

	// Dispatch
	//	self.sourceTextField.text = nil;
	[self.idealTimeDatePickerTextField constrain];
	
	// Passenger
	self.firstNameTextField.text = nil;
	self.lastNameTextField.text = nil;
	self.phoneNumberTextField.text = nil;
	self.passengerCountSegmentedControl.selectedSegmentIndex = 0;
	
	// Location
	self.startAddressTextField.text = nil;
	self.endAddressTextField.text = nil;
	self.transferFromTextField.text = nil;
	self.transferToTextField.text = nil;
	
	// Vehicle
	self.vehicleDescriptionTextField.text = nil;
	self.vehicleTransmissionSegmentedControl.selectedSegmentIndex = 0;
	self.seatBeltCountSegmentedControl.selectedSegmentIndex = 0;
	
	// Notes
	self.notesTextView.text = nil;

	// Reset responder state
	self.currentResponder = nil;
	[[self initialResponder] becomeFirstResponder];
}


- (void)submitFieldsWithCurrentResponder:(UIResponder*)currentResponder {

	// TODO: Implement submitting fields to Telegram bot
	
	BOOL isSubmitSuccessful = NO;
	if (!isSubmitSuccessful) {
	
		[Util presentOKAlertWithViewController:self andTitle:@"Submit Form" andMessage:@"Unable to submit form at this time.\nTry again later." andHandler:^(UIAlertAction* action) {
			
			[currentResponder becomeFirstResponder];
		}];
		
		return;
	}

	[Util presentOKAlertWithViewController:self andTitle:@"Submit Form" andMessage:@"Submitted form successfully.\nProvide paper form to dispatcher." andHandler:^(UIAlertAction* action) {
		
		[self clearFields];
	}];
}


@end
