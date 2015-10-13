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
	
	[self configureView];
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
		
		if ([string rangeOfCharacterFromSet:[NSCharacterSet nonPhoneNumberCharacterSet]].location != NSNotFound) return NO;
		
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


- (void)configureView {
	
	if (!self.isAddMode) {
		
		[self loadDataModelIntoView];
	}
}


- (void)loadDataModelIntoView {

	// Load navbar title
	self.title = [@"Team: " stringByAppendingString:[self.team getTitle]];
	
	// Load dispatch fields
	self.isActiveSwitch.on = self.team.isActive.boolValue;
	self.rideCountLabel.text = [NSString stringWithFormat:@"%d", (int)self.team.ridesAssigned.count];
	self.durationLabel.text = [NSString stringWithFormat:@"%.0f min", self.team.assignedDuration / (NSTimeInterval)SECONDS_PER_MINUTE];
	self.distanceLabel.text = [NSString stringWithFormat:@"%.1f km", self.team.assignedDistance / (CLLocationDistance)METERS_PER_KILOMETER];
	self.donationsLabel.text =  [self.currencyNumberFormatter stringFromNumber:self.team.assignedDonations];
	
	// Load team fields
	self.nameTextField.text = self.team.name;
	self.membersTextField.text = self.team.members;
	self.phoneNumberTextField.text = self.team.phoneNumber;
	self.isMascotSwitch.on = self.team.isMascot.boolValue;
	
	// Load location fields
	self.timeDatePickerTextField.date = self.team.locationCurrentTime;
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
	self.team.name = [self.nameTextField.text trimAll];
	self.team.members = [self.membersTextField.text trimAll];
	self.team.phoneNumber = [self.phoneNumberTextField.text trimAll];
	self.team.isMascot = @(self.isMascotSwitch.on);
	
	// Save location field - try async geocode
	
	self.team.locationCurrentTime = self.timeDatePickerTextField.date;
	
	BOOL updatedLocation = NO;
	NSString* viewAddressString = [self.addressTextField.text trimAll];
	if (![NSString compareString:self.team.locationCurrentAddress toString:viewAddressString]) {
		
		Ride* firstRideAssigned = [self.team getFirstRideAssigned];
		[firstRideAssigned clearPrepRoute];
		
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
		
		[self.team postNotificationUpdatedWithSender:self andUpdatedLocation:updatedLocation];
	}
}


@end
