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
# pragma mark Methods
#

+ (BOOL)isTeamAssignedToRide:(Ride*)ride;

@end
