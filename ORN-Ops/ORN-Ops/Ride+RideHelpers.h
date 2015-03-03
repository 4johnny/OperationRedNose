//
//  Ride+RideHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "Ride.h"

#
# pragma mark - Constants
#

#define RIDE_ENTITY_NAME	@"Ride"

#define RIDE_STATUS_STRING_NONE			@"None"
#define RIDE_STATUS_STRING_NEW			@"New"
#define RIDE_STATUS_STRING_CONFIRMED	@"Confirmed"
#define RIDE_STATUS_STRING_PROGRESSING	@"Progressing"
#define RIDE_STATUS_STRING_COMPLETED	@"Completed"
#define RIDE_STATUS_STRING_TRANSFERRED	@"Transferred"
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
	RideStatus_Transferred =	5,
	
	RideStatus_Cancelled =		9
};

#
# pragma mark - Interface
#

@interface Ride (RideHelpers)

#
# pragma mark Initializers
#

+ (instancetype)rideWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
				  andLocationStartCoordinate:(CLLocationCoordinate2D)locationStartCoordinate
					 andLocationStartAddress:(NSString*)locationStartAddress
						andLocationStartCity:(NSString*)locationStartCity;

#
# pragma mark Helpers
#

- (NSString*)getPassengerName;

+ (NSString*)stringFromStatus:(RideStatus)status;
+ (RideStatus)statusFromString:(NSString*)statusString;

@end
