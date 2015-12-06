//
//  AppDelegate.h
//  ORN-Intake
//
//  Created by Johnny on 2015-12-03.
//  Copyright © 2015 Payso Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


#
# pragma mark - Interface
#

@interface AppDelegate : UIResponder <UIApplicationDelegate>

#
# pragma mark Initializers
#

+ (AppDelegate*)sharedAppDelegate;

#
# pragma mark Properties
#

@property (strong, nonatomic) UIWindow* window;

// Persisted in user defaults (for now)
// TODO: Persist Telegram info in keychain instead of user defaults
@property (strong, nonatomic) NSString* telegramBotAuthToken;
@property (strong, nonatomic) NSNumber* telegramBotUserID;

#
# pragma mark Core Data Properties
#

@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

- (void)saveContext;

#
# pragma mark Helper Methods
#

- (NSURL*)applicationDocumentsDirectory;

@end

