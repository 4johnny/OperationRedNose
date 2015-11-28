//
//  AppDelegate.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-22.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ORNDataModelSource.h"


#
# pragma mark - Interface
#

@interface AppDelegate : UIResponder <UIApplicationDelegate, ORNDataModelSource>

#
# pragma mark Initializers
#

+ (AppDelegate*)sharedAppDelegate;

#
# pragma mark Properties
#

@property (strong, nonatomic) UIWindow* window;

// TODO: Persist Telegram auth token to keychain instead of user defaults
@property (strong, nonatomic) NSString* telegramBotAuthToken; // Persisted to user defaults (for now)
@property (strong, nonatomic) NSNumber* telegramBotOffset; // Persisted to user defaults

#
# pragma mark Core Data Properties
#

@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;

#
# pragma mark Helper Methods
#

+ (NSURL*)applicationDocumentsDirectoryURL;

- (void)startTelegramBotPoll;
- (void)stopTelegramBotPoll;

@end

