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
# pragma mark Initializers
#


//+ (void)initialize {
//	
//}


- (instancetype)init {
	self = [super init];
	
	if (self) {
		
		// Data validation char sets
		
		_phoneNumberCharacterSet = [NSCharacterSet decimalDigitCharacterSet]; // [NSCharacterSet characterSetWithCharactersInString:@"0123456789-()+*#,;"];
		_phoneNumberCharacterSetInverted = _phoneNumberCharacterSet.invertedSet;
		
		_monetaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
		_monetaryCharacterSetInverted = _monetaryCharacterSet.invertedSet;
	}
	
	return self;
}


+ (instancetype)sharedUtil {
	
	// Singleton
	
	static Util* sharedUtil = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		sharedUtil = [[Util alloc] init];
	});
	
	return sharedUtil;
}


#
# pragma mark Converters
#


+ (NSString*)stringFromDictionary:(NSDictionary*)dictionary {
	
	if (!dictionary) return nil;
	if (dictionary.count <= 0) return @"";
	
	NSError* error;
	NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
	
	return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


+ (NSMutableDictionary*)dictionaryFromString:(NSString*)string {
	
	if (!string) return nil;
	//	string = [string trimAllNewline];
	if (string.length <= 0) return [NSMutableDictionary dictionary];
	
	NSError* error;
	NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
	if (!data) return nil;
	
	return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
}


+ (NSMutableDictionary*)dictionaryFromObject:(NSObject*)object {
	
	// Best effort to convert to dictionary
	
	if (!object) return nil;
	
	if ([object isKindOfClass:[NSDictionary class]]) return [object mutableCopy];
	
	if ([object isKindOfClass:[NSString class]]) return [Util dictionaryFromString:(NSString*)object];
	
	return nil;
}


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


+ (void)presentOKAlertWithViewController:(UIViewController*)viewController
								andTitle:(NSString*)title
							  andMessage:(NSString*)message {
	
	[Util presentOKAlertWithViewController:viewController andTitle:title andMessage:message andHandler:nil];
}


+ (void)presentOKAlertWithViewController:(UIViewController*)viewController
								andTitle:(NSString*)title
							  andMessage:(NSString*)message
						andHandler:(void (^ __nullable)(UIAlertAction* action))handler {
	
	if (!viewController) return;
	
	UIAlertController* actionAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	
	[actionAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handler]];
	
	[viewController presentViewController:actionAlertController animated:YES completion:nil];
}


+ (UIAlertController*)presentActionAlertWithViewController:(UIViewController*)viewController
												  andTitle:(NSString*)title
												andMessage:(NSString*)message
												 andAction:(UIAlertAction*)action
										  andCancelHandler:(void (^ __nullable)(UIAlertAction* action))cancelHandler {
	
	if (!viewController) return nil;
	
	UIAlertController* actionAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	
	[actionAlertController addAction:action];
	[actionAlertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:cancelHandler]];

	[viewController presentViewController:actionAlertController animated:YES completion:nil];
	
	return actionAlertController;
}


+ (void)presentConnectionAlertWithViewController:(UIViewController*)viewController
									  andHandler:(void(^)(UIAlertAction* action))handler {
	
	[Util presentOKAlertWithViewController:viewController andTitle:@"Connection Trouble" andMessage:@"Try again later." andHandler:handler];
}


+ (void)presentDeleteAlertWithViewController:(UIViewController*)viewController
							   andDataObject:(id<ORNDataObject>)dataObject
							andCancelHandler:(void (^ __nullable)(UIAlertAction* action))cancelHandler {
	
	NSString* alertTitle = [NSString stringWithFormat:@"Delete %@: %@", [NSStringFromClass(dataObject.class) lowercaseString], [dataObject getTitle]];
	
	UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* _Nonnull action) {
		
		[dataObject delete];
		[Util saveManagedObjectContext];
	}];
	
	(void)[Util presentActionAlertWithViewController:viewController
											andTitle:alertTitle
										  andMessage:@"Cannot be undone! Are you sure?"
										   andAction:deleteAction
									andCancelHandler:cancelHandler];
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


+ (void)postNotificationDataModelResetWithSender:(id)sender {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DATA_MODEL_RESET_NOTIFICATION_NAME object:sender userInfo:nil];
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


+ (void)deleteAllObjectsWithEntityName:(NSString*)entityName {
	
	id<ORNDataModelSource> dataModelSource = (id<ORNDataModelSource>)[UIApplication sharedApplication].delegate;
	[dataModelSource deleteAllObjectsWithEntityName:entityName];
}


+ (void)removePersistentStore {

	id<ORNDataModelSource> dataModelSource = (id<ORNDataModelSource>)[UIApplication sharedApplication].delegate;
	[dataModelSource removePersistentStore];
}


#
# pragma mark Data Model
#


+ (BOOL)isStaleDate:(NSDate*)date {

	if (!date) return YES;
	
	return [date isOlderThanMinutes:TIME_MINUTE_INTERVAL];
}


@end
