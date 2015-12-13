//
//  Ride+RideHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "Ride.h"

#
# pragma mark - Constants
#

#define RIDE_ENTITY_NAME	@"Ride"

#define RIDE_ATTRIBUTE_NAME_DATE_TIME_START					@"dateTimeStart"
#define RIDE_ATTRIBUTE_NAME_SOURCE_NAME						@"sourceName"

#define RIDE_ATTRIBUTE_NAME_PASSENGER_NAME_FIRST			@"passengerNameFirst"
#define RIDE_ATTRIBUTE_NAME_PASSENGER_NAME_LAST				@"passengerNameLast"
#define RIDE_ATTRIBUTE_NAME_PASSENGER_PHONE_NUMBER			@"passengerPhoneNumber"
#define RIDE_ATTRIBUTE_NAME_PASSENGER_COUNT					@"passengerCount"

#define RIDE_ATTRIBUTE_NAME_LOCATION_START_ADDRESS			@"locationStartAddress"
#define RIDE_ATTRIBUTE_NAME_LOCATION_END_ADDRESS			@"locationEndAddress"
#define RIDE_ATTRIBUTE_NAME_LOCATION_TRANSFER_FROM			@"locationTransferFrom"
#define RIDE_ATTRIBUTE_NAME_LOCATION_TRANSFER_TO			@"locationTransferTo"

#define RIDE_ATTRIBUTE_NAME_VEHICLE_DESCRIPTION				@"vehicleDescription"
#define RIDE_ATTRIBUTE_NAME_VEHICLE_TRANSMISSION			@"vehicleTransmission"
#define RIDE_ATTRIBUTE_VALUE_VEHICLE_TRANSMISSION_AUTOMATIC	@"automatic"
#define RIDE_ATTRIBUTE_VALUE_VEHICLE_TRANSMISSION_MANUAL	@"manual"
#define RIDE_ATTRIBUTE_NAME_VEHICLE_SEAT_BELT_COUNT			@"vehicleSeatBeltCount"

#define RIDE_ATTRIBUTE_NAME_NOTES							@"notes"

#define RIDE_TITLE_DEFAULT	@"(Ride)"
#define RIDE_TITLE_NONE		@"-None-"

// NOTE: Sort keys indexed in data model
#define RIDE_FETCH_SORT_KEY1		@"dateTimeStart"
#define RIDE_FETCH_SORT_ASC1		YES
#define RIDE_FETCH_SORT_KEY2		@"locationStartLongitude"
#define RIDE_FETCH_SORT_ASC2		YES
#define RIDE_FETCH_BATCH_SIZE		20

#define RIDE_STATUS_STRING_NONE			@"None"
#define RIDE_STATUS_STRING_NEW			@"New"
#define RIDE_STATUS_STRING_ASSIGNED		@"Assigned"
#define RIDE_STATUS_STRING_DISPATCHED	@"Dispatched"
#define RIDE_STATUS_STRING_TRANSPORTING	@"Transporting"
#define RIDE_STATUS_STRING_COMPLETED	@"Completed"
#define RIDE_STATUS_STRING_CANCELLED	@"Cancelled"

#define RIDE_STATUS_STRING_SHORT_NONE			@"None"
#define RIDE_STATUS_STRING_SHORT_NEW			@"New"
#define RIDE_STATUS_STRING_SHORT_ASSIGNED		@"Asgn"
#define RIDE_STATUS_STRING_SHORT_DISPATCHED		@"Dspt"
#define RIDE_STATUS_STRING_SHORT_TRANSPORTING	@"Trns"
#define RIDE_STATUS_STRING_SHORT_COMPLETED		@"Cmpl"
#define RIDE_STATUS_STRING_SHORT_CANCELLED		@"Cncl"

#
# pragma mark - Enums
#

typedef NS_ENUM(NSInteger, RideStatus) {
	
	RideStatus_None =			0,
	
	RideStatus_New	=			1,
	RideStatus_Assigned =		2,
	RideStatus_Dispatched =		3,
	RideStatus_Transporting =	4,
	RideStatus_Completed =		5,
	RideStatus_Cancelled =		6,
};

typedef NS_ENUM(NSInteger, RideLocationType) {
	
	RideLocationType_None = 0,
	
	RideLocationType_Start,
	RideLocationType_End,
};

typedef NS_ENUM(NSInteger, RideRouteType) {
	
	RideRouteType_None =	0,
	
	RideRouteType_Main =	1,
	RideRouteType_Prep =	2,
	RideRouteType_Wait =	3,
};

typedef NS_ENUM(NSInteger, VehicleTransmission) {
	
	VehicleTransmission_None =			0,
	
	VehicleTransmission_Automatic =		1,
	VehicleTransmission_Manual =		2,
	
	VehicleTransmission_Unknown =		9,
};

#
# pragma mark - Protocol
#

@protocol RideModelSource <NSObject>

#
# pragma mark Properties
#

@required

@property (weak, nonatomic) Ride* ride;

@end

#
# pragma mark - Interface
#

@interface Ride (RideHelpers) <ORNDataObject>

#
# pragma mark Initializers
#

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
								 andDateTime:(NSDate*)dateTime
								andPlacemark:(CLPlacemark*)placemark
						 andRideLocationType:(RideLocationType)rideLocationType;

- (instancetype)initWithAttributes:(NSDictionary<NSString*,id>*)attributes
		   andManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
					  andGeocoder1:(CLGeocoder*)geocoder1
					  andGeocoder2:(CLGeocoder*)geocoder2
						 andSender:(id)sender;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel*)managedObjectModel;

+ (instancetype)rideWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
								 andDateTime:(NSDate*)dateTime
								andPlacemark:(CLPlacemark*)placemark
						 andRideLocationType:(RideLocationType)rideLocationType;

+ (instancetype)rideWithAttributes:(NSDictionary<NSString*,id>*)attributes
		   andManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
					  andGeocoder1:(CLGeocoder*)geocoder1
					  andGeocoder2:(CLGeocoder*)geocoder2
						 andSender:(id)sender;
	
+ (instancetype)rideWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (instancetype)rideWithManagedObjectModel:(NSManagedObjectModel*)managedObjectModel;

#
# pragma mark Notifications
#

+ (void)addCreatedObserver:(id)observer withSelector:(SEL)selector;
+ (void)addDeletedObserver:(id)observer withSelector:(SEL)selector;
+ (void)addUpdatedObserver:(id)observer withSelector:(SEL)selector;

+ (Ride*)rideFromNotification:(NSNotification*)notification;

+ (BOOL)isUpdatedLocationStartFromNotification:(NSNotification*)notification;
+ (BOOL)isUpdatedLocationEndFromNotification:(NSNotification*)notification;
+ (BOOL)isUpdatedTeamAssignedFromNotification:(NSNotification*)notification;

- (void)postNotificationCreatedWithSender:(id)sender;
- (void)postNotificationDeletedWithSender:(id)sender;

- (void)postNotificationUpdatedWithSender:(id)sender;

- (void)postNotificationUpdatedWithSender:(id)sender
				  andUpdatedLocationStart:(BOOL)updatedLocationStart
					andUpdatedLocationEnd:(BOOL)updatedLocationEnd;

- (void)postNotificationUpdatedWithSender:(id)sender
				   andUpdatedTeamAssigned:(BOOL)updatedTeamAssigned;

- (void)postNotificationUpdatedWithSender:(id)sender
				  andUpdatedLocationStart:(BOOL)updatedLocationStart
					andUpdatedLocationEnd:(BOOL)updatedLocationEnd
				   andUpdatedTeamAssigned:(BOOL)updatedTeamAssigned;

#
# pragma mark Instance Helpers
#

- (void)assignTeam:(Team*)team withSender:(id)sender;

- (void)updateLocationWithRideLocationType:(RideLocationType)rideLocationType
							   andLatitude:(CLLocationDegrees)latitude
							  andLongitude:(CLLocationDegrees)longitude
								 andStreet:(NSString*)street
								   andCity:(NSString*)city
								  andState:(NSString*)state
								andAddress:(NSString*)address;

- (void)clearLocationWithRideLocationType:(RideLocationType)rideLocationType;

- (void)tryUpdateLocationWithAddressString:(NSString*)addressString
					   andRideLocationType:(RideLocationType)rideLocationType
		andNeedsUpdateTeamAssignedLocation:(BOOL)needsUpdateTeamAssignedLocation
							   andGeocoder:(CLGeocoder*)geocoder
								 andSender:(id)sender;

- (void)tryUpdateMainRouteWithSender:(id)sender;

- (void)tryUpdateMainRouteWithNeedsUpdateTeamAssignedLocation:(BOOL)needsUpdateTeamAssignedLocation
										  andRideLocationType:(RideLocationType)rideLocationType
												  andGeocoder:(CLGeocoder*)geocoder
													andSender:(id)sender;

- (void)tryUpdatePrepRouteWithLatitude:(NSNumber*)latitude
						  andLongitude:(NSNumber*)longitude
							andIsFirst:(BOOL)isFirst
							 andSender:(id)sender;

- (void)tryUpdateTeamAssignedLocationWithRideLocationType:(RideLocationType)rideLocationType
											  andGeocoder:(CLGeocoder*)geocoder
												andSender:(id)sender;

- (void)clearMainRoute;
- (void)clearPrepRoute;

- (BOOL)isPreDispatch;
- (BOOL)isDispatched;
- (BOOL)isPreTransport;
- (BOOL)isTransporting;
- (BOOL)isActive;

- (NSString*)getStatusText;
- (NSString*)getStatusTextShort;

- (NSString*)getPassengerName;
- (NSDate*)getRouteDateTimeEnd;

- (CLLocationCoordinate2D)getLocationStartCoordinate;
- (CLLocationCoordinate2D)getLocationEndCoordinate;
- (CLLocationCoordinate2D)getLocationPrepCoordinate;

- (NSNumber*)latitudeWithRideLocationType:(RideLocationType)rideLocationType;
- (NSNumber*)longitudeWithRideLocationType:(RideLocationType)rideLocationType;
- (MKMapItem*)mapItemWithRideLocationType:(RideLocationType)rideLocationType;

- (MKPolyline*)polylineWithRideRouteType:(RideRouteType)rideRouteType;

- (NSTimeInterval)getDurationWithRideRouteType:(RideRouteType)rideRouteType;
- (CLLocationDistance)getDistanceWithRideRouteType:(RideRouteType)rideRouteType;

#
# pragma mark Class Helpers
#

+ (void)tryCreateRideWithAddressString:(NSString*)addressString
						   andGeocoder:(CLGeocoder*)geocoder
							 andSender:(id)sender;

@end
