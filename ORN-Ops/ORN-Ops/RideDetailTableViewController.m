//
//  RideDetailTableViewController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "RideDetailTableViewController.h"
#import "AppDelegate.h"


#
# pragma mark - Interface
#


@interface RideDetailTableViewController ()

@end


#
# pragma mark - Implementation
#


@implementation RideDetailTableViewController


#
# pragma mark UIViewController
#


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

	if (pickerView == self.vehicleTransmissionPickerView) return 2;
	if (pickerView == self.seatBeltCountPickerView) return 10;
	
	return 0;
}


#
# pragma mark <UIPickerViewDelegate>
#

- (CGFloat)pickerView:(UIPickerView*)pickerView rowHeightForComponent:(NSInteger)component {
	
	return 30; // points
}

- (CGFloat)pickerView:(UIPickerView*)pickerView widthForComponent:(NSInteger)component {
	
	if (pickerView == self.vehicleTransmissionPickerView) return 150;
	if (pickerView == self.seatBeltCountPickerView) return 30;
	
	return 0; // points
}


- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

	if (pickerView == self.vehicleTransmissionPickerView) {
		
		switch (row) {
				
			case 0:
			    return @"Automatic";
				
			case 1:
				return @"Manual";
				
			default:
		    break;
		}
	}
	
	if (pickerView == self.seatBeltCountPickerView) return [NSString stringWithFormat:@"%d", (int)row];
	
	return nil;
}


/*
- (NSAttributedString*)pickerView:(UIPickerView*)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {

	return nil;
}
*/
/*
- (UIView*)pickerView:(UIPickerView*)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView*)view {
	
	return view;
}
*/


#
# pragma mark Action Handlers
#


- (IBAction)backgroundTapped:(UITapGestureRecognizer*)sender {

	[self.view endEditing:YES];
}


- (IBAction)savePressed:(UIBarButtonItem *)sender {
	
	[self.view endEditing:YES];
	
	
	
	//	[RideDetailTableViewController saveManagedObjectContext];
	[self.navigationController popViewControllerAnimated:YES];
}


#
# pragma mark Helpers
#


+ (void)saveManagedObjectContext {
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate saveManagedObjectContext];
}


@end
