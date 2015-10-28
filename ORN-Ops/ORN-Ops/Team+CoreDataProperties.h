//
//  Team+CoreDataProperties.h
//  ORN-Ops
//
//  Created by Johnny on 2015-10-27.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Team.h"

NS_ASSUME_NONNULL_BEGIN

@interface Team (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *emailAddress;
@property (nullable, nonatomic, retain) NSNumber *isActive;
@property (nullable, nonatomic, retain) NSNumber *isMascot;
@property (nullable, nonatomic, retain) NSString *locationCurrentAddress;
@property (nullable, nonatomic, retain) NSString *locationCurrentCity;
@property (nullable, nonatomic, retain) NSNumber *locationCurrentIsManual;
@property (nullable, nonatomic, retain) NSNumber *locationCurrentLatitude;
@property (nullable, nonatomic, retain) NSNumber *locationCurrentLongitude;
@property (nullable, nonatomic, retain) NSString *locationCurrentState;
@property (nullable, nonatomic, retain) NSString *locationCurrentStreet;
@property (nullable, nonatomic, retain) NSDate *locationCurrentTime;
@property (nullable, nonatomic, retain) NSString *members;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *notes;
@property (nullable, nonatomic, retain) NSString *phoneNumber;
@property (nullable, nonatomic, retain) NSSet<Ride *> *ridesAssigned;

@end

@interface Team (CoreDataGeneratedAccessors)

- (void)addRidesAssignedObject:(Ride *)value;
- (void)removeRidesAssignedObject:(Ride *)value;
- (void)addRidesAssigned:(NSSet<Ride *> *)values;
- (void)removeRidesAssigned:(NSSet<Ride *> *)values;

@end

NS_ASSUME_NONNULL_END
