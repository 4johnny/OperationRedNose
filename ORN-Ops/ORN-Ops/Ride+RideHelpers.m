//
//  Ride+RideHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "Ride+RideHelpers.h"


#
# pragma mark - Implementation
#


@implementation Ride (RideHelpers)


#
# pragma mark Initializers
#

- (instancetype)initWithEntity:(NSEntityDescription*)entityDescription
insertIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
   withLocationStartCoordinate:(CLLocationCoordinate2D)locationStartCoordinate
	   andLocationStartAddress:(NSString*)locationStartAddress
		  andLocationStartCity:(NSString*)locationStartCity {
	
	self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];
	if (self) {
		
		self.dateTimeStart = [NSDate date];
		
		self.locationStartLatitude = [NSNumber numberWithDouble:locationStartCoordinate.latitude];
		self.locationStartLongitude = [NSNumber numberWithDouble:locationStartCoordinate.longitude];
		self.locationStartAddress = locationStartAddress;
		self.locationStartCity = locationStartCity;
	}
	
	return self;
}


+ (instancetype)rideWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
				  andLocationStartCoordinate:(CLLocationCoordinate2D)locationStartCoordinate
					 andLocationStartAddress:(NSString*)locationStartAddress
						andLocationStartCity:(NSString*)locationStartCity {
	
	return [[Ride alloc] initWithEntity:[NSEntityDescription entityForName:RIDE_ENTITY_NAME inManagedObjectContext:managedObjectContext]
		 insertIntoManagedObjectContext:managedObjectContext
			withLocationStartCoordinate:locationStartCoordinate
				andLocationStartAddress:locationStartAddress
				   andLocationStartCity:locationStartCity];
}


#
# pragma mark Helpers
#


- (NSString*)getPassengerName {
	
	// If first or last name is empty return other one
	if (!self.passengerNameLast || self.passengerNameLast.length <= 0) return self.passengerNameFirst;
	if (!self.passengerNameFirst || self.passengerNameFirst.length <= 0) return self.passengerNameLast;
	
	// Combine first and last name
	return [NSString stringWithFormat:@"%@ %@", self.passengerNameFirst, self.passengerNameLast];
}


+ (NSString*)stringFromStatus:(RideStatus)status {
	
	switch (status) {
			
		case RideStatus_New:
			return RIDE_STATUS_STRING_NEW;
			
		case RideStatus_Confirmed:
			return RIDE_STATUS_STRING_CONFIRMED;
			
		case RideStatus_Progressing:
			return RIDE_STATUS_STRING_PROGRESSING;
			
		case RideStatus_Completed:
			return RIDE_STATUS_STRING_COMPLETED;

		case RideStatus_Cancelled:
			return RIDE_STATUS_STRING_CANCELLED;
			
		default:
		case RideStatus_None:
			return RIDE_STATUS_STRING_NONE;
	}
}


+ (RideStatus)statusFromString:(NSString*)statusString {
	
	if (!statusString || statusString.length <= 0) return RideStatus_None;
	
	if ([statusString isEqualToString:RIDE_STATUS_STRING_NEW]) return RideStatus_New;
	if ([statusString isEqualToString:RIDE_STATUS_STRING_CONFIRMED]) return RideStatus_Confirmed;
	if ([statusString isEqualToString:RIDE_STATUS_STRING_PROGRESSING]) return RideStatus_Progressing;
	if ([statusString isEqualToString:RIDE_STATUS_STRING_COMPLETED]) return RideStatus_Completed;
	
	if ([statusString isEqualToString:RIDE_STATUS_STRING_CANCELLED]) return RideStatus_Cancelled;
	
	return RideStatus_None;
}


@end
