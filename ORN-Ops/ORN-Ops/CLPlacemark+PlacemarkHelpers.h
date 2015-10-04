//
//  CLPlacemark+PlacemarkHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-04-19.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#
# pragma mark Interface
#

@interface CLPlacemark (PlacemarkHelpers)

#
# pragma mark Address Methods
#

+ (NSDictionary<NSString*,NSString*>*)addressDictionary:(NSMutableDictionary<NSString*,NSString*>*)addressDictionary
											 withStreet:(NSString*)street
												andCity:(NSString*)city
											   andState:(NSString*)state
												 andZIP:(NSString*)ZIP
											 andCountry:(NSString*)country
										 andCountryCode:(NSString*)countryCode;

- (NSString*)getAddressString;
- (NSString*)getAddressStringFromDictionaryWithAddCountryName:(BOOL)addCountryName;

- (NSString*)getAddressStreet;
- (NSString*)getAddressCity;
- (NSString*)getAddressState;
- (NSString*)getAddressZIP;
- (NSString*)getAddressCountry;
- (NSString*)getAddressCountryCode;

@end
