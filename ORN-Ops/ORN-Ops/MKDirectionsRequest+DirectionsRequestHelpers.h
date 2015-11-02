//
//  MKDirectionsRequest+DirectionsRequestHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-11-02.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>

#
# pragma mark - Interface
#

@interface MKDirectionsRequest (DirectionsRequestHelpers)

#
# pragma mark Initializers
#

+ (instancetype)directionsRequestWithDepartureDate:(NSDate*)departureDate
								andSourcePlacemark:(MKPlacemark*)sourcePlaceMark
						   andDestinationPlacemark:(MKPlacemark*)destinationPlacemark;
	
+ (instancetype)directionsRequestWithStartDate:(NSDate*)startDate
							 andSourceLatitude:(NSNumber*)sourceLatitude
							andSourceLongitude:(NSNumber*)sourceLongitude
						andDestinationLatitude:(NSNumber*)destinationLatitude
					   andDestinationLongitude:(NSNumber*)destinationLongitude;

@end
