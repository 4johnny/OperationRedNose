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
	
	return _polyline.coordinate;
}


- (MKMapRect)boundingMapRect {
	
	return _polyline.boundingMapRect;
}


- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
	
	return [_polyline intersectsMapRect:mapRect];
}


#
# pragma mark MKMultiPoint
#
// NOTE: Required for rendering by MKPolylineRenderer


- (MKMapPoint*)points {
	
	return [_polyline points];
}


- (NSUInteger)pointCount {
	
	return [_polyline pointCount];
}


- (void)getCoordinates:(CLLocationCoordinate2D*)coords range:(NSRange)range {
	
	return [_polyline getCoordinates:coords range:range];
}


@end
