//
//  ORNDataModelSource.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-25.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#ifndef ORN_Ops_ORNDataModelSource_h
#define ORN_Ops_ORNDataModelSource_h

#
# pragma mark - Constants
#

#define ORN_ERROR_CODE_DATA_MODEL_PERSISTENT_STORE_ADD		101 // NSInteger
#define ORN_ERROR_CODE_DATA_MODEL_PERSISTENT_STORE_REMOVE	102 // NSInteger

#
# pragma mark - Protocol
#

@protocol ORNDataModelSource <NSObject>

#
# pragma mark Properties
#

@required

@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;

#
# pragma mark Methods
#

@required

- (void)saveManagedObjectContext;
- (void)removePersistentStore;

@end


#endif // ORN_Ops_ORNDataModelSource_h
