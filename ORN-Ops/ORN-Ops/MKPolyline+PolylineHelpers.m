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
	NSArray* latitudes = [decoder decodeObjectForKey:POLYLINE_LATITUDES_CODING_KEY];
	if (latitudes.count == 0) return [self init];
	NSArray* longitudes = [decoder decodeObjectForKey:POLYLINE_LONGITUDES_CODING_KEY];
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
	NSMutableArray* latitudes = [NSMutableArray arrayWithCapacity:pointCount];
	NSMutableArray* longitudes = [NSMutableArray arrayWithCapacity:pointCount];
	for (int i = 0; i < pointCount; i++) {
		
		latitudes[i] = [NSNumber numberWithDouble:coordinates[i].latitude];
		longitudes[i] = [NSNumber numberWithDouble:coordinates[i].longitude];
	}
	
	// Encode coordinate arrays
	[encoder encodeObject:latitudes forKey:POLYLINE_LATITUDES_CODING_KEY];
	[encoder encodeObject:longitudes forKey:POLYLINE_LONGITUDES_CODING_KEY];
}


@end
