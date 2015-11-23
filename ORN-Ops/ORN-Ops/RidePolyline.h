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
# pragma mark - Constants
#

#define RIDE_POLYLINE_ANNOTATION_ID	@"ridePolylineAnnotation"

#
# pragma mark - Interface
#

@interface RidePolyline : BasePolyline <RideModelSource>

#
# pragma mark Properties
#

@property (weak, nonatomic) Ride* ride;
@property (nonatomic) RideRouteType rideRouteType;

#
# pragma mark Initializers
#

- (instancetype)initWithPolyline:(MKPolyline*)polyline
						 andRide:(Ride*)ride
				andRideRouteType:(RideRouteType)rideRouteType;

- (instancetype)init;

+ (instancetype)ridePolylineWithPolyline:(MKPolyline*)polyline
								 andRide:(Ride*)ride
						andRideRouteType:(RideRouteType)rideRouteType;

+ (instancetype)ridePolyline:(RidePolyline*)ridePolyline
				withPolyline:(MKPolyline*)polyline
					 andRide:(Ride*)ride
			andRideRouteType:(RideRouteType)rideRouteType;

@end
