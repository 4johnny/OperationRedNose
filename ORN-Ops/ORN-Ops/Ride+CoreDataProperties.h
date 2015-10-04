//
//  Ride+CoreDataProperties.h
//  ORN-Ops
//
//  Created by Johnny on 2015-10-03.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Ride.h"

NS_ASSUME_NONNULL_BEGIN

@interface Ride (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *dateTimeStart;
@property (nullable, nonatomic, retain) NSDecimalNumber *donationAmount;
@property (nullable, nonatomic, retain) NSString *locationEndAddress;
@property (nullable, nonatomic, retain) NSString *locationEndCity;
@property (nullable, nonatomic, retain) NSNumber *locationEndLatitude;
@property (nullable, nonatomic, retain) NSNumber *locationEndLongitude;
@property (nullable, nonatomic, retain) NSString *locationEndState;
@property (nullable, nonatomic, retain) NSString *locationEndStreet;
@property (nullable, nonatomic, retain) NSNumber *locationPrepLatitude;
@property (nullable, nonatomic, retain) NSNumber *locationPrepLongitude;
@property (nullable, nonatomic, retain) NSString *locationStartAddress;
@property (nullable, nonatomic, retain) NSString *locationStartCity;
@property (nullable, nonatomic, retain) NSNumber *locationStartLatitude;
@property (nullable, nonatomic, retain) NSNumber *locationStartLongitude;
@property (nullable, nonatomic, retain) NSString *locationStartState;
@property (nullable, nonatomic, retain) NSString *locationStartStreet;
@property (nullable, nonatomic, retain) NSString *locationTransferFrom;
@property (nullable, nonatomic, retain) NSString *locationTransferTo;
@property (nullable, nonatomic, retain) NSString *notes;
@property (nullable, nonatomic, retain) NSNumber *passengerCount;
@property (nullable, nonatomic, retain) NSString *passengerNameFirst;
@property (nullable, nonatomic, retain) NSString *passengerNameLast;
@property (nullable, nonatomic, retain) NSString *passengerPhoneNumber;
@property (nullable, nonatomic, retain) NSNumber *routeMainDistance;
@property (nullable, nonatomic, retain) NSNumber *routeMainDuration;
@property (nullable, nonatomic, retain) id routeMainPolyline;
@property (nullable, nonatomic, retain) NSNumber *routePrepDistance;
@property (nullable, nonatomic, retain) NSNumber *routePrepDuration;
@property (nullable, nonatomic, retain) id routePrepPolyline;
@property (nullable, nonatomic, retain) NSString *sourceName;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *vehicleDescription;
@property (nullable, nonatomic, retain) NSNumber *vehicleSeatBeltCount;
@property (nullable, nonatomic, retain) NSNumber *vehicleTransmission;
@property (nullable, nonatomic, retain) Team *teamAssigned;

@end

NS_ASSUME_NONNULL_END
