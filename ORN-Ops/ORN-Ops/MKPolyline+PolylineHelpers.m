//
//  MKPolyline+PolylineHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-04-03.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "MKPolyline+PolylineHelpers.h"


#
# pragma mark - Constants
#

#define POLYLINE_LATITUDES_CODING_KEY	@"MKPolyline.latitudes"
#define POLYLINE_LONGITUDES_CODING_KEY	@"MKPolyline.longitudes"


#
# pragma mark - Implementation
#


@implementation MKPolyline (PolylineHelpers)


#
# pragma mark <NSCoding>
#


- (instancetype)initWithCoder:(NSCoder*)decoder {
	
	// Decode coordinates from arrays - if none, we are done
	NSArray<NSNumber*>* latitudes = [decoder decodeObjectForKey:POLYLINE_LATITUDES_CODING_KEY];
	if (latitudes.count <= 0) return [self init];
	NSArray<NSNumber*>* longitudes = [decoder decodeObjectForKey:POLYLINE_LONGITUDES_CODING_KEY];
	NSUInteger pointCount = latitudes.count;
	
	// Translated coding-enabled objects into coordinates
	CLLocationCoordinate2D coordinates[pointCount];
	for (int i = 0; i < pointCount; i++) {
		
		coordinates[i] = CLLocationCoordinate2DMake(((NSNumber*)latitudes[i]).doubleValue, ((NSNumber*)longitudes[i]).doubleValue);
	}
	
	return [MKPolyline polylineWithCoordinates:coordinates count:pointCount];
}


- (void)encodeWithCoder:(NSCoder*)encoder {
	
	// Grab coordinates - if none, we are done
	// NOTE: Map locations must always be persisted as coordinates, not map points
	NSUInteger pointCount = self.pointCount;
	if (pointCount <= 0) return;
	CLLocationCoordinate2D coordinates[pointCount];
	[self getCoordinates:coordinates range:(NSRange){0, pointCount}];
	
	// Translate coordinates into coding-enabled objects
	// NOTE: For simplicity, use 2 parallel arrays
	NSMutableArray<NSNumber*>* latitudes = [NSMutableArray arrayWithCapacity:pointCount];
	NSMutableArray<NSNumber*>* longitudes = [NSMutableArray arrayWithCapacity:pointCount];
	for (int i = 0; i < pointCount; i++) {
		
		latitudes[i] = @(coordinates[i].latitude);
		longitudes[i] = @(coordinates[i].longitude);
	}
	
	// Encode coordinate arrays
	[encoder encodeObject:latitudes forKey:POLYLINE_LATITUDES_CODING_KEY];
	[encoder encodeObject:longitudes forKey:POLYLINE_LONGITUDES_CODING_KEY];
}


- (CLLocationCoordinate2D)getCoordinateAtIndex:(NSUInteger)index {

	// Grab coordinate - if none, we are done
	NSUInteger pointCount = self.pointCount;
	if (pointCount <= 0 || index >= pointCount)
		return (CLLocationCoordinate2D){NSNotFound, NSNotFound};
	
	CLLocationCoordinate2D coordinates[1];
	[self getCoordinates:coordinates range:(NSRange){index, 1}];
	
	return coordinates[0];
}


- (CLLocationCoordinate2D)getFirstCoordinate {

	return [self getCoordinateAtIndex:0];
}


- (CLLocationCoordinate2D)getLastCoordinate {
	
	return [self getCoordinateAtIndex:(self.pointCount - 1)];
}


@end
