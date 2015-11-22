//
//  TeamDetailTableViewController.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Team+TeamHelpers.h"
#import "DatePickerTextField.h"

#
# pragma mark - Constants
#

#define TEAM_DETAIL_TABLE_VIEW_CONTROLLER_ID	@"teamDetailTableViewController"

#
# pragma mark - Interface
#

@interface TeamDetailTableViewController : UITableViewController <TeamModelSource, UITableViewDelegate, UITextFieldDelegate, DatePickerTextFieldDelegate>

#
# pragma mark Data Model Properties
#

@property (weak, nonatomic) Team* team;

#
# pragma mark UI Outlets
#

// Dispatch
@property (weak, nonatomic) IBOutlet UISwitch *isActiveSwitch;
@property (weak, nonatomic) IBOutlet UILabel *rideCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *donationsLabel;

// Team
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *membersTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UISwitch *isMascotSwitch;

// Location
@property (weak, nonatomic) IBOutlet DatePickerTextField *timeDatePickerTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UILabel *coordinatesLabel;
@property (weak, nonatomic) IBOutlet UISwitch *isManualSwitch;

// Notes
@property (weak, nonatomic) IBOutlet UITextView* notesTextView;

@end
