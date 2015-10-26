//
//  MKMapCamera+MapCameraHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-10-26.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>


#
# pragma mark - Implementation
#


@interface MKMapCamera (MapCameraHelpers)

#
# pragma mark Properties
#

@property (readonly, nonatomic) CLLocationDistance distanceFromCenter;

@end
