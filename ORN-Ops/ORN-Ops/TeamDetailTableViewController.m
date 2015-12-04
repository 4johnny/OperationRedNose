//
//  TeamDetailTableViewController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "TeamDetailTableViewController.h"
#import "Ride+RideHelpers.h"


#
# pragma mark - Constants
#

#define PHONE_TEXT_LENGTH_MAX	10


#
# pragma mark - Interface
#

@interface TeamDetailTableViewController ()

#
# pragma mark Properties
#

@property (nonatomic, getter=isAddMode) BOOL addMode;

@property (nonatomic) CLGeocoder* geocoder;

@property (nonatomic) NSNumberFormatter* currencyNumberFormatter;

@end


#
# pragma mark - Implementation
#


@implementation TeamDetailTableViewController


#
# pragma mark Property Accessors
#


- (CLGeocoder*)geocoder {
	
	if (_geocoder) return _geocoder;
	
	_geocoder = [[CLGeocoder alloc] init];
	
	return _geocoder;
}


- (NSNumberFormatter*)currencyNumberFormatter {
	
	if (!_currencyNumberFormatter) {
		
		_currencyNumberFormatter = [[NSNumberFormatter alloc] init];
		_currencyNumberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
		_currencyNumberFormatter.locale = [NSLocale currentLocale];
	}
	
	return _currencyNumberFormatter;
}


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

	// Configure access mode: add or edit
	self.addMode = (self.team == nil);
	if (self.isAddMode) {
		
		// Replace "save" button with "add"
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(savePressed:)];
	}
	
	[self configureTagsForTabOrder];
	
	[self configureViewFromDataModel];
}


- (void)viewDidAppear:(BOOL)animated {
	
	if (self.isAddMode) {
		
		// Show keyboard on first entry field
		[self.membersTextField becomeFirstResponder];
	}
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


/*
 User hit keyboard return key
 */
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	
	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:textField andIsAddmode:self.isAddMode];
	
	return NO; // Do not perform default text-field behaviour
}


#
# pragma mark <DatePickerTextFieldDelegate>
#


- (void)dateChanged:(UIDatePicker*)sender {
	
	if (sender == self.timeDatePickerTextField.datePicker) {
		
		[self configureLocationWithDate:self.timeDatePickerTextField.date];
	}
}


#
# pragma mark Action Handlers
#


- (IBAction)backgroundTapped:(UITapGestureRecognizer*)sender {
	
	[self.view endEditing:YES];
}


- (IBAction)savePressed:(UIBarButtonItem*)sender {
	
	[self.view endEditing:YES];

	[self saveDataModelFromView];
	
	if (self.isAddMode) {
		
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
		
	} else {
		
		[self.navigationController popViewControllerAnimated:YES];
	}
}


- (IBAction)cancelPressed:(UIBarButtonItem*)sender {
	
	[self.view endEditing:YES];
	
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)isActiveValueChanged:(UISwitch*)sender {

	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:self.isAddMode];
}


- (IBAction)isMascotValueChanged:(UISwitch*)sender {

	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:self.isAddMode];
}


- (IBAction)isManualValueChanged:(UISwitch*)sender {

	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:self.isAddMode];
}


#
# pragma mark Helpers
#


- (void)configureTagsForTabOrder {

	// Dispatch
	self.isActiveSwitch.tag = 			0;
	self.rideCountLabel.tag = 			1;
	self.durationLabel.tag = 			2;
	self.distanceLabel.tag = 			3;
	self.donationsLabel.tag = 			4;
	
	// Team
	self.teamIDLabel.tag = 				5;
	self.membersTextField.tag = 		6;
	self.emailAddressTextField.tag =	7;
	self.phoneNumberTextField.tag = 	8;
	self.isMascotSwitch.tag = 			9;
	
	// Location
	self.timeDatePickerTextField.tag = 	10;
	self.addressTextField.tag = 		11;
	self.coordinatesLabel.tag = 		12;
	self.isManualSwitch.tag = 			13;
	
	// Notes
	self.notesTextView.tag = 			14;
}


- (void)configureViewFromDataModel {
	
	if (self.isAddMode) {
		
		self.teamIDLabel.text = [self nextTeamID];
		
	} else {
	
		[self loadDataModelIntoView];
		[self configureLocationWithDate:self.team.locationCurrentTime];
	}
}


- (void)configureLocationWithDate:(NSDate*)locationCurrentTime {

	// If location data stale, highlight with red italics
	if ([Util isStaleDate:locationCurrentTime]) {
		
		UIColor* colorStale = [UIColor redColor];
		
		// Location Time
		self.timeDatePickerTextField.font = [UIFont boldSystemFontOfSize:self.timeDatePickerTextField.font.pointSize];
		self.timeDatePickerTextField.textColor = colorStale;
		
		// Location Address
		self.addressTextField.font = [UIFont boldSystemFontOfSize:self.addressTextField.font.pointSize];
		self.addressTextField.textColor = colorStale;
		
		// Location Coordinates
		self.coordinatesLabel.font = [UIFont boldSystemFontOfSize:self.coordinatesLabel.font.pointSize];
		self.coordinatesLabel.textColor = colorStale;
		
	} else {
		
		// Location Time
		self.timeDatePickerTextField.font = [UIFont systemFontOfSize:self.timeDatePickerTextField.font.pointSize];
		self.timeDatePickerTextField.textColor = nil;
		
		// Location Address
		self.addressTextField.font = [UIFont systemFontOfSize:self.addressTextField.font.pointSize];
		self.addressTextField.textColor = nil;
		
		// Location Coordinates
		self.coordinatesLabel.font = [UIFont systemFontOfSize:self.coordinatesLabel.font.pointSize];
		self.coordinatesLabel.textColor = nil;
	}
}


- (void)loadDataModelIntoView {

	NSArray<Ride*>* sortedActiveRidesAssigned = [self.team getSortedActiveRidesAssigned];
	
	// Load navbar title
	self.title = [@"Team: " stringByAppendingString:[self.team getTitle]];
	
	// Load dispatch fields
	self.isActiveSwitch.on = self.team.isActive.boolValue;
	self.rideCountLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)sortedActiveRidesAssigned.count, (unsigned long)self.team.ridesAssigned.count];
	self.durationLabel.text = [NSString stringWithFormat:@"%.0f min", [self.team getDurationWithSortedActiveRidesAssigned:sortedActiveRidesAssigned] / (NSTimeInterval)SECONDS_PER_MINUTE];
	self.distanceLabel.text = [NSString stringWithFormat:@"%.1f km", [self.team getDistanceWithSortedActiveRidesAssigned:sortedActiveRidesAssigned] / (CLLocationDistance)METERS_PER_KILOMETER];
	self.donationsLabel.text =  [self.currencyNumberFormatter stringFromNumber:[self.team getDonationsAssigned]];
	
	// Load team fields
	self.teamIDLabel.text = self.team.teamID.stringValue;
	self.membersTextField.text = self.team.members;
	self.emailAddressTextField.text = self.team.emailAddress;
	self.phoneNumberTextField.text = self.team.phoneNumber;
	self.isMascotSwitch.on = self.team.isMascot.boolValue;
	
	// Load location fields
	self.timeDatePickerTextField.date = self.team.locationCurrentTime ?: [NSDate date];
	self.addressTextField.text = self.team.locationCurrentAddress;
	self.coordinatesLabel.text = [NSString stringWithFormat:@"(%.7f,%.7f)", self.team.locationCurrentLatitude.doubleValue, self.team.locationCurrentLongitude.doubleValue];
	self.isManualSwitch.on = self.team.locationCurrentIsManual.boolValue;
	
	// Load notes fields
	self.notesTextView.text = self.team.notes;
}


- (void)saveDataModelFromView {
	
	if (self.isAddMode) {
		
		self.team = [Team teamWithManagedObjectContext:[Util managedObjectContext]];
	}
	
	// Save dispatch fields
	self.team.isActive = @(self.isActiveSwitch.on);
	
	// Save team fields

	if (self.isAddMode) {
		
		self.team.teamID = @(self.teamIDLabel.text.integerValue);
	}
	self.team.members = [self.membersTextField.text trimAll];
	self.team.emailAddress = [self.emailAddressTextField.text trimAll];
	self.team.phoneNumber = [self.phoneNumberTextField.text trimAll];
	
	BOOL updatedMascot = NO;
	if (self.team.isMascot.boolValue != self.isMascotSwitch.on) {
		
		self.team.isMascot = @(self.isMascotSwitch.on);
		updatedMascot = YES;
	}
	
	// Save location field - try async geocode
	
	self.team.locationCurrentTime = self.timeDatePickerTextField.date;
	
	BOOL updatedLocation = NO;
	NSString* viewAddressString = [self.addressTextField.text trimAll];
	if (![NSString compareString:self.team.locationCurrentAddress toString:viewAddressString]) {
		
		Ride* firstSortedActiveRideAssigned = [self.team getSortedActiveRidesAssigned].firstObject;
		[firstSortedActiveRideAssigned clearPrepRoute];
		
		if (viewAddressString.length > 0) {
			
			[self.team tryUpdateCurrentLocationWithAddressString:viewAddressString
													 andGeocoder:self.geocoder
													   andSender:self]; // async
			
		} else {
			
			[self.team clearCurrentLocation];
			updatedLocation = YES;
		}
	}
	
	self.team.locationCurrentIsManual = @(self.isManualSwitch.on);
	
	// Save notes fields
	self.team.notes = [self.notesTextView.text trim];
	
	// Persist data model to store and notify observers
	[Util saveManagedObjectContext];
	if (self.isAddMode) {
		
		[self.team postNotificationCreatedWithSender:self];
		
	} else {
		
		[self.team postNotificationUpdatedWithSender:self
								  andUpdatedLocation:updatedLocation
									andUpdatedMascot:updatedMascot];
	}
}


@end
