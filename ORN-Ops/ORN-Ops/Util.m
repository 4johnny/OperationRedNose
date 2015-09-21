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

#define DOWN_ARROW_STRING	@"▼"


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


+ (void)presentActionAlertWithViewController:(UIViewController*)viewController
									andTitle:(NSString*)title
								  andMessage:(NSString*)message
								   andAction:(UIAlertAction*)action {
	
	if (!viewController) return;
	
	UIAlertController* actionAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	
	[actionAlertController addAction:action];
	[actionAlertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

	[viewController presentViewController:actionAlertController animated:YES completion:nil];
}


+ (void)presentOKAlertWithViewController:(UIViewController*)viewController
								andTitle:(NSString*)title
							  andMessage:(NSString*)message {
	
	[Util presentActionAlertWithViewController:viewController andTitle:title andMessage:message andAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
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


+ (void)animateDropView:(UIView*)view
		 withDropHeight:(CGFloat)dropHeight
		   withDuration:(NSTimeInterval)duration
			  withDelay:(NSTimeInterval)delay {
	
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
# pragma mark Maps
#


+ (MKPlacemark*)placemarkWithLatitude:(CLLocationDegrees)latitude
						 andLongitude:(CLLocationDegrees)longitude
				 andAddressDictionary:(NSDictionary*)addressDictionary {

	return [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:addressDictionary];
}


+ (MKDirectionsRequest*)directionsRequestWithDepartureDate:(NSDate*)departureDate
										andSourcePlacemark:(MKPlacemark*)sourcePlaceMark
								   andDestinationPlacemark:(MKPlacemark*)destinationPlacemark {
	
	if (!departureDate || !sourcePlaceMark || !destinationPlacemark) return nil;
	
	MKDirectionsRequest* directionsRequest = [[MKDirectionsRequest alloc] init];
	directionsRequest.departureDate = departureDate;
	directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourcePlaceMark];
	directionsRequest.destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
	directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
	directionsRequest.requestsAlternateRoutes = NO;
	
	return directionsRequest;
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


@end
