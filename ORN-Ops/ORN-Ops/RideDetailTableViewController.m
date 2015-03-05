//
//  RideDetailTableViewController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "RideDetailTableViewController.h"
#import "AppDelegate.h"
#import "Team.h"


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
	
	// HACK: Recreate start-time date picker in code, since UI bug causes middle components to white out on iPad
	// TODO: Remove hack code if/when Apple fixes bug
	UIView* superview = self.startTimeDatePicker.superview;
	[self.startTimeDatePicker removeFromSuperview];
	NSLocale* locale = self.startTimeDatePicker.locale;
	NSInteger minuteInterval = self.startTimeDatePicker.minuteInterval;
	UIDatePicker* startTimeDatePicker = [[UIDatePicker alloc] initWithFrame:self.startTimeDatePicker.frame];
	self.startTimeDatePicker = startTimeDatePicker; // NOTE: Need local strong var since Outlet is weak
	self.startTimeDatePicker.locale = locale;
	self.startTimeDatePicker.minuteInterval = minuteInterval;
	[superview addSubview:self.startTimeDatePicker];
	// END HACK

	[self configureView];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setToolbarHidden:NO];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self.navigationController setToolbarHidden:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#
# pragma mark <UIPickerViewDataSource>
#

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {

	return 1;
}


- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {

	if (pickerView == self.passengerCountPickerView) return 10;
	if (pickerView == self.vehicleTransmissionPickerView) return 2;
	if (pickerView == self.seatBeltCountPickerView) return 11;
	
	return 0;
}


#
# pragma mark <UIPickerViewDelegate>
#


- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

	[self.view endEditing:YES];
}


- (CGFloat)pickerView:(UIPickerView*)pickerView rowHeightForComponent:(NSInteger)component {
	
	return 20; // points
}


- (CGFloat)pickerView:(UIPickerView*)pickerView widthForComponent:(NSInteger)component {

	if (pickerView == self.passengerCountPickerView) return 35;
	if (pickerView == self.vehicleTransmissionPickerView) return 150;
	if (pickerView == self.seatBeltCountPickerView) return 35;
	
	return 0; // points
}


- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

	if (pickerView == self.passengerCountPickerView) return [NSString stringWithFormat:@"%d", (int)row + 1];
	
	if (pickerView == self.vehicleTransmissionPickerView) {
		
		switch (row) {
				
			case 0:
			    return @"Automatic";
				
			case 1:
				return @"Manual";
				
			default:
		    break;
		}
	}
	
	if (pickerView == self.seatBeltCountPickerView) return [NSString stringWithFormat:@"%d", (int)row];
	
	return nil;
}


/*
- (NSAttributedString*)pickerView:(UIPickerView*)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {

	return nil;
}
*/
/*
- (UIView*)pickerView:(UIPickerView*)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView*)view {
	
	return view;
}
*/


#
# pragma mark Action Handlers
#


- (IBAction)backgroundTapped:(UITapGestureRecognizer*)sender {

	[self.view endEditing:YES];
}


- (IBAction)savePressed:(UIBarButtonItem*)sender {
	
	[self.view endEditing:YES];
	
	[self saveDataModelFromView];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RIDE_UPDATED_NOTIFICATION_NAME object:self userInfo:@{RIDE_ENTITY_NAME:self.ride, RIDE_DID_LOCATION_CHANGE_NOTIFICATION_KEY:[NSNumber numberWithBool:YES]}];
	
	[self.navigationController popViewControllerAnimated:YES];
}


#
# pragma mark Helpers
#


- (void)configureView {

	[self configureRangeForStartTimeDatePicker];
	[self loadDataModelIntoView];
}


// Constrain start-time date picker to range between 1 day before and after now
- (void)configureRangeForStartTimeDatePicker {
	
	// Get date-time for now, and Gregorian calendar
	NSDate* now = [NSDate date];
	NSCalendar* gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	
	// Minimum date-time is one day before now
	NSDateComponents* offsetComponents = [[NSDateComponents alloc] init];
	offsetComponents.day = -1;
	self.startTimeDatePicker.minimumDate = [gregorianCalendar dateByAddingComponents:offsetComponents toDate:now options:0];
	
	// Maximum date-time is one day from now
	offsetComponents.day = 1;
	self.startTimeDatePicker.maximumDate = [gregorianCalendar dateByAddingComponents:offsetComponents toDate:now options:0];
}


// Load ride data model into view fields
// TODO: Load remaining data model values into view
- (void)loadDataModelIntoView {

	// Load dispatch fields
//	if (self.ride.teamAssigned) {
//		self.teamAssignedTextField.text = ((Team*)self.ride.teamAssigned).name;
//	}
	
	// Load passenger fields
	self.firstNameTextField.text = self.ride.passengerNameFirst;
	self.lastNameTextField.text = self.ride.passengerNameLast;
	
	// Load location fields
	self.startAddressTextField.text = self.ride.locationStartAddress;
	self.endAddressTextField.text = self.ride.locationEndAddress;
	
	// Load vehicle fields
	
	// Load notes fields
	
	// Load time fields
	self.startTimeDatePicker.date = self.ride.dateTimeStart;
}


// Save ride data model from view fields
// TODO: Save remaining data model values from view
- (void)saveDataModelFromView {

	// Save dispatch fields
//	self.ride.teamAssigned = nil;
//	if (self.teamAssignedPicker.selectedIndex) {
//		
//		// TODO: Get selected team object to assign
//		self.ride.teamAssigned =;
//	}
	
	// Save passenger fields
	self.ride.passengerNameFirst = self.firstNameTextField.text;
	self.ride.passengerNameLast = self.lastNameTextField.text;
	
	// Save location fields
	// TODO: Validate locations via geocoding
	self.ride.locationStartAddress = self.startAddressTextField.text;
	self.ride.locationEndAddress = self.endAddressTextField.text;
	
	// Save vehicle fields
	
	// Save notes fields
	
	// Save time fields
	self.ride.dateTimeStart = self.startTimeDatePicker.date;
	
	// Persist data model to disk
	[RideDetailTableViewController saveManagedObjectContext];
}


+ (void)saveManagedObjectContext {
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate saveManagedObjectContext];
}


@end
