//
//  RideDetailTableViewController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "RideDetailTableViewController.h"
#import "AppDelegate.h"
#import "Team+TeamHelpers.h"


#
# pragma mark - Constants
#

#define DONATION_TEXT_LENGTH_MAX	8 // NOTE: Limit to ensure number fits in NSDecimal


#
# pragma mark Data Model Constants
#

#define TEAM_FETCH_SORT_KEY			@"name"
#define TEAM_FETCH_SORT_ASCENDING	YES


#
# pragma mark - Interface
#

@interface RideDetailTableViewController ()

#
# pragma mark Properties
#

@property (strong, nonatomic) NSFetchedResultsController* teamFetchedResultsController;

@property (nonatomic) CLGeocoder* geocoder;
@property (nonatomic) UIAlertController* okAlertController;

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
	
	// Create fetch request for teams
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TEAM_ENTITY_NAME];
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:TEAM_FETCH_SORT_KEY ascending:TEAM_FETCH_SORT_ASCENDING]];
	//fetchRequest.predicate = [NSPredicate predicateWithFormat:@"movie.id == %@", self.movie.id];
	//fetchRequest.fetchBatchSize = PAGE_LIMIT;
	//fetchRequest.fetchLimit = PAGE_LIMIT;
	
	// NOTE: nil for section name key path means "no sections"
	_teamFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.ride.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	_teamFetchedResultsController.delegate = self;
	
	NSError *error = nil;
	if ([_teamFetchedResultsController performFetch:&error]) return _teamFetchedResultsController;
	
	// TODO: Replace this with code to handle the error appropriately.
	// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	NSLog(@"Unresolved error %@, %@", error, error.userInfo);
	abort();
	
	return _teamFetchedResultsController;
}


- (CLGeocoder*)geocoder {
	
	if (_geocoder) return _geocoder;
	
	_geocoder = [[CLGeocoder alloc] init];
	
	return _geocoder;
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
	
	if (pickerView == self.teamAssignedPickerView) return self.teamFetchedResultsController.fetchedObjects.count + 1;
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
	
	if (pickerView == self.teamAssignedPickerView) return 300;
	if (pickerView == self.seatBeltCountPickerView) return 35;
	
	return 0; // points
}


- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	if (pickerView == self.teamAssignedPickerView) {
		
		if (row == 0) return TEAM_TITLE_NONE;
		
		Team* team = self.teamFetchedResultsController.fetchedObjects[row - 1];
		
		return [team getTitle];
	}
	
	if (pickerView == self.seatBeltCountPickerView) return [NSString stringWithFormat:@"%d", (int)row];
	
	return nil;
}


- (NSAttributedString*)pickerView:(UIPickerView*)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	if (pickerView == self.teamAssignedPickerView) {
		
		// Left-align team titles
		NSString* title = [self pickerView:pickerView titleForRow:row forComponent:component];
		NSMutableParagraphStyle* mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
		mutableParagraphStyle.alignment = NSTextAlignmentLeft;
		NSMutableAttributedString* attributedTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSParagraphStyleAttributeName:mutableParagraphStyle}];
		
		return attributedTitle;
	}
	
	return nil; // NOTE: Falls back to "pickerView:titleForRow:forComponent:"
}


/*
 - (UIView*)pickerView:(UIPickerView*)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView*)view {
	
	return view;
 }
 */


#
# pragma mark <UITextFieldDelegate>
#


- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
	
	// NOTE: String may be typed or pasted
	// NOTE: Cannot rely on keyboards to constrain input char types, since different devices show different keyboards for same text field
	
	// If replacement string empty, we are done
	if (string.length <= 0) return YES;
	
	// Donation field should conform to monetary format
	if (textField == self.donationTextField) {
		
		// Reject replacement string exceeding max length
		// NOTE: Optimization to avoid further checks below
		if (string.length > DONATION_TEXT_LENGTH_MAX) return NO;
		
		// Reject non-decimal chars
		NSCharacterSet* nonDecimalSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."].invertedSet;
		if ([string rangeOfCharacterFromSet:nonDecimalSet].location != NSNotFound) return NO;
		
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
			if (decimalNumbers.length > 2) return NO;
		}
	}
	
	return YES;
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
- (void)loadDataModelIntoView {
	
	// Load dispatch fields
	self.sourceTextField.text = self.ride.sourceName;
	self.donationTextField.text = self.ride.donationAmount ? self.ride.donationAmount.stringValue : @"";
	[self.teamAssignedPickerView selectRow:(self.ride.teamAssigned ? [self.teamFetchedResultsController.fetchedObjects indexOfObject:self.ride.teamAssigned] + 1 : 0) inComponent:0 animated:NO]; // "None" at index 0
	
	// Load passenger fields
	self.firstNameTextField.text = self.ride.passengerNameFirst;
	self.lastNameTextField.text = self.ride.passengerNameLast;
	self.phoneNumberTextField.text = self.ride.passengerPhoneNumber;
	self.passengerCountSegmentedControl.selectedSegmentIndex = self.ride.passengerCount.longValue - 1;
	
	// Load location fields
	self.startAddressTextField.text = self.ride.locationStartAddress;
	self.endAddressTextField.text = self.ride.locationEndAddress;
	self.transferFromTextField.text = self.ride.locationTransferFrom;
	self.transferToTextField.text = self.ride.locationTransferTo;
	
	// Load vehicle fields
	self.vehicleDescriptionTextField.text = self.ride.vehicleDescription;
	self.vehicleTransmissionSegmentedControl.selectedSegmentIndex = self.ride.vehicleTransmission.integerValue == VehicleTransmission_Manual ? 1 : 0; // enum VehicleTransmission
	[self.seatBeltCountPickerView selectRow:self.ride.vehicleSeatBeltCount.longValue inComponent:0 animated:NO];
	
	// Load notes fields
	self.notesTextView.text = self.ride.notes;
	
	// Load time fields
	self.startTimeDatePicker.date = self.ride.dateTimeStart;
}


// Save ride data model from view fields
- (void)saveDataModelFromView {
	
	// Save dispatch fields
	self.ride.sourceName = [self.sourceTextField.text trim];
	self.ride.donationAmount = self.donationTextField.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:self.donationTextField.text] : nil;
	
	// Save dispatch field: team assigned
	Team* existingTeamAssigned = self.ride.teamAssigned; // Maybe nil
	NSInteger selectedTeamRow = [self.teamAssignedPickerView selectedRowInComponent:0];
	Team* newTeamAssigned = selectedTeamRow > 0 ? self.teamFetchedResultsController.fetchedObjects[selectedTeamRow - 1] : nil; // "None" at index 0
	BOOL updatedTeamAssigned = (existingTeamAssigned != newTeamAssigned);
	if (updatedTeamAssigned) {
		
		// Remove ride from existing team assigned, if present - notify observers
		if (existingTeamAssigned) {
			
			[existingTeamAssigned removeRidesAssignedObject:self.ride];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:self userInfo:@{TEAM_ENTITY_NAME : existingTeamAssigned, TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY : [NSNumber numberWithBool:YES]}];
		}
		
		// Add ride to new team assigned, if present - notify observers
		if (newTeamAssigned) {
			
			[newTeamAssigned addRidesAssignedObject:self.ride];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:self userInfo:@{TEAM_ENTITY_NAME : newTeamAssigned, TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY : [NSNumber numberWithBool:YES]}];
		}
		
		// Add new team assigned to ride
		self.ride.teamAssigned = newTeamAssigned;
	}
	
	// Save passenger fields
	self.ride.passengerNameFirst = [self.firstNameTextField.text trimAll];
	self.ride.passengerNameLast = [self.lastNameTextField.text trimAll];
	self.ride.passengerPhoneNumber = [self.phoneNumberTextField.text trimAll];
	self.ride.passengerCount = [NSNumber numberWithLong:self.passengerCountSegmentedControl.selectedSegmentIndex + 1];
	
	// Save location fields - try async geocode
	BOOL updatedLocationStart = NO;
	NSString* viewAddressString = [self.startAddressTextField.text trimAll];
	if (![NSString compareString:self.ride.locationStartAddress toString:viewAddressString]) {
		
		[self.ride clearRoute];
		
		if (viewAddressString.length > 0) {
			
			[self.ride tryUpdateLocationWithAddressString:viewAddressString andRideLocationType:RideLocationType_Start andGeocoder:self.geocoder andSender:self]; // async
			
		} else {
			
			[self.ride clearLocationWithRideLocationType:RideLocationType_Start];
			updatedLocationStart = YES;
		}
	}
	BOOL updatedLocationEnd = NO;
	viewAddressString = [self.endAddressTextField.text trimAll];
	if (![NSString compareString:self.ride.locationEndAddress toString:viewAddressString]) {
		
		[self.ride clearRoute];
		
		if (viewAddressString.length > 0) {
			
			[self.ride tryUpdateLocationWithAddressString:viewAddressString andRideLocationType:RideLocationType_End andGeocoder:self.geocoder andSender:self]; // async
			
		} else {
			
			[self.ride clearLocationWithRideLocationType:RideLocationType_End];
			updatedLocationEnd = YES;
		}
	}
	self.ride.locationTransferFrom = [self.transferFromTextField.text trimAll];
	self.ride.locationTransferTo = [self.transferToTextField.text trimAll];
	
	// Save vehicle fields
	self.ride.vehicleDescription = [self.vehicleDescriptionTextField.text trimAll];
	self.ride.vehicleTransmission = [NSNumber numberWithInteger:self.vehicleTransmissionSegmentedControl.selectedSegmentIndex + 1]; // enum VehicleTransmission
	self.ride.vehicleSeatBeltCount = [NSNumber numberWithInteger:[self.seatBeltCountPickerView selectedRowInComponent:0]];
	
	// Save notes fields
	self.ride.notes = [self.notesTextView.text trimAll];
	
	// Save time fields - try async calculate route duration
	if (![Util compareDate:self.ride.dateTimeStart toDate:self.startTimeDatePicker.date]) {
		
		self.ride.dateTimeStart = self.startTimeDatePicker.date;
		self.ride.routeDuration = nil;
		[self.ride tryUpdateRouteDurationWithSender:self]; // async
	}

	// Persist data model to disk and notify observers
	[Util saveManagedObjectContext];
	[self.ride postNotificationUpdatedWithSender:self andUpdatedLocationStart:updatedLocationStart andUpdatedLocationEnd:updatedLocationEnd andUpdatedTeamAssigned:updatedTeamAssigned];
}


@end
