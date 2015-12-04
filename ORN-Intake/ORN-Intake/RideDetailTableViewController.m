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
# pragma mark - Interface
#

@interface RideDetailTableViewController ()

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

	// Show keyboard on first non-dispatch entry field
	[self.firstNameTextField becomeFirstResponder];
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
		
	}
	
	return YES;
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
	
	[self.view endEditing:YES];
}


- (IBAction)submitPressed:(UIBarButtonItem*)sender {
	
	[self.view endEditing:YES];
	
	//	[self submitDataFromView];
}


- (IBAction)statusValueChanged:(UISegmentedControl*)sender {
	
	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:YES];
}


- (IBAction)passengerCountValueChanged:(UISegmentedControl*)sender {

	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:YES];
}


- (IBAction)transmissionValueChanged:(UISegmentedControl*)sender {
	
	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:YES];
}


- (IBAction)seatBeltCountValueChanged:(UISegmentedControl*)sender {
	
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


@end
