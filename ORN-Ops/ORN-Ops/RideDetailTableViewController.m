//
//  RideDetailTableViewController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "RideDetailTableViewController.h"
#import "Team+TeamHelpers.h"


#
# pragma mark - Constants
#

#define PHONE_TEXT_LENGTH_MAX	10

#define DONATION_TEXT_LENGTH_MAX	8 // NOTE: Arbitrary limit to ensure number fits in NSDecimalNumber
#define DONATION_TEXT_DECIMAL_COUNT	2

#
# pragma mark - Interface
#

@interface RideDetailTableViewController ()

#
# pragma mark Properties
#

@property (nonatomic, getter=isAddMode) BOOL addMode;

@property (strong, nonatomic) NSFetchedResultsController* teamFetchedResultsController;

@property (nonatomic) CLGeocoder* geocoder1;
@property (nonatomic) CLGeocoder* geocoder2;
@property (nonatomic) CLGeocoder* geocoder3;

@end


#
# pragma mark - Implementation
#


@implementation RideDetailTableViewController


#
# pragma mark Property Accessors
#


- (NSFetchedResultsController*)teamFetchedResultsController {
	
	if (_teamFetchedResultsController) return _teamFetchedResultsController;
	
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TEAM_ENTITY_NAME];
	fetchRequest.sortDescriptors =
	@[
	  [NSSortDescriptor sortDescriptorWithKey:TEAM_FETCH_SORT_KEY1 ascending:TEAM_FETCH_SORT_ASC1],
	  [NSSortDescriptor sortDescriptorWithKey:TEAM_FETCH_SORT_KEY2 ascending:TEAM_FETCH_SORT_ASC2],
	  ];
	
	_teamFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[Util managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
	_teamFetchedResultsController.delegate = self;
	
	NSError* error = nil;
	if (![_teamFetchedResultsController performFetch:&error]) {
		
		NSLog(@"Unresolved error: %@, %@", error, error.userInfo);
	}

	return _teamFetchedResultsController;
}


- (CLGeocoder*)geocoder1 {
	
	if (_geocoder1) return _geocoder1;
	
	_geocoder1 = [[CLGeocoder alloc] init];
	
	return _geocoder1;
}


- (CLGeocoder*)geocoder2 {
	
	if (_geocoder2) return _geocoder2;
	
	_geocoder2 = [[CLGeocoder alloc] init];
	
	return _geocoder2;
}


- (CLGeocoder*)geocoder3 {
	
	if (_geocoder3) return _geocoder3;
	
	_geocoder3 = [[CLGeocoder alloc] init];
	
	return _geocoder3;
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
	self.addMode = (self.ride == nil);
	if (self.isAddMode) {
		
		// Replace "save" button with "add"
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(savePressed:)];
	}
	
	[self configureTagsForTabOrder];

	[self configureForPhoneWithSize:self.view.frame.size];
	
	[self configureViewFromDataModel];
}


- (void)viewDidAppear:(BOOL)animated {

	if (self.isAddMode) {
	
		// Show keyboard on first entry field
		[self.startTimeDatePickerTextField becomeFirstResponder];
	}
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
	NSLog(@"Warning: Memory Low");
}



#
# pragma mark <UIContentContainer>
#


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

	[self configureForPhoneWithSize:size];
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
		
	} else if (textField == self.donationTextField) {
		
		// Reject replacement string exceeding max length
		// NOTE: Optimization to avoid further checks below
		if (string.length > DONATION_TEXT_LENGTH_MAX) return NO;
		
		// Reject non-monetary chars
		if ([string rangeOfCharacterFromSet:[NSCharacterSet monetaryCharacterSetInverted]].location != NSNotFound) return NO;
		
		// Reject more than one decimal-point char
		if ([string containsString:@"."] && [textField.text containsString:@"."]) return NO;
		
		// Reject resulting string exceeding max length
		NSMutableString* newString = [textField.text mutableCopy];
		[newString replaceCharactersInRange:range withString:string];
		if (newString.length > DONATION_TEXT_LENGTH_MAX) return NO;
		
		// Reject more than two decimal places
		NSRange range = [newString rangeOfString:@"."];
		if (range.location != NSNotFound) {
			NSString* decimalNumbers = [newString substringFromIndex:range.location + 1];
			if (decimalNumbers.length > DONATION_TEXT_DECIMAL_COUNT) return NO;
		}
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
# pragma mark <UIPickerViewDelegate>
#


- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	if (pickerView == self.teamAssignedPickerTextField.pickerView) {
		
		if (row == 0) { // None
			
			// Change status to New
			self.statusSegmentedControl.selectedSegmentIndex = 0;
			
		} else {
			
			if (row == self.teamAssignedPickerTextField.initialSelectedRow && ![self.ride isPreDispatch]) {
				
				// Reset status to data model
				self.statusSegmentedControl.selectedSegmentIndex = self.ride.status.integerValue - 1;
				
			} else {
				
				// Change status to Assigned
				self.statusSegmentedControl.selectedSegmentIndex = 1;
			}
		}
	}
}


#
# pragma mark <NSFetchedResultsControllerDelegate>
#


- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
	
	// NOTE: Even if method is empty, at least one protocol method must be implemented for fetch-results controller to track changes
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


- (IBAction)statusValueChanged:(UISegmentedControl*)sender {
	
	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:self.isAddMode];
}


- (IBAction)passengerCountValueChanged:(UISegmentedControl*)sender {

	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:self.isAddMode];
}


- (IBAction)transmissionValueChanged:(UISegmentedControl*)sender {
	
	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:self.isAddMode];
}


- (IBAction)seatBeltCountValueChanged:(UISegmentedControl*)sender {
	
	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:self.isAddMode];
}


#
# pragma mark Helpers
#


- (void)configureTagsForTabOrder {

	// Dispatch
	self.statusSegmentedControl.tag =				0;
	self.startTimeDatePickerTextField.tag =			1;
	self.teamAssignedPickerTextField.tag =			2;
	self.sourceTextField.tag =						3;
	self.donationTextField.tag =					4;
	
	// Passenger
	self.firstNameTextField.tag =					5;
	self.lastNameTextField.tag =					6;
	self.phoneNumberTextField.tag =					7;
	self.passengerCountSegmentedControl.tag =		8;
	
	// Location
	self.startAddressTextField.tag =				9;
	self.endAddressTextField.tag =					10;
	self.transferFromTextField.tag =				11;
	self.transferToTextField.tag =					12;
	
	// Vehicle
	self.vehicleDescriptionTextField.tag =			13;
	self.vehicleTransmissionSegmentedControl.tag =	14;
	self.seatBeltCountSegmentedControl.tag =		15;
	
	// Notes
	self.notesTextView.tag =						16;
}


- (void)configureForPhoneWithSize:(CGSize)size {
	
	if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPhone) return;

	if (size.width < 667) {
		
		// Set font size for segmented controls
		[self.statusSegmentedControl setTitleTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12.5] } forState:UIControlStateNormal];
		
		[self.statusSegmentedControl setTitle:RIDE_STATUS_STRING_SHORT_NEW forSegmentAtIndex:0];
		[self.statusSegmentedControl setTitle:RIDE_STATUS_STRING_SHORT_ASSIGNED forSegmentAtIndex:1];
		[self.statusSegmentedControl setTitle:RIDE_STATUS_STRING_SHORT_DISPATCHED forSegmentAtIndex:2];
		[self.statusSegmentedControl setTitle:RIDE_STATUS_STRING_SHORT_TRANSPORTING forSegmentAtIndex:3];
		[self.statusSegmentedControl setTitle:RIDE_STATUS_STRING_SHORT_COMPLETED forSegmentAtIndex:4];
		[self.statusSegmentedControl setTitle:RIDE_STATUS_STRING_SHORT_CANCELLED forSegmentAtIndex:5];
		
	} else {
		
		// Set font size for segmented controls
		[self.statusSegmentedControl setTitleTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:13] } forState:UIControlStateNormal];
		
		[self.statusSegmentedControl setTitle:RIDE_STATUS_STRING_NEW forSegmentAtIndex:0];
		[self.statusSegmentedControl setTitle:RIDE_STATUS_STRING_ASSIGNED forSegmentAtIndex:1];
		[self.statusSegmentedControl setTitle:RIDE_STATUS_STRING_DISPATCHED forSegmentAtIndex:2];
		[self.statusSegmentedControl setTitle:RIDE_STATUS_STRING_TRANSPORTING forSegmentAtIndex:3];
		[self.statusSegmentedControl setTitle:RIDE_STATUS_STRING_COMPLETED forSegmentAtIndex:4];
		[self.statusSegmentedControl setTitle:RIDE_STATUS_STRING_CANCELLED forSegmentAtIndex:5];
	}
}


- (void)configureTeamAssignedPickerTextField {
	
	NSUInteger numberOfTitles = self.teamFetchedResultsController.fetchedObjects.count;
	
	NSMutableArray<NSString*>* teamTitles = [NSMutableArray arrayWithCapacity:(numberOfTitles + 1)];
	NSMutableArray<NSNumber*>* teamPickableStatuses = [NSMutableArray arrayWithCapacity:(numberOfTitles + 1)];
	
	[teamTitles addObject:TEAM_TITLE_NONE];
	[teamPickableStatuses addObject:@YES];
	
	for (Team* team in self.teamFetchedResultsController.fetchedObjects) {
		
		[teamTitles addObject:[team getTitle]];
		[teamPickableStatuses addObject:team.isActive];
	}
	
	self.teamAssignedPickerTextField.titles = teamTitles;
	self.teamAssignedPickerTextField.pickableStatuses = teamPickableStatuses;
}


- (void)configureViewFromDataModel {
	
	[self configureTeamAssignedPickerTextField];
	
	if (!self.isAddMode) {
		
		[self loadDataModelIntoView];
	}
}


- (void)loadDataModelIntoView {
	
	// Load navbar title
	self.title = [@"Ride: " stringByAppendingString:[self.ride getTitle]];
	
	// Load dispatch fields
	self.statusSegmentedControl.selectedSegmentIndex = self.ride.status.integerValue - 1;
	self.startTimeDatePickerTextField.date = self.ride.dateTimeStart;
	self.teamAssignedPickerTextField.selectedRow = self.ride.teamAssigned ? [self.teamFetchedResultsController.fetchedObjects indexOfObject:self.ride.teamAssigned] + 1 : 0; // "None" at index 0
	self.sourceTextField.text = self.ride.sourceName;
	self.donationTextField.text = self.ride.donationAmount ? self.ride.donationAmount.stringValue : @"";
	
	// Load passenger fields
	self.firstNameTextField.text = self.ride.passengerNameFirst;
	self.lastNameTextField.text = self.ride.passengerNameLast;
	self.phoneNumberTextField.text = self.ride.passengerPhoneNumber;
	self.passengerCountSegmentedControl.selectedSegmentIndex = self.ride.passengerCount.integerValue - 1;
	
	// Load location fields
	self.startAddressTextField.text = self.ride.locationStartAddress;
	self.endAddressTextField.text = self.ride.locationEndAddress;
	self.transferFromTextField.text = self.ride.locationTransferFrom;
	self.transferToTextField.text = self.ride.locationTransferTo;
	
	// Load vehicle fields
	self.vehicleDescriptionTextField.text = self.ride.vehicleDescription;
	self.vehicleTransmissionSegmentedControl.selectedSegmentIndex = self.ride.vehicleTransmission.integerValue == VehicleTransmission_Manual ? 1 : 0; // enum VehicleTransmission
	self.seatBeltCountSegmentedControl.selectedSegmentIndex = self.ride.vehicleSeatBeltCount.integerValue;
	
	// Load notes fields
	self.notesTextView.text = self.ride.notes;
}


- (void)saveDataModelFromView {
	
	if (self.isAddMode) {
		
		self.ride = [Ride rideWithManagedObjectContext:[Util managedObjectContext]];
	}
	
	// Save dispatch field: ride status
	BOOL needsUpdateTeamAssignedLocation = NO;
	RideStatus newStatus = self.statusSegmentedControl.selectedSegmentIndex + 1;
	BOOL updatedStatus = (self.ride.status.integerValue != newStatus);
	if (updatedStatus) {
		
		if (self.ride == [self.ride.teamAssigned getSortedActiveRidesAssigned].firstObject) {
		
			needsUpdateTeamAssignedLocation = YES;
		}
		
		self.ride.status = @(newStatus);

		if (self.ride == [self.ride.teamAssigned getSortedActiveRidesAssigned].firstObject) {
			
			needsUpdateTeamAssignedLocation = YES;
		}
		
		if (needsUpdateTeamAssignedLocation) {
			
			[self.ride.teamAssigned tryUpdateActiveAssignedRideRoutesWithSender:self];
		}
	}
	
	// Save dispatch field: start time - try async calculate route
	if (![NSDate compareDate:self.ride.dateTimeStart toDate:self.startTimeDatePickerTextField.date]) {
		
		self.ride.dateTimeStart = self.startTimeDatePickerTextField.date;
		[self.ride clearMainRoute];
		[self.ride tryUpdateMainRouteWithSender:self]; // async
	}
	
	// Save dispatch field: team assigned
	Team* existingTeamAssigned = self.ride.teamAssigned; // Maybe nil
	Team* newTeamAssigned = self.teamAssignedPickerTextField.selectedRow > 0 ? self.teamFetchedResultsController.fetchedObjects[self.teamAssignedPickerTextField.selectedRow - 1] : nil; // "None" at index 0
	BOOL updatedTeamAssigned = (existingTeamAssigned != newTeamAssigned);
	if (updatedTeamAssigned) {
		
		// Assign team to ride, including route recalculations and notifications
		[self.ride assignTeam:newTeamAssigned withSender:self];
	}
	
	// Save other dispatch fields
	self.ride.sourceName = [self.sourceTextField.text trimAll];
	self.ride.donationAmount = self.donationTextField.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:self.donationTextField.text] : nil;
	
	// Save passenger fields
	self.ride.passengerNameFirst = [self.firstNameTextField.text trimAll];
	self.ride.passengerNameLast = [self.lastNameTextField.text trimAll];
	self.ride.passengerPhoneNumber = [self.phoneNumberTextField.text trimAll];
	self.ride.passengerCount = @(self.passengerCountSegmentedControl.selectedSegmentIndex + 1);
	
	// Save location fields - try async geocode
	
	BOOL updatedLocationStart = NO;
	NSString* newLocationStartAddress = [self.startAddressTextField.text trimAll];
	if ([NSString compareString:self.ride.locationStartAddress toString:newLocationStartAddress]) {
		
		if (needsUpdateTeamAssignedLocation) {

			[self.ride tryUpdateTeamAssignedLocationWithRideLocationType:RideLocationType_Start
															 andGeocoder:self.geocoder1
															   andSender:self];
		}
		
	} else {
	
		[self.ride clearPrepRoute];
		[self.ride clearMainRoute];
		
		if (newLocationStartAddress.length > 0) {
			
			[self.ride tryUpdateLocationWithAddressString:newLocationStartAddress
									  andRideLocationType:RideLocationType_Start
					   andNeedsUpdateTeamAssignedLocation:needsUpdateTeamAssignedLocation
											  andGeocoder:self.geocoder2
												andSender:self]; // async
			
		} else {
			
			[self.ride clearLocationWithRideLocationType:RideLocationType_Start];
			updatedLocationStart = YES;
		}
	}
	
	BOOL updatedLocationEnd = NO;
	NSString* newLocationEndAddress = [self.endAddressTextField.text trimAll];
	if ([NSString compareString:self.ride.locationEndAddress toString:newLocationEndAddress]) {
		
		if (needsUpdateTeamAssignedLocation) {
			
			[self.ride tryUpdateTeamAssignedLocationWithRideLocationType:RideLocationType_End
															 andGeocoder:self.geocoder3
															   andSender:self];
		}
		
	} else {
	
		[self.ride clearMainRoute];
		
		if (newLocationEndAddress.length > 0) {
			
			[self.ride tryUpdateLocationWithAddressString:newLocationEndAddress
									  andRideLocationType:RideLocationType_End
					   andNeedsUpdateTeamAssignedLocation:needsUpdateTeamAssignedLocation
											  andGeocoder:self.geocoder3
												andSender:self]; // async
			
		} else {
			
			[self.ride clearLocationWithRideLocationType:RideLocationType_End];
			updatedLocationEnd = YES;
		}
	}
	self.ride.locationTransferFrom = [self.transferFromTextField.text trimAll];
	self.ride.locationTransferTo = [self.transferToTextField.text trimAll];
	
	// Save vehicle fields
	self.ride.vehicleDescription = [self.vehicleDescriptionTextField.text trimAll];
	self.ride.vehicleTransmission = @(self.vehicleTransmissionSegmentedControl.selectedSegmentIndex + 1); // enum VehicleTransmission
	self.ride.vehicleSeatBeltCount = @(self.seatBeltCountSegmentedControl.selectedSegmentIndex);
	
	// Save notes fields
	self.ride.notes = [self.notesTextView.text trim];
	
	// Persist data model to store and notify observers
	[Util saveManagedObjectContext];
	if (self.isAddMode) {
		
		[self.ride postNotificationCreatedWithSender:self];
		
	} else {
		
		[self.ride postNotificationUpdatedWithSender:self
							 andUpdatedLocationStart:updatedLocationStart
							   andUpdatedLocationEnd:updatedLocationEnd
							  andUpdatedTeamAssigned:updatedTeamAssigned];
	}
}


@end
