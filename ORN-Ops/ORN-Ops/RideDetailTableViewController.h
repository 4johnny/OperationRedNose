//
//  RideDetailTableViewController.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

#
# pragma mark - Interface
#

@interface RideDetailTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>

#
# pragma mark Outlets
#

// Dispatch
@property (weak, nonatomic) IBOutlet UITextField *sourceTextField;
@property (weak, nonatomic) IBOutlet UITextField *teamAssignedTextField;

// Passenger
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passengerCountTextField;

// Location
@property (weak, nonatomic) IBOutlet UITextField *startAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *endAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *transferFromTextField;
@property (weak, nonatomic) IBOutlet UITextField *transferToTextField;

// Time
@property (weak, nonatomic) IBOutlet UIDatePicker *startTimeDatePicker;

// Vehicle
@property (weak, nonatomic) IBOutlet UITextField *vehicleDescriptionTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *vehicleTransmissionPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *seatBeltCountPickerView;

// Notes
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;

@end
