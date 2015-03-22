//
//  Util.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-28.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#
# pragma mark - Constants
#

#define SECONDS_PER_MINUTE	60

#define ARROW_BUTTON_WIDTH	30
#define DOWN_ARROW_STRING	@"▼"

#define CG_SIZE_MAX		CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)

#
# pragma mark Map Constants
#

#define MAP_SPAN_LOCATION_DELTA_NEIGHBOURHOOD	0.02 // degrees
#define MAP_SPAN_LOCATION_DELTA_CITY			0.2 // degrees
#define MAP_SPAN_LOCATION_DELTA_LOCALE			2.0 // degrees

#
# pragma mark Jurisdication Constants
#

#define VANCOUVER_LATITUDE			49.25
#define VANCOUVER_LONGITUDE			-123.1
#define VANCOUVER_COORDINATE		CLLocationCoordinate2DMake(VANCOUVER_LATITUDE, VANCOUVER_LONGITUDE)

#define BURNABY_LATITUDE			49.266667
#define BURNABY_LONGITUDE			-122.966667
#define BURNABY_COORDINATE			CLLocationCoordinate2DMake(BURNABY_LATITUDE, BURNABY_LONGITUDE)

#define CHARITY_NAME				@"KidSport"
#define JURISDICTION_NAME			@"Tri-Cities, Burnaby, New Westminster"
#define JURISDICTION_COORDINATE		BURNABY_COORDINATE
#define JURISDICTION_SEARCH_RADIUS	100000 // metres

#
# pragma mark - Interface
#

@interface Util : NSObject

#
# pragma mark Responder
#

+ (void)preloadKeyboardViaTextField:(UITextField*)textfield;

#
# pragma mark Alert
#

+ (UIAlertController*)sharedOKAlertController;
+ (void)presentOKAlertWithTitle:(NSString*)title andMessage:(NSString*)message;

#
# pragma mark Notifications
#

+ (BOOL)isValueFromNotification:(NSNotification*)notification withKey:(NSString*)key;

#
# pragma mark <ORNDataModelSource>
#

+ (NSManagedObjectContext*)managedObjectContext;
+ (void)saveManagedObjectContext;

#
# pragma mark Controls
#

+ (UIButton*)downArrowButton;

@end
