//
//  BasePolyline.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-10.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "BasePolyline.h"

#
# pragma mark - Interface
#


@interface BasePolyline ()

@property (nonatomic) MKPolyline* polyline;
@property (nonatomic) CLLocationCoordinate2D locationCoordinate;

@end


#
# pragma mark - Implementation
#


@implementation BasePolyline


#
# pragma mark Initializers
#


- (instancetype)initWithPolyline:(MKPolyline*)polyline {
	
	self = [super init];
	if (self) {

		_polyline = polyline;
		
		// Pre-calculate coordinate for midpoint of points, for efficiency
		if (_polyline.pointCount > 0) {
			
			NSUInteger midpointIndex = _polyline.pointCount / 2;
			
			if (_polyline.pointCount % 2 == 1) {
				
				_locationCoordinate = MKCoordinateForMapPoint(_polyline.points[midpointIndex]);
				
			} else {
				
				MKMapPoint mapPoint1 = _polyline.points[midpointIndex - 1];
				MKMapPoint mapPoint2 = _polyline.points[midpointIndex];
				
				_locationCoordinate = MKCoordinateForMapPoint(MKMapPointMake((mapPoint1.x + mapPoint2.x) / 2.0, (mapPoint1.y + mapPoint2.y) / 2.0));
			}
		}
	}
	
	return self;
}


- (instancetype)init {
	
	return [self initWithPolyline:nil];
}


+ (instancetype)basePolylineWithPolyline:(MKPolyline*)polyline {
	
	return [[BasePolyline alloc] initWithPolyline:polyline];
}


#
# pragma mark <MKOverlay>
#


- (CLLocationCoordinate2D)coordinate {

	return self.locationCoordinate;
}


- (MKMapRect)boundingMapRect {
	
	return self.polyline.boundingMapRect;
}


- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
	
	return [self.polyline intersectsMapRect:mapRect];
}


#
# pragma mark MKMultiPoint
#
// NOTE: Required for rendering by MKPolylineRenderer


- (MKMapPoint*)points {
	
	return [self.polyline points];
}


- (NSUInteger)pointCount {
	
	return [self.polyline pointCount];
}


- (void)getCoordinates:(CLLocationCoordinate2D*)coords range:(NSRange)range {
	
	return [self.polyline getCoordinates:coords range:range];
}


@end
