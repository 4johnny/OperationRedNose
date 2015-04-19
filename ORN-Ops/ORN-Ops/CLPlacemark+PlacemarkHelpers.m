//
//  CLPlacemark+PlacemarkHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-04-19.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import "CLPlacemark+PlacemarkHelpers.h"


#
# pragma mark Implementation
#


@implementation CLPlacemark (PlacemarkHelpers)


#
# pragma mark Address Methods
#


+ (NSDictionary*)addressDictionary:(NSMutableDictionary*)addressDictionary
						withStreet:(NSString*)street
						   andCity:(NSString*)city
						  andState:(NSString*)state
							andZIP:(NSString*)ZIP
						andCountry:(NSString*)country
					andCountryCode:(NSString*)countryCode {
	
	if (!addressDictionary) {
		
		addressDictionary = [NSMutableDictionary dictionaryWithCapacity:6];
	}
	
	if (street.length > 0) {
		
		addressDictionary[(NSString*)kABPersonAddressStreetKey] = street;
	}
	
	if (city.length > 0) {
		
		addressDictionary[(NSString*)kABPersonAddressCityKey] = city;
	}
	
	if (state.length > 0) {
		
		addressDictionary[(NSString*)kABPersonAddressStateKey] = state;
	}
	
	if (ZIP.length > 0) {
		
		addressDictionary[(NSString*)kABPersonAddressZIPKey] = ZIP;
	}
	
	if (country.length > 0) {
		
		addressDictionary[(NSString*)kABPersonAddressCountryKey] = country;
	}
	
	if (countryCode.length > 0) {
		
		addressDictionary[(NSString*)kABPersonAddressCountryCodeKey] = countryCode;
	}
	
	return addressDictionary;
}


- (NSString*)getAddressString {
	
	NSString* street = [self getAddressStreet];
	NSString* city = [self getAddressCity];
	
	if (street && city) return [NSString stringWithFormat:@"%@, %@", street, city];
	
	return [NSString stringWithFormat:@"%@ (%.3f,%.3f)", self.name, self.location.coordinate.latitude, self.location.coordinate.longitude];
}


- (NSString*)getAddressStringFromDictionaryWithAddCountryName:(BOOL)addCountryName {

	return ABCreateStringWithAddressDictionary(self.addressDictionary, addCountryName);
}


- (NSString*)getAddressStreet {
	
	return self.addressDictionary[(NSString*)kABPersonAddressStreetKey];
}


- (NSString*)getAddressCity {
	
	return self.addressDictionary[(NSString*)kABPersonAddressCityKey];
}


- (NSString*)getAddressState {
	
	return self.addressDictionary[(NSString*)kABPersonAddressStateKey];
}


- (NSString*)getAddressZIP {
	
	return self.addressDictionary[(NSString*)kABPersonAddressZIPKey];
}


- (NSString*)getAddressCountry {
	
	return self.addressDictionary[(NSString*)kABPersonAddressCountryKey];
}


- (NSString*)getAddressCountryCode {
	
	return self.addressDictionary[(NSString*)kABPersonAddressCountryCodeKey];
}


@end
