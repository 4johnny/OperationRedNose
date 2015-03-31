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
# pragma mark - Constants
#

#define DATA_MODEL_RESET_NOTIFICATION_NAME	@"dataModelReset"


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


+ (void)presentAlertWithTitle:(NSString*)title andMessage:(NSString*)message andAction:(UIAlertAction*)action {

	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	
	[alertController addAction:action];
	[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
	
	// Present via known top-level controller to allow for async callback alerts
	id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
	UIViewController* appRootViewController = (UIViewController*)appDelegate.window.rootViewController;
	[appRootViewController presentViewController:alertController animated:YES completion:nil];
}


#
# pragma mark Notifications
#


+ (BOOL)isValueFromNotification:(NSNotification*)notification withKey:(NSString*)key {
	
	return notification.userInfo[key] && ((NSNumber*)notification.userInfo[key]).boolValue;
}


+ (void)addDataModelResetObserver:(id)observer withSelector:(SEL)selector {
	
	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:DATA_MODEL_RESET_NOTIFICATION_NAME object:nil];
}


+ (void)postNotificationDataModelResetWithSender:(id)sender  {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DATA_MODEL_RESET_NOTIFICATION_NAME object:sender userInfo:nil];
}


#
# pragma mark Views
#


+ (void)animateDropView:(UIView*)view withDropHeight:(CGFloat)dropHeight withDuration:(NSTimeInterval)duration withDelay:(NSTimeInterval)delay {
	
	// Remember end frame for annotation
	CGRect endFrame = view.frame;
	
	// Move annotation out of view
	view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - dropHeight, view.frame.size.width, view.frame.size.height);
	
	// Animate drop, completing with squash effect
	[UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
		
		view.frame = endFrame;
		
	} completion:^(BOOL finished) {
		
		if (!finished) return; // Exit block
		
		// Animate squash, completing with un-squash
		[UIView animateWithDuration:0.05 animations:^{
			
			view.transform = CGAffineTransformMakeScale(1.0, 0.8);
			
		} completion:^(BOOL finished){
			
			if (!finished) return; // Exit block
			
			[UIView animateWithDuration:0.1 animations:^{
				
				view.transform = CGAffineTransformIdentity;
			}];
		}];
	}];
}


+ (UIButton*)downArrowButton {
	
	UIButton* downArrowButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[downArrowButton setTitle:DOWN_ARROW_STRING forState:UIControlStateNormal];
	
	return downArrowButton;
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


+ (void)removePersistentStore {

	id<ORNDataModelSource> dataModelSource = (id<ORNDataModelSource>)[UIApplication sharedApplication].delegate;
	[dataModelSource removePersistentStore];
}


@end
