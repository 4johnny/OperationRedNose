//
//  RideDetailTableViewController.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ride+RideHelpers.h"
#import "PickerTextField.h"
#import "DatePickerTextField.h"

#
# pragma mark - Constants
#

#define RIDE_DETAIL_TABLE_VIEW_CONTROLLER_ID	@"rideDetailTableViewController"

#
# pragma mark - Interface
#

@interface RideDetailTableViewController : UITableViewController <RideModelSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, NSFetchedResultsControllerDelegate>

#
# pragma mark Data Model Properties
#

@property (weak, nonatomic) Ride* ride;

#
# pragma mark UI Outlets
#

// Dispatch
@property (weak, nonatomic) IBOutlet UISegmentedControl *statusSegmentedControl;
@property (weak, nonatomic) IBOutlet DatePickerTextField* startTimeDatePickerTextField;
@property (weak, nonatomic) IBOutlet PickerTextField* teamAssignedPickerTextField;
@property (weak, nonatomic) IBOutlet UITextField* sourceTextField;
@property (weak, nonatomic) IBOutlet UITextField* donationTextField;

// Passenger
@property (weak, nonatomic) IBOutlet UITextField* firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField* lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField* phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl* passengerCountSegmentedControl;

// Location
@property (weak, nonatomic) IBOutlet UITextField* startAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField* endAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField* transferFromTextField;
@property (weak, nonatomic) IBOutlet UITextField* transferToTextField;

// Vehicle
@property (weak, nonatomic) IBOutlet UITextField* vehicleDescriptionTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl* vehicleTransmissionSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl* seatBeltCountSegmentedControl;

// Notes
@property (weak, nonatomic) IBOutlet UITextView* notesTextView;

@end
