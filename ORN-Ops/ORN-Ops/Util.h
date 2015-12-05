//
//  Util.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-28.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "Macros.h"
#import "ORNDataObject.h"


#
# pragma mark - Constants
#

#define ORN_ERROR_DOMAIN_ORNOPSAPP	@"OperationRedNose.OpsApp.ErrorDomain"

#
# pragma mark Map Constants
#

#define MAP_SPAN_LOCATION_DELTA_NEIGHBOURHOOD	0.02 // degrees
#define MAP_SPAN_LOCATION_DELTA_CITY			0.25 // degrees
#define MAP_SPAN_LOCATION_DELTA_LOCALE			2.0 // degrees

#
# pragma mark Dispatch Constants
#

#define ARRIVAL_MARGIN_DURATION	60 // seconds
#define ARRIVAL_MARGIN_DISTANCE	100 // meters

#
# pragma mark Date-Time Constants
#

#define TIME_MINUTE_INTERVAL	5

#
# pragma mark Jurisdication Constants
#

#define CANADA_COUNTRY_NAME				@"Canada"
#define CANADA_COUNTRY_CODE				@"CA"

#define BRITISH_COLUMBIA_PROVINCE_CODE	@"BC"
#define BRITISH_COLUMBIA_STATE_CODE		BRITISH_COLUMBIA_PROVINCE_CODE

#define VANCOUVER_LATITUDE				49.25
#define VANCOUVER_LONGITUDE				-123.1
#define VANCOUVER_COORDINATE			CLLocationCoordinate2DMake(VANCOUVER_LATITUDE, VANCOUVER_LONGITUDE)

#define BURNABY_LATITUDE				49.266667
#define BURNABY_LONGITUDE				-122.966667
#define BURNABY_COORDINATE				CLLocationCoordinate2DMake(BURNABY_LATITUDE, BURNABY_LONGITUDE)

#define CHARITY_NAME					@"KidSport"
#define JURISDICTION_NAME				@"Tri-Cities, Burnaby, New Westminster"
#define JURISDICTION_COORDINATE			BURNABY_COORDINATE
#define JURISDICTION_SEARCH_RADIUS		100000 // meters

#
# pragma mark - Interface
#

@interface Util : NSObject

#
# pragma mark Initializers
#

+ (instancetype)sharedUtil;

#
# pragma mark NSCharacterSet
#

@property (nonatomic) NSCharacterSet* phoneNumberCharacterSet;
@property (nonatomic) NSCharacterSet* phoneNumberCharacterSetInverted;

@property (nonatomic) NSCharacterSet* monetaryCharacterSet;
@property (nonatomic) NSCharacterSet* monetaryCharacterSetInverted;

#
# pragma mark Converters
#

+ (NSString*)stringFromDictionary:(NSDictionary*)dictionary;
+ (NSMutableDictionary*)dictionaryFromString:(NSString*)string;
+ (NSMutableDictionary*)dictionaryFromObject:(NSObject*)object;

#
# pragma mark Responder
#

+ (void)preloadKeyboardViaTextField:(UITextField*)textfield;

#
# pragma mark Alert
#

+ (void)presentOKAlertWithViewController:(UIViewController*)viewController
								andTitle:(NSString*)title
							  andMessage:(NSString*)message;

+ (void)presentOKAlertWithViewController:(UIViewController*)viewController
								andTitle:(NSString*)title
							  andMessage:(NSString*)message
							  andHandler:(void (^)(UIAlertAction* action))handler;

+ (UIAlertController*)presentActionAlertWithViewController:(UIViewController*)viewController
												  andTitle:(NSString*)title
												andMessage:(NSString*)message
												 andAction:(UIAlertAction*)action
										  andCancelHandler:(void (^)(UIAlertAction* action))cancelHandler;

+ (void)presentConnectionAlertWithViewController:(UIViewController*)viewController
									  andHandler:(void(^)(UIAlertAction* action))handler;

+ (void)presentDeleteAlertWithViewController:(UIViewController*)viewController
							   andDataObject:(id<ORNDataObject>)dataObject
							andCancelHandler:(void (^)(UIAlertAction* action))cancelHandler;

#
# pragma mark Notifications
#

+ (BOOL)isValueFromNotification:(NSNotification*)notification withKey:(NSString*)key;

+ (void)addDataModelResetObserver:(id)observer withSelector:(SEL)selector;
+ (void)postNotificationDataModelResetWithSender:(id)sender;

#
# pragma mark <ORNDataModelSource>
#

+ (NSManagedObjectContext*)managedObjectContext;
+ (void)saveManagedObjectContext;
+ (void)deleteAllObjectsWithEntityName:(NSString*)entityName;
+ (void)removePersistentStore;

#
# pragma mark Data Model
#

+ (BOOL)isStaleDate:(NSDate*)date;

@end
