//
//  RideDetailTableViewController.m
//  ORN-Intake
//
//  Created by Johnny on 2015-12-03.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

// NOTE: Keep in sync with ORN-Ops

#import "RideDetailTableViewController.h"


#
# pragma mark - Constants
#

#define PHONE_TEXT_LENGTH_MAX	10



#
# pragma mark Command Constants
#

#define ENABLE_COMMANDS

#define COMMAND_HELP				@"ornhelp"

// Hidden commands
#define COMMAND_BOT					@"ornbot" // Telegram ID is first parameter


#
# pragma mark Remote Command Constants
#

#define TELEGRAM_SEND_MESSAGE_URL_FORMAT	@"https://api.telegram.org/bot%@/sendMessage"

#define SEND_MESSAGE_TIMEOUT	30 // seconds


#
# pragma mark - Interface
#


@interface RideDetailTableViewController ()

@property (weak, nonatomic) UIResponder* currentResponder;

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
	
	// Remove section footer
	self.tableView.sectionFooterHeight = 0;
	
	// Remove table footer
	self.tableView.tableFooterView = [UIView new];

	[self configureTagsForTabOrder];
}


- (void)viewDidAppear:(BOOL)animated {

	[[self initialResponder] becomeFirstResponder];
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
# pragma mark <UITextFieldDelegate>
#


- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString*)string {
	
	// NOTE: String may be typed or pasted
	// NOTE: Cannot rely on keyboards to constrain input char types, since different devices show different keyboards for same text field
	// NOTE: Check fields in order of most likely used, since this method is called per char entered
	
	if (textField == self.phoneNumberTextField) {
	
		// Reject non-phone number chars
		if ([string rangeOfCharacterFromSet:[NSCharacterSet phoneNumberCharacterSetInverted]].location != NSNotFound) return NO;
		
		// Reject resulting string exceeding max length
		NSMutableString* newString = [textField.text mutableCopy];
		[newString replaceCharactersInRange:range withString:string];
		if (newString.length > PHONE_TEXT_LENGTH_MAX) return NO;
	}
	
	return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	
	self.currentResponder = textField;
	
	return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField*)textField {
	
	if (self.currentResponder == textField) {
		self.currentResponder = nil;
	}
	
	return YES;
}


#
# pragma mark <UITextViewDelegate>
#


- (void)textViewDidBeginEditing:(UITextView*)textView {

	self.currentResponder = textView;
}


- (void)textViewDidEndEditing:(UITextView*)textView {
	
	if (self.currentResponder == textView) {
		self.currentResponder = nil;
	}
}


/*
 User hit keyboard return key
 */
- (BOOL)textFieldShouldReturn:(UITextField*)textField {

	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:textField andIsAddmode:YES];
	
	return NO; // Do not perform default text-field behaviour
}


#
# pragma mark Action Handlers
#


- (IBAction)backgroundTapped:(UITapGestureRecognizer*)sender {
	
	[self.view endEditing:YES];
}


- (IBAction)clearPressed:(UIBarButtonItem*)sender {
	
	UIResponder* currentResponder = self.currentResponder; // Maybe nil
	[self.view endEditing:YES];
	
	UIAlertAction* clearAction = [UIAlertAction actionWithTitle:@"Clear" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* _Nonnull action) {
		
		[self clearFields];
	}];
	
	[Util presentActionAlertWithViewController:self
									  andTitle:@"Clear Form"
									andMessage:@"Cannot be undone! Are you sure?"
									 andAction:clearAction
									andCancelHandler:^(UIAlertAction* action) {
										[currentResponder becomeFirstResponder];
									}];
}


- (IBAction)submitPressed:(UIBarButtonItem*)sender {
	
	UIResponder* currentResponder = self.currentResponder; // Maybe nil
	[self.view endEditing:YES];
	
#ifdef ENABLE_COMMANDS
	// If command present, handle it and we are done
	if ([self handleCommandString:self.sourceTextField.text]) {
		
		self.sourceTextField.text = nil;
		
		[currentResponder becomeFirstResponder];
		
		return; // Do *not* perform default submit behaviour
	}
#endif
	
	UIAlertAction* submitAction = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* _Nonnull action) {
		
		[self submitFieldsWithCurrentResponder:currentResponder];
	}];
	
	[Util presentActionAlertWithViewController:self
									  andTitle:@"Submit Form"
									andMessage:@"Cannot be undone! Are you sure?"
									 andAction:submitAction
									andCancelHandler:^(UIAlertAction* action) {
										[currentResponder becomeFirstResponder];
									}];
}


- (IBAction)passengerCountValueChanged:(UISegmentedControl*)sender {
	
	self.currentResponder = nil;

	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:YES];
}


- (IBAction)transmissionValueChanged:(UISegmentedControl*)sender {
	
	self.currentResponder = nil;
	
	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:YES];
}


- (IBAction)seatBeltCountValueChanged:(UISegmentedControl*)sender {
	
	self.currentResponder = nil;
	
	[self.view makeNextTaggedViewFirstResponderWithCurrentTaggedView:sender andIsAddmode:YES];
}


#
# pragma mark Command Handlers
#


/*
 * Handle command string
 * Returns whether command string was handled
 */
- (BOOL)handleCommandString:(NSString*)commandString {
	
	NSArray<NSString*>* commandComponents = [commandString componentsTrimAll];
	
	if (commandComponents.count <= 0) return NO;
	
	NSString* commandAction = commandComponents[0].lowercaseString;
	
	BOOL isCommandHandled = NO;
	
	if ([COMMAND_HELP isEqualToString:commandAction]) {
		
		NSString* message =
		[NSString stringWithFormat:
		 @"%@",
		 
		 COMMAND_HELP
		 ];
		[Util presentOKAlertWithViewController:self andTitle:@"ORN Commands" andMessage:message];
		
		isCommandHandled = YES;
		
	} else if ([COMMAND_BOT isEqualToString:commandAction]) {
		
		AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
		
		if (commandComponents.count > 1) {
			
			// Grab Telegram bot auth token and persist it for later use
			appDelegate.telegramBotAuthToken = commandComponents[1];
			
		} else {
			
			// No Telegram ID, so remove from persistence
			appDelegate.telegramBotAuthToken = nil;
		}
		
		isCommandHandled = YES;
	}
	
	if (isCommandHandled) {
		NSLog(@"Handled Command: %@", commandString);
	}
	
	return isCommandHandled;
}


#
# pragma mark Helpers
#


- (void)configureTagsForTabOrder {

	// Dispatch
	self.sourceTextField.tag =						0;
	self.idealTimeDatePickerTextField.tag =			1;
	
	// Passenger
	self.firstNameTextField.tag =					2;
	self.lastNameTextField.tag =					3;
	self.phoneNumberTextField.tag =					4;
	self.passengerCountSegmentedControl.tag =		5;
	
	// Location
	self.startAddressTextField.tag =				6;
	self.endAddressTextField.tag =					7;
	self.transferFromTextField.tag =				8;
	self.transferToTextField.tag =					9;
	
	// Vehicle
	self.vehicleDescriptionTextField.tag =			10;
	self.vehicleTransmissionSegmentedControl.tag =	11;
	self.seatBeltCountSegmentedControl.tag =		12;
	
	// Notes
	self.notesTextView.tag =						13;
}


- (UIResponder*)initialResponder {

	return self.firstNameTextField;
}


- (void)clearFields {

	// Clear all fields *except* for source, for user convenience

	// Dispatch
	//	self.sourceTextField.text = nil;
	[self.idealTimeDatePickerTextField constrain];
	
	// Passenger
	self.firstNameTextField.text = nil;
	self.lastNameTextField.text = nil;
	self.phoneNumberTextField.text = nil;
	self.passengerCountSegmentedControl.selectedSegmentIndex = 0;
	
	// Location
	self.startAddressTextField.text = nil;
	self.endAddressTextField.text = nil;
	self.transferFromTextField.text = nil;
	self.transferToTextField.text = nil;
	
	// Vehicle
	self.vehicleDescriptionTextField.text = nil;
	self.vehicleTransmissionSegmentedControl.selectedSegmentIndex = 0;
	self.seatBeltCountSegmentedControl.selectedSegmentIndex = 0;
	
	// Notes
	self.notesTextView.text = nil;

	// Reset responder state
	self.currentResponder = nil;
	[[self initialResponder] becomeFirstResponder];
}


- (void)submitFieldsWithCurrentResponder:(UIResponder*)currentResponder {

	// TODO: Implement submitting fields to Telegram bot
	
	// Submit form info to Telegram bot

	// Build URL request
	NSMutableURLRequest* urlRequest = [self urlRequestForTelegramBotSendMessage];
	NSLog(@"Backend URL-request for ride create: %@", urlRequest);
	NSAssert(urlRequest, @"URL request must exist");
	if (!urlRequest) return;
	
	// Fire URL request - async
	//	[appDelegate.chatsNavigationController showActivityIndicator];
	[[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
		
		NSLog(@"URL response for ride create running on thread: %@", [NSThread currentThread]);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			NSLog(@"Processing response for ride create on thread: %@", [NSThread currentThread]);
			
			//	[appDelegate.chatsNavigationController hideActivityIndicator];
			
			if (!data) {
				NSLog(@"URL Connection Error - %@ %@", error.localizedDescription, error.userInfo[NSURLErrorFailingURLStringErrorKey]);
				[Util presentConnectionAlertWithViewController:self andHandler:^(UIAlertAction *action) {
					[currentResponder becomeFirstResponder];
				}];
				return;
			}
			
			// We have data - convert it to JSON dictionary
			NSError* error = nil;
			NSDictionary* responseJSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
			if (!responseJSONDictionary) {
				NSLog(@"JSON Deserialization Error - %@ %@", error.localizedDescription, error.userInfo);
				[Util presentConnectionAlertWithViewController:self andHandler:^(UIAlertAction *action) {
					[currentResponder becomeFirstResponder];
				}];
				return;
			}
			NSLog(@"Backend URL-response JSON for ride create: %@", responseJSONDictionary);
			
			// We have JSON dictionary - grab ride create result
			
			BOOL isRideCreateSuccessful = ((NSNumber*)responseJSONDictionary[@"ok"]).boolValue;
			
			if (!isRideCreateSuccessful) {

				NSNumber* errorCode = responseJSONDictionary[@"error_code"];
				NSString* errorDescriptionText = responseJSONDictionary[@"description"];
				NSLog(@"Telegram Error (%@): %@", errorCode, errorDescriptionText);
				
				NSString* alertTitle = [NSString stringWithFormat:@"Unable to submit form at this time: %@\nTry again later.", errorDescriptionText];
				[Util presentOKAlertWithViewController:self andTitle:@"Submit Form" andMessage:alertTitle andHandler:^(UIAlertAction* action) {
					[currentResponder becomeFirstResponder];
				}];
				
				return;
			}
			
			// Ride created successfully - notify user
			
			[Util presentOKAlertWithViewController:self andTitle:@"Submit Form" andMessage:@"Submitted form successfully.\nProvide paper form to dispatcher." andHandler:^(UIAlertAction* action) {
				
				[self clearFields];
			}];
			
		});
	}] resume];
}


- (NSMutableURLRequest*)urlRequestForTelegramBotSendMessage {
	
	AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
	
	NSString* authToken = appDelegate.telegramBotAuthToken;
	NSAssert(authToken.length > 0, @"Telegram bot auth token must exist");
	if (authToken.length <= 0) return nil;
	
	NSString* urlString = [NSString stringWithFormat:TELEGRAM_SEND_MESSAGE_URL_FORMAT, authToken];
	NSURL* url = [NSURL URLWithString:urlString];
	//	NSLog(@"URL for Telegram bot message: %@", url);
	
	NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
	urlRequest.HTTPMethod = @"POST";
	urlRequest.timeoutInterval = SEND_MESSAGE_TIMEOUT; // seconds
	[urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	NSDictionary<NSString*,id>* messageDictionary =
	@{
	  @"entity" :		@"ride",
	  @"action" :		@"create",
	  @"attributes" :
		  @{
			  // Dispatch
			  @"sourceName" :			[self.sourceTextField.text trimAll] ?: @"",
			  
			  // Passenger
			  @"passengerNameFirst" :	[self.firstNameTextField.text trimAll] ?: @"",
			  @"passengerNameLast" :	[self.lastNameTextField.text trimAll] ?: @"",
			  @"passengerPhoneNumber" : [self.phoneNumberTextField.text trimAll] ?: @"",
			  @"passengerCount" : 		@(self.passengerCountSegmentedControl.selectedSegmentIndex + 1),
			  
			  // Location
			  @"locationStartAddress" :	[self.startAddressTextField.text trimAll] ?: @"",
			  @"locationEndAddress" :	[self.endAddressTextField.text trimAll] ?: @"",
			  @"locationTransferFrom" :	[self.transferFromTextField.text trimAll] ?: @"",
			  @"locationTransferTo" :	[self.transferToTextField.text trimAll] ?: @"",
			  
			  // Vehicle
			  @"vehicleDescription" :	[self.vehicleDescriptionTextField.text trimAll] ?: @"",
			  @"vehicleTransmission" :	(self.vehicleTransmissionSegmentedControl.selectedSegmentIndex == 1 ? @"manual" : @"automatic"),
			  @"vehicleSeatBeltCount" :	@(self.seatBeltCountSegmentedControl.selectedSegmentIndex),
			  
			  // Notes
			  @"notes" :				[self.notesTextView.text trim] ?: @"",
			  }
	  };
	NSString* messageText = [Util stringFromDictionary:messageDictionary];
	
	NSDictionary<NSString*,id>* httpBodyJSONDictionary =
	@{
	  @"chat_id" :	@"@orn_test_ops_bot",
	  @"text" :		messageText ?: @"",
	  };
	NSLog(@"Backend URL-request JSON for Telegram bot message: %@", httpBodyJSONDictionary);
	
	NSError* error = nil;
	urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:httpBodyJSONDictionary options:kNilOptions error:&error];
	if (error) {
		NSLog(@"JSON Serialization Error - %@ %@", error.localizedDescription, error.userInfo);
		return nil;
	}
	
	NSLog(@"URL request for Telegram bot message: %@", urlRequest);
	
	return urlRequest;
}


@end