//
//  Ride+RideMapAnnotation.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-24.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "Ride+RideMapAnnotation.h"


#
# pragma mark - Implementation
#


@implementation Ride (RideMapAnnotation)


#
# pragma mark <MKAnnotation>
#


- (CLLocationCoordinate2D)coordinate {
	
	return CLLocationCoordinate2DMake(self.locationStartLatitude.doubleValue, self.locationStartLongitude.doubleValue);
}


- (NSString*)title {
	
	return [NSString stringWithFormat:@"Ride: %@ %@", self.passengerNameFirst, self.passengerNameLast];
}


- (NSString*)subtitle {

	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	NSString* dateTime = [dateFormatter stringFromDate:self.dateTimeStart];
	
	return [NSString stringWithFormat:@"%@ %@", dateTime, self.locationStartAddress];
}


@end
