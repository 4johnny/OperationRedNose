//
//  MKMapCamera+MapCameraHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-10-26.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#import "MKMapCamera+MapCameraHelpers.h"


#
# pragma mark - Implementation
#


@implementation MKMapCamera (MapCameraHelpers)


#
# pragma mark Property Accessors
#


- (CLLocationDistance)distanceFromCenter {

	return self.pitch <= 0 ? self.altitude : (self.altitude / cos(self.pitch * M_PI / 180));
}


@end
