//
//  AppDelegate.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-22.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


#
# pragma mark - Interface
#

@interface AppDelegate : UIResponder <UIApplicationDelegate>

#
# pragma mark Properties
#

@property (strong, nonatomic) UIWindow* window;

#
# pragma mark Core Data Properties
#

@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;

#
# pragma mark Core Data Helpers
#

- (void)saveManagedObjectContext;

#
# pragma mark Helpers
#

+ (NSURL*)applicationDocumentsDirectoryURL;

@end

