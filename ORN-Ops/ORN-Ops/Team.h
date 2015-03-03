//
//  Team.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-02.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Ride;

@interface Team : NSManagedObject

@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSNumber * isMascot;
@property (nonatomic, retain) NSString * locationCurrentAddress;
@property (nonatomic, retain) NSNumber * locationCurrentLatitude;
@property (nonatomic, retain) NSNumber * locationCurrentLongitude;
@property (nonatomic, retain) NSString * members;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSSet *ridesAssigned;
@end

@interface Team (CoreDataGeneratedAccessors)

- (void)addRidesAssignedObject:(Ride *)value;
- (void)removeRidesAssignedObject:(Ride *)value;
- (void)addRidesAssigned:(NSSet *)values;
- (void)removeRidesAssigned:(NSSet *)values;

@end
