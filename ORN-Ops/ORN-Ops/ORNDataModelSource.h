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

@end


#endif // ORN_Ops_ORNDataModelSource_h
