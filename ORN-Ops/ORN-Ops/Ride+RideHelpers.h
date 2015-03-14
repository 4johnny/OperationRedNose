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

#define RIDE_CREATED_NOTIFICATION_NAME					@"rideCreated"
#define RIDE_UPDATED_NOTIFICATION_NAME					@"rideUpdated"
#define RIDE_UPDATED_LOCATION_START_NOTIFICATION_KEY	@"rideUpdatedLocationStart"
#define RIDE_UPDATED_LOCATION_END_NOTIFICATION_KEY		@"rideUpdatedLocationEnd"
#define RIDE_UPDATED_TEAM_ASSIGNED_NOTIFICATION_KEY		@"rideUpdatedTeamAssigned"

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
# pragma mark Helpers
#

- (void)updateLocationWithLatitude:(CLLocationDegrees)latitude andLogitude:(CLLocationDegrees)longitude andAddress:(NSString*)address andCity:(NSString*)city andRideLocationType:(RideLocationType)rideLocationType;
- (void)updateLocationWithPlacemark:(CLPlacemark*)placemark andRideLocationType:(RideLocationType)rideLocationType;
- (void)clearLocationWithRideLocationType:(RideLocationType)rideLocationType;

- (NSString*)getPassengerName;
- (MKDirectionsRequest*)getDirectionsRequest;
- (void)calculateDateTimeEnd;

+ (NSString*)stringFromStatus:(RideStatus)status;
+ (RideStatus)statusFromString:(NSString*)statusString;

@end
