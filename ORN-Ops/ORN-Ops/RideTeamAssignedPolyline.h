//
//  RideTeamAssignedPolyline.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-09.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Ride+RideHelpers.h"

#
# pragma mark - Interface
#

@interface RideTeamAssignedPolyline : NSObject <MKOverlay>

// NOTE: Decorator for MKPolyline, which cannot be subclassed effectively (due to missing designated initializers)

#
# pragma mark Properties
#

// TODO: Consider whether ride property should be weak
@property (nonatomic) Ride* ride;

#
# pragma mark <MKOverlay> Properties
#

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly) MKMapRect boundingMapRect;

#
# pragma mark MKMultiPoint Properties
#
// NOTE: Required for rendering by MKPolylineRenderer

- (MKMapPoint*)points;
- (NSUInteger)pointCount;

#
# pragma mark Initializers
#

- (instancetype)initWithRide:(Ride*)ride andStartCoordinate:(CLLocationCoordinate2D*)startCoordinate;
- (instancetype)init;

+ (instancetype)rideTeamPolylineWithRide:(Ride*)ride andStartCoordinate:(CLLocationCoordinate2D*)startCoordinate;

#
# pragma mark MKMultiPoint
#
// NOTE: Required for rendering by MKPolylineRenderer

- (void)getCoordinates:(CLLocationCoordinate2D*)coords range:(NSRange)range;

@end
