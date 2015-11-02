//
//  MKDirectionsRequest+DirectionsRequestHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-11-02.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#import "MKDirectionsRequest+DirectionsRequestHelpers.h"


#
# pragma mark - Implementation
#


@implementation MKDirectionsRequest (DirectionsRequestHelpers)


#
# pragma mark Initializers
#


+ (instancetype)directionsRequestWithDepartureDate:(NSDate*)departureDate
								andSourcePlacemark:(MKPlacemark*)sourcePlaceMark
						   andDestinationPlacemark:(MKPlacemark*)destinationPlacemark {
	
	if (!departureDate || !sourcePlaceMark || !destinationPlacemark) return nil;
	
	MKDirectionsRequest* directionsRequest = [[MKDirectionsRequest alloc] init];
	directionsRequest.departureDate = departureDate;
	directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourcePlaceMark];
	directionsRequest.destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
	directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
	directionsRequest.requestsAlternateRoutes = NO;
	
	return directionsRequest;
}


+ (instancetype)directionsRequestWithDepartureDate:(NSDate*)departureDate
								 andSourceLatitude:(NSNumber*)sourceLatitude
								andSourceLongitude:(NSNumber*)sourceLongitude
							andDestinationLatitude:(NSNumber*)destinationLatitude
						   andDestinationLongitude:(NSNumber*)destinationLongitude {
	
	if (!departureDate || !sourceLatitude || !sourceLongitude || !destinationLatitude || !destinationLongitude) return nil;
	
	// Create placemarks for ride start and end locations
	MKPlacemark* sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(sourceLatitude.doubleValue, sourceLongitude.doubleValue) addressDictionary:nil];
	
	MKPlacemark* destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(destinationLatitude.doubleValue, destinationLongitude.doubleValue) addressDictionary:nil];
	
	// Create directions request for route by car for ride start time
	return [MKDirectionsRequest directionsRequestWithDepartureDate:departureDate
												andSourcePlacemark:sourcePlacemark
										   andDestinationPlacemark:destinationPlacemark];
}


@end
