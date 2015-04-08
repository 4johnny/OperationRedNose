//
//  Ride.h
//  ORN-Ops
//
//  Created by Johnny on 2015-04-08.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Team;

@interface Ride : NSManagedObject

@property (nonatomic, retain) NSDate * dateTimeStart;
@property (nonatomic, retain) NSDecimalNumber * donationAmount;
@property (nonatomic, retain) NSString * locationEndAddress;
@property (nonatomic, retain) NSString * locationEndCity;
@property (nonatomic, retain) NSNumber * locationEndLatitude;
@property (nonatomic, retain) NSNumber * locationEndLongitude;
@property (nonatomic, retain) NSNumber * locationPrepLatitude;
@property (nonatomic, retain) NSNumber * locationPrepLongitude;
@property (nonatomic, retain) NSString * locationStartAddress;
@property (nonatomic, retain) NSString * locationStartCity;
@property (nonatomic, retain) NSNumber * locationStartLatitude;
@property (nonatomic, retain) NSNumber * locationStartLongitude;
@property (nonatomic, retain) NSString * locationTransferFrom;
@property (nonatomic, retain) NSString * locationTransferTo;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * passengerCount;
@property (nonatomic, retain) NSString * passengerNameFirst;
@property (nonatomic, retain) NSString * passengerNameLast;
@property (nonatomic, retain) NSString * passengerPhoneNumber;
@property (nonatomic, retain) NSNumber * routeMainDistance;
@property (nonatomic, retain) NSNumber * routeMainDuration;
@property (nonatomic, retain) id routeMainPolyline;
@property (nonatomic, retain) NSNumber * routePrepDistance;
@property (nonatomic, retain) NSNumber * routePrepDuration;
@property (nonatomic, retain) id routePrepPolyline;
@property (nonatomic, retain) NSString * sourceName;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * vehicleDescription;
@property (nonatomic, retain) NSNumber * vehicleSeatBeltCount;
@property (nonatomic, retain) NSNumber * vehicleTransmission;
@property (nonatomic, retain) Team *teamAssigned;

@end
