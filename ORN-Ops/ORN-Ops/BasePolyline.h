//
//  BasePolyline.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-10.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>

#
# pragma mark - Interface
#

@interface BasePolyline : NSObject <MKOverlay>

// NOTE: Decorator for MKPolyline, which cannot be subclassed effectively (due to missing designated initializers)

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

- (instancetype)initWithPolyline:(MKPolyline*)polyline;
- (instancetype)init;

+ (instancetype)basePolylineWithPolyline:(MKPolyline*)polyline;

#
# pragma mark MKMultiPoint
#
// NOTE: Required for rendering by MKPolylineRenderer

- (void)getCoordinates:(CLLocationCoordinate2D*)coords range:(NSRange)range;

@end
