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

	if (pickerView == self.teamAssignedPickerView) return 300;
	if (pickerView == self.passengerCountPickerView) return 35;
	if (pickerView == self.vehicleTransmissionPickerView) return 150;
	if (pickerView == self.seatBeltCountPickerView) return 35;
	
	return 0; // points
}


- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

	if (pickerView == self.teamAssignedPickerView) {
		
		if (row == 0) return @"- None -";
		
		Team* team = self.teamFetchedResultsController.fetchedObjects[row - 1];
		NSString* teamTitle = [team getTeamTitle];
		return (teamTitle && teamTitle.length > 0) ? teamTitle : TEAM_TITLE_DEFAULT;
	}
	
	if (pickerView == self.passengerCountPickerView) return [NSString stringWithFormat:@"%d", (int)row + 1];
	
	if (pickerView == self.vehicleTransmissionPickerView) {
		
		switch (row) {
				
			default:
			case 0:
			    return @"Automatic";
				
			case 1:
				return @"Manual";
		}
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
	[self.teamAssignedPickerView selectRow:(self.ride.teamAssigned ? 1 + [self.teamFetchedResultsController.fetchedObjects indexOfObject:self.ride.teamAssigned] : 0) inComponent:0 animated:NO]; // "None" at index 0
	
	// Load passenger fields
	self.firstNameTextField.text = self.ride.passengerNameFirst;
	self.lastNameTextField.text = self.ride.passengerNameLast;
	self.phoneNumberTextField.text = self.ride.passengerPhoneNumber;
	[self.passengerCountPickerView selectRow:self.ride.passengerCount.longValue inComponent:0 animated:NO];
	
	// Load location fields
	self.startAddressTextField.text = self.ride.locationStartAddress;
	self.endAddressTextField.text = self.ride.locationEndAddress;
	self.transferFromTextField.text = self.ride.locationTransferFrom;
	self.transferToTextField.text = self.ride.locationTransferTo;
	
	// Load vehicle fields
	self.vehicleDescriptionTextField.text = self.ride.vehicleDescription;
	[self.vehicleTransmissionPickerView selectRow:([self.ride.vehicleTransmission isEqualToString:@"Manual"] ? 1 : 0) inComponent:0 animated:NO]; // "Automatic" at index 0
	[self.seatBeltCountPickerView selectRow:self.ride.vehicleSeatBeltCount.longValue inComponent:0 animated:NO];
	
	// Load notes fields
	self.notesTextView.text = self.ride.notes;
	
	// Load time fields
	self.startTimeDatePicker.date = self.ride.dateTimeStart;
}


// Save ride data model from view fields
- (void)saveDataModelFromView {

	// Save dispatch fields
	self.ride.sourceName = self.sourceTextField.text;
	self.ride.donationAmount = self.donationTextField.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:self.donationTextField.text] : nil;

	// Save dispatch field: team assigned
	Team* existingTeamAssigned = self.ride.teamAssigned; // Maybe nil
	NSInteger selectedTeamRow = [self.teamAssignedPickerView selectedRowInComponent:0];
	Team* newteamAssigned = selectedTeamRow > 0 ? self.teamFetchedResultsController.fetchedObjects[selectedTeamRow - 1] : nil; // "None" at index 0
	BOOL updatedTeamAssigned = (existingTeamAssigned != newteamAssigned);
	if (updatedTeamAssigned) {

		// Remove team assigned, if present - notify observers
		if (existingTeamAssigned) {
			
			[existingTeamAssigned removeRidesAssignedObject:self.ride];
			[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:self userInfo:@{TEAM_ENTITY_NAME:existingTeamAssigned, TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY:[NSNumber numberWithBool:YES]}];
			self.ride.teamAssigned = nil; // NOTE: Likely redundant due to "smart" Core Data relationships
		}

		// Add team assigned, if present - notify observers
		if (newteamAssigned) {
			
			[newteamAssigned addRidesAssignedObject:self.ride];
			[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:self userInfo:@{TEAM_ENTITY_NAME:newteamAssigned, TEAM_UPDATED_RIDES_ASSIGNED_NOTIFICATION_KEY:[NSNumber numberWithBool:YES]}];
		}
		
		self.ride.teamAssigned = newteamAssigned;
	}
	
	// Save passenger fields
	self.ride.passengerNameFirst = self.firstNameTextField.text;
	self.ride.passengerNameLast = self.lastNameTextField.text;
	self.ride.passengerPhoneNumber = self.phoneNumberTextField.text;
	self.ride.passengerCount = [NSNumber numberWithLong:[self.passengerCountPickerView selectedRowInComponent:0]];
	
	// Save location fields
	// TODO: Validate locations via geocoding
	BOOL updatedLocationStart = ![self.ride.locationStartAddress isEqualToString:self.startAddressTextField.text];
	self.ride.locationStartAddress = self.startAddressTextField.text;
	BOOL updatedLocationEnd = ![self.ride.locationEndAddress isEqualToString:self.endAddressTextField.text];
	self.ride.locationEndAddress = self.endAddressTextField.text;
	self.ride.locationTransferFrom = self.transferFromTextField.text;
	self.ride.locationTransferTo = self.transferToTextField.text;
	
	// Save vehicle fields
	self.ride.vehicleDescription = self.vehicleDescriptionTextField.text;
	self.ride.vehicleTransmission = [self.vehicleTransmissionPickerView selectedRowInComponent:0] == 1 ? @"Manual" : @"Automatic";
	self.ride.vehicleSeatBeltCount = [NSNumber numberWithLong:[self.seatBeltCountPickerView selectedRowInComponent:0]];
	
	// Save notes fields
	self.ride.notes = self.notesTextView.text;
	
	// Save time fields
	self.ride.dateTimeStart = self.startTimeDatePicker.date;
	//	self.ride.dateTimeEnd = nil;
	[self.ride calculateDateTimeEnd];

	// Notify observers of updates to ride
	NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithDictionary:@{RIDE_ENTITY_NAME:self.ride}];
	if (updatedTeamAssigned) {
		userInfo[RIDE_UPDATED_TEAM_ASSIGNED_NOTIFICATION_KEY] = [NSNumber numberWithBool:YES];
	}
	if (updatedLocationStart) {
		userInfo[RIDE_UPDATED_LOCATION_START_NOTIFICATION_KEY] = [NSNumber numberWithBool:YES];
	}
	if (updatedLocationEnd) {
		userInfo[RIDE_UPDATED_LOCATION_END_NOTIFICATION_KEY] = [NSNumber numberWithBool:YES];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:RIDE_UPDATED_NOTIFICATION_NAME object:self userInfo:userInfo];
	
	// Persist data model to disk
	[RideDetailTableViewController saveManagedObjectContext];
}


+ (void)saveManagedObjectContext {
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate saveManagedObjectContext];
}


@end
