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

#define DONATION_TEXT_LENGTH_MAX	8 // NOTE: Arbitrary limit to ensure number fits in NSDecimal
#define DONATION_TEXT_DECIMAL_COUNT	2

#define DATE_PICKER_LOCALE				@"en_CA"
#define DATE_PICKER_DATETIME_FORMAT		@"EEE MMM dd HH:mm"

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
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TEAM_ENTITY_NAME];
	fetchRequest.sortDescriptors =
	@[
	  [NSSortDescriptor sortDescriptorWithKey:TEAM_FETCH_SORT_KEY1 ascending:TEAM_FETCH_SORT_ASCENDING],
	  [NSSortDescriptor sortDescriptorWithKey:TEAM_FETCH_SORT_KEY2 ascending:TEAM_FETCH_SORT_ASCENDING]
	  ];
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

	// Extend edge "under bottom bars" to improve aesthetics when popping view controller
	// NOTE: Done manually so that storyboard easier to design with
	self.edgesForExtendedLayout = UIRectEdgeBottom;
	
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
			if (decimalNumbers.length > DONATION_TEXT_DECIMAL_COUNT) return NO;
		}
	}
	
	return YES;
}


/*
 User hit keyboard return key
 */
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	
	// Remove focus and keyboard
	[textField resignFirstResponder];

	return NO; // Do not perform default text-field behaviour
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
	
	[self configureTeamAssignedPickerTextField];
	[self configureStartTimeDatePickerTextField];
	
	[self loadDataModelIntoView];
}


- (void)configureTeamAssignedPickerTextField {

	NSMutableArray* teamTitles = [NSMutableArray arrayWithCapacity:self.teamFetchedResultsController.fetchedObjects.count + 1];
	
	[teamTitles addObject:TEAM_TITLE_NONE];
	
	for (Team* team in self.teamFetchedResultsController.fetchedObjects) {
		
		[teamTitles addObject:[team getTitle]];
	}
	
	self.teamAssignedPickerTextField.titles = teamTitles;
}


/*
 Constrain start-time date picker
 */
- (void)configureStartTimeDatePickerTextField {

	// Basic config
	self.startTimeDatePickerTextField.minuteInterval = TIME_MINUTE_INTERVAL;
	self.startTimeDatePickerTextField.locale = [NSLocale localeWithLocaleIdentifier:DATE_PICKER_LOCALE];
	self.startTimeDatePickerTextField.dateFormat = DATE_PICKER_DATETIME_FORMAT;
	
	// Get date-time for now
	NSDate* now = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	
	// Minimum date-time is one day before now
	NSCalendar* currentCalendar = [NSCalendar currentCalendar];
	NSDateComponents* offsetComponents = [[NSDateComponents alloc] init];
	offsetComponents.day = -1;
	self.startTimeDatePickerTextField.minimumDate = [currentCalendar dateByAddingComponents:offsetComponents toDate:now options:0];
	
	// Maximum date-time is one day from now
	offsetComponents.day = 1;
	self.startTimeDatePickerTextField.maximumDate = [currentCalendar dateByAddingComponents:offsetComponents toDate:now options:0];
}


// Load ride data model into view fields
- (void)loadDataModelIntoView {
	
	// Load dispatch fields
	self.startTimeDatePickerTextField.date = self.ride.dateTimeStart;
	self.teamAssignedPickerTextField.selectedRow = self.ride.teamAssigned ? [self.teamFetchedResultsController.fetchedObjects indexOfObject:self.ride.teamAssigned] + 1 : 0; // "None" at index 0
	self.sourceTextField.text = self.ride.sourceName;
	self.donationTextField.text = self.ride.donationAmount ? self.ride.donationAmount.stringValue : @"";
	
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
	self.seatBeltCountSegmentedControl.selectedSegmentIndex = self.ride.vehicleSeatBeltCount.integerValue;
	
	// Load notes fields
	self.notesTextView.text = self.ride.notes;
}


// Save ride data model from view fields
- (void)saveDataModelFromView {
	
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
	self.ride.sourceName = [self.sourceTextField.text trim];
	self.ride.donationAmount = self.donationTextField.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:self.donationTextField.text] : nil;
	
	// Save passenger fields
	self.ride.passengerNameFirst = [self.firstNameTextField.text trimAll];
	self.ride.passengerNameLast = [self.lastNameTextField.text trimAll];
	self.ride.passengerPhoneNumber = [self.phoneNumberTextField.text trimAll];
	self.ride.passengerCount = [NSNumber numberWithLong:self.passengerCountSegmentedControl.selectedSegmentIndex + 1];
	
	// Save location fields - try async geocode
	BOOL updatedLocationStart = NO;
	NSString* viewAddressString = [self.startAddressTextField.text trimAll];
	if (![NSString compareString:self.ride.locationStartAddress toString:viewAddressString]) {
		
		[self.ride clearMainRoute];
		[self.ride clearPrepRoute];
		
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
		
		[self.ride clearMainRoute];
		
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
	self.ride.vehicleSeatBeltCount = [NSNumber numberWithInteger:self.seatBeltCountSegmentedControl.selectedSegmentIndex];
	
	// Save notes fields
	self.ride.notes = [self.notesTextView.text trimAll];
	
	// Persist data model to store and notify observers
	[Util saveManagedObjectContext];
	[self.ride postNotificationUpdatedWithSender:self andUpdatedLocationStart:updatedLocationStart andUpdatedLocationEnd:updatedLocationEnd andUpdatedTeamAssigned:updatedTeamAssigned];
}


@end
