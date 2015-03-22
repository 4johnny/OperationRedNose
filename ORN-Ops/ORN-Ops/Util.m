//
//  Util.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-28.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "Util.h"
#import "ORNDataModelSource.h"


#
# pragma mark - Implementation
#


@implementation Util


#
# pragma mark Responder
#


/*
 Preload keyboard to avoid delay upon user first attempt
 */
+ (void)preloadKeyboardViaTextField:(UITextField*)textfield {
	
	// NOTE: Text field needs to be already in view hierarchy
	[textfield becomeFirstResponder];
	[textfield resignFirstResponder];
}


#
# pragma mark Alert
#


+ (UIAlertController*)sharedOKAlertController {
	
	// Singleton
	
	static UIAlertController* sharedOKAlertController = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		UIAlertAction* okAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
		sharedOKAlertController = [UIAlertController alertControllerWithTitle:@"Error" message:nil preferredStyle:UIAlertControllerStyleAlert];
		[sharedOKAlertController addAction:okAlertAction];
	});
	
	return sharedOKAlertController;
}


+ (void)presentOKAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
	
	// TODO: Singleton for now, but may need to alloc new controllers for each alert
	UIAlertController* okAlertController = [Util sharedOKAlertController];
	
	okAlertController.title = title;
	okAlertController.message = message;
	
	// Present via known top-level controller to allow for async callback alerts
	id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
	UIViewController* appRootViewController = (UIViewController*)appDelegate.window.rootViewController;
	
	[appRootViewController presentViewController:okAlertController animated:YES completion:nil];
}


#
# pragma mark Notifications
#


+ (BOOL)isValueFromNotification:(NSNotification*)notification withKey:(NSString*)key {
	
	return notification.userInfo[key] && ((NSNumber*)notification.userInfo[key]).boolValue;
}


#
# pragma mark <ORNDataModelSource>
#


+ (NSManagedObjectContext*)managedObjectContext {
	
	id<ORNDataModelSource> dataModelSource = (id<ORNDataModelSource>)[UIApplication sharedApplication].delegate;
	return dataModelSource.managedObjectContext;
}


+ (void)saveManagedObjectContext {
	
	id<ORNDataModelSource> dataModelSource = (id<ORNDataModelSource>)[UIApplication sharedApplication].delegate;
	[dataModelSource saveManagedObjectContext];
}


#
# pragma mark Controls
#

+ (UIButton*)downArrowButton {
	
	UIButton* downArrowButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[downArrowButton setTitle:DOWN_ARROW_STRING forState:UIControlStateNormal];
	
	return downArrowButton;
}


@end
