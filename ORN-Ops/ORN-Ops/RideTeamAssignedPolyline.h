//
//  RideTeamAssignedPolyline.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-09.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "BasePolyline.h"
#import "Ride+RideHelpers.h"

#
# pragma mark - Interface
#

@interface RideTeamAssignedPolyline : BasePolyline

#
# pragma mark Properties
#

// TODO: Consider whether ride property should be weak
@property (nonatomic) Ride* ride;

#
# pragma mark Initializers
#

- (instancetype)initWithRide:(Ride*)ride andStartCoordinate:(CLLocationCoordinate2D*)startCoordinate;
- (instancetype)init;

+ (instancetype)rideTeamAssignedPolylineWithRide:(Ride*)ride andStartCoordinate:(CLLocationCoordinate2D*)startCoordinate;

@end
