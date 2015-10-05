//
//  TeamDetailTableViewController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "TeamDetailTableViewController.h"


#
# pragma mark - Interface
#

@interface TeamDetailTableViewController ()

#
# pragma mark Properties
#

@property (nonatomic, getter=isAddMode) BOOL addMode;

@property (nonatomic) NSNumberFormatter* currencyNumberFormatter;

@end


#
# pragma mark - Implementation
#


@implementation TeamDetailTableViewController


#
# pragma mark Property Accessors
#


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
# pragma mark Action Handlers
#


- (IBAction)backgroundTapped:(UITapGestureRecognizer*)sender {
	
	[self.view endEditing:YES];
}


- (IBAction)savePressed:(UIBarButtonItem*)sender {
	
	[self.view endEditing:YES];

	//	[TeamDetailTableViewController saveManagedObjectContext];
	[self.navigationController popViewControllerAnimated:YES];
}


#
# pragma mark Helpers
#


- (void)configureView {
	
	self.title = [@"Team: " stringByAppendingString:[self.team getTitle]];
	
	if (!self.isAddMode) {
		
		[self loadDataModelIntoView];
	}
}


- (void)loadDataModelIntoView {
	
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
	
	// Save dispatch field: start time - try async calculate route
	
	// Save dispatch field: team assigned
	
	// Save other dispatch fields
	
	// Save team fields
	
	// Save location fields - try async geocode
	BOOL updatedLocation = NO;
	
	// Save notes fields
	self.team.notes = [self.notesTextView.text trimAll];
	
	// Persist data model to store and notify observers
	[Util saveManagedObjectContext];
	if (self.isAddMode) {
		
		[self.team postNotificationCreatedWithSender:self];
		
	} else {
		
		[self.team postNotificationUpdatedWithSender:self andUpdatedLocation:updatedLocation];
	}
}


@end
