//
//  MKPolyline+PolylineHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-04-03.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>

#
# pragma mark - Interface
#

@interface MKPolyline (PolylineHelpers) <NSCoding>

- (CLLocationCoordinate2D)getCoordinateAtIndex:(NSUInteger)index;
- (CLLocationCoordinate2D)getFirstCoordinate;
- (CLLocationCoordinate2D)getLastCoordinate;

@end
