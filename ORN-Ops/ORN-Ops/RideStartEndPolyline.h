//
//  RideStartEndPolyline.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-10.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "BasePolyline.h"
#import "Ride+RideHelpers.h"

#
# pragma mark - Interface
#

@interface RideStartEndPolyline : BasePolyline <RideModelSource>

#
# pragma mark Properties
#

// TODO: Consider whether ride property should be weak
@property (nonatomic) Ride* ride;

#
# pragma mark Initializers
#

- (instancetype)initWithRide:(Ride*)ride andPolyline:(MKPolyline*)polyline;
- (instancetype)init;

+ (instancetype)rideStartEndPolylineWithRide:(Ride*)ride andPolyline:(MKPolyline*)polyline;

@end
