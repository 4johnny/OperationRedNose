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

	if (pickerView == self.teamAssignedPickerView) return self.teamFetchedResultsController.fetchedObjects.count;
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
		
		Team* team = self.teamFetchedResultsController.fetchedObjects[row];
		NSString* teamTitle = [team getTeamTitle];
		return (teamTitle && teamTitle.length > 0) ? teamTitle : @"<Unidentified Team>";
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
//		[attributedTitle addAttribute:NSParagraphStyleAttributeName value:mutableParagraphStyle range:NSMakeRange(0,title.length)];
		
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
	
	if (self.ride.teamAssigned) {
		
		NSUInteger row = [self.teamFetchedResultsController.fetchedObjects indexOfObject:self.ride.teamAssigned];
		[self.teamAssignedPickerView selectRow:row inComponent:0 animated:NO];
	}
	
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
	NSInteger selectedTeamRow = [self.teamAssignedPickerView selectedRowInComponent:0];
	self.ride.teamAssigned = self.teamFetchedResultsController.fetchedObjects[selectedTeamRow];
	
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
