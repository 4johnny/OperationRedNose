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
	
	return [[Ride alloc] initWithEntity:[NSEntityDescription entityForName:@"Ride" inManagedObjectContext:managedObjectContext]
		 insertIntoManagedObjectContext:managedObjectContext
			withLocationStartCoordinate:locationStartCoordinate
				andLocationStartAddress:locationStartAddress
				   andLocationStartCity:locationStartCity];
}


#
# pragma mark Class Methods
#

+ (BOOL)isTeamAssignedToRide:(Ride*)ride {

	return (ride.assignedTeam && ride.assignedTeam.length > 0);
}


@end
