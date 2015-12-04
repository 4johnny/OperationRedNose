//
//  RideDetailTableViewController.h
//  ORN-Intake
//
//  Created by Johnny on 2015-12-03.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

// NOTE: Keep in sync with ORN-Ops

#import <UIKit/UIKit.h>

#import "PickerTextField.h"
#import "DatePickerTextField.h"

#
# pragma mark - Constants
#

#define RIDE_DETAIL_TABLE_VIEW_CONTROLLER_ID	@"rideDetailTableViewController"

#
# pragma mark - Interface
#

@interface RideDetailTableViewController : UITableViewController <UITableViewDelegate, UITextFieldDelegate>

#
# pragma mark UI Outlets
#

// Dispatch
@property (weak, nonatomic) IBOutlet UITextField* sourceTextField;
@property (weak, nonatomic) IBOutlet DatePickerTextField* idealTimeDatePickerTextField;

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
