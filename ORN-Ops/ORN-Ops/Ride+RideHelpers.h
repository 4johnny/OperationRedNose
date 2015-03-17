//
//  Ride+RideHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Ride.h"

#
# pragma mark - Constants
#

#define RIDE_ENTITY_NAME	@"Ride"
#define RIDE_TITLE_DEFAULT	@"(Ride)"
#define RIDE_TITLE_NONE		@"-None-"

#define RIDE_STATUS_STRING_NONE			@"None"
#define RIDE_STATUS_STRING_NEW			@"New"
#define RIDE_STATUS_STRING_CONFIRMED	@"Confirmed"
#define RIDE_STATUS_STRING_PROGRESSING	@"Progressing"
#define RIDE_STATUS_STRING_COMPLETED	@"Completed"
#define RIDE_STATUS_STRING_CANCELLED	@"Cancelled"

#
# pragma mark - Enums
#

typedef NS_ENUM(NSInteger, RideStatus) {
	
	RideStatus_None =			0,
	
	RideStatus_New =			1,
	RideStatus_Confirmed =		2,
	RideStatus_Progressing =	3,
	RideStatus_Completed =		4,
	
	RideStatus_Cancelled =		9
};

typedef NS_ENUM(NSInteger, RideLocationType) {
	
	RideLocationType_None = 0,
	
	RideLocationType_Start,
	RideLocationType_End
};

typedef NS_ENUM(NSInteger, VehicleTransmission) {
	
	VehicleTransmission_None =			0,
	
	VehicleTransmission_Automatic =		1,
	VehicleTransmission_Manual =		2,
	
	VehicleTransmission_Unknown =		9
};

#
# pragma mark - Interface
#

@interface Ride (RideHelpers)

#
# pragma mark Initializers
#

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext andDateTime:(NSDate*)dateTime andPlacemark:(CLPlacemark*)placemark andRideLocationType:(RideLocationType)rideLocationType;
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (instancetype)rideWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext andDateTime:(NSDate*)dateTime andPlacemark:(CLPlacemark*)placemark andRideLocationType:(RideLocationType)rideLocationType;
+ (instancetype)rideWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

#
# pragma mark Notifications
#

+ (void)addCreatedObserver:(id)observer withSelector:(SEL)selector;
+ (void)addUpdatedObserver:(id)observer withSelector:(SEL)selector;

+ (Ride*)rideFromNotification:(NSNotification*)notification;
+ (BOOL)isUpdatedLocationStartFromNotification:(NSNotification*)notification;
+ (BOOL)isUpdatedLocationEndFromNotification:(NSNotification*)notification;
+ (BOOL)isUpdatedTeamAssignedFromNotification:(NSNotification*)notification;

- (void)postNotificationCreatedWithSender:(id)sender;
- (void)postNotificationUpdatedWithSender:(id)sender;

- (void)postNotificationUpdatedWithSender:(id)sender andUpdatedLocationStart:(BOOL)updatedLocationStart andUpdatedLocationEnd:(BOOL)updatedLocationEnd;
- (void)postNotificationUpdatedWithSender:(id)sender andUpdatedLocationStart:(BOOL)updatedLocationStart andUpdatedLocationEnd:(BOOL)updatedLocationEnd andUpdatedTeamAssigned:(BOOL)updatedTeamAssigned;

#
# pragma mark Helpers
#

- (void)clearLocationWithRideLocationType:(RideLocationType)rideLocationType;
- (void)clearRoute;

- (void)updateLocationWithLatitude:(CLLocationDegrees)latitude andLogitude:(CLLocationDegrees)longitude andAddress:(NSString*)address andCity:(NSString*)city andRideLocationType:(RideLocationType)rideLocationType;
- (void)updateLocationWithPlacemark:(CLPlacemark*)placemark andRideLocationType:(RideLocationType)rideLocationType;

- (void)tryUpdateLocationWithAddressString:(NSString*)addressString andRideLocationType:(RideLocationType)rideLocationType andGeocoder:(CLGeocoder*)geocoder andSender:(id)sender;
- (void)tryUpdateRouteDurationWithSender:(id)sender;

- (NSString*)getPassengerName;
- (NSString*)getTitle;
- (MKDirectionsRequest*)getDirectionsRequest;
- (NSDate*)getRouteDateTimeEnd;

+ (NSString*)stringFromStatus:(RideStatus)status;
+ (RideStatus)statusFromString:(NSString*)statusString;

@end
