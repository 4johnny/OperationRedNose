//
//  AppDelegate.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-22.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTabBarController.h"


#
# pragma mark - Constants
#

#define CORE_DATA_STORE_SQL_FILE_NAME	@"ORN-Ops.sqlite"
#define CORE_DATA_MODEL_RESOURCE_NAME	@"ORN-Ops"

#
# pragma mark - Interface
#


@interface AppDelegate ()


#
# pragma mark Core Data Properties
#

// NOTE: Private accessors are read-write
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel* managedObjectModel;

@end


#
# pragma mark - Implementation
#


@implementation AppDelegate


- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
	// Override point for customization after application launch.

	return YES;
}


- (void)applicationWillResignActive:(UIApplication*)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication*)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	
	// Saves changes in the application's managed object context before the application terminates.
	[self saveManagedObjectContext];
}


- (void)applicationWillEnterForeground:(UIApplication*)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication*)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication*)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	
	// Saves changes in the application's managed object context before the application terminates.
	[self saveManagedObjectContext];
}


#
# pragma mark - Core Data Stack
#


#
# pragma mark Core Data Accessors
#


/*
 Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application).
 */
- (NSManagedObjectContext*)managedObjectContext {
	
	if (_managedObjectContext) return _managedObjectContext;
	
	NSPersistentStoreCoordinator* psc = self.persistentStoreCoordinator;
	if (!psc) return nil;
	
	_managedObjectContext = [[NSManagedObjectContext alloc] init]; // Init call makes this thread default owner
	_managedObjectContext.persistentStoreCoordinator = psc;
	
	return _managedObjectContext;
}


/*
 The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
 */
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
	
	if (_persistentStoreCoordinator) return _persistentStoreCoordinator;
	
	// Create the coordinator and store
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	NSURL* storeURL = [[AppDelegate applicationDocumentsDirectoryURL] URLByAppendingPathComponent:CORE_DATA_STORE_SQL_FILE_NAME];
	NSError* error = nil;
	if ([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) return _persistentStoreCoordinator;
	
	// TODO: Replace this with code to handle the error appropriately.
	// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	error = [AppDelegate persistentStoreAddError:error];
	NSLog(@"Unresolved error %@, %@", error, error.userInfo);
	abort();
	
	return _persistentStoreCoordinator;
}


/*
 The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
 */
- (NSManagedObjectModel*)managedObjectModel {
	
	if (_managedObjectModel) return _managedObjectModel;
	
	NSURL* modelURL = [[NSBundle mainBundle] URLForResource:CORE_DATA_MODEL_RESOURCE_NAME withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	
	return _managedObjectModel;
}


#
# pragma mark Core Data Helpers
#


- (void)saveManagedObjectContext {
	
	NSManagedObjectContext* moc = self.managedObjectContext;
	if (!moc || !moc.hasChanges) return;
	
	NSError* error = nil;
	if ([moc save:&error]) return;
	
	// TODO: Replace this with code to handle the error appropriately.
	// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	NSLog(@"Unresolved error %@, %@", error, error.userInfo);
	abort();
}


- (void)removePersistentStore {
	
	// Reset dependent Core Data stack, to avoid inconsistencies upon potential errors
	[self.managedObjectContext reset];
	[self saveManagedObjectContext];
	self.managedObjectContext = nil;
	NSPersistentStoreCoordinator* persistentStoreCoordinator = self.persistentStoreCoordinator;
	self.persistentStoreCoordinator = nil;
	
	// Delete persistent store
	// NOTE: Should be exactly 1
	NSPersistentStore* persistentStore = persistentStoreCoordinator.persistentStores.firstObject;
	NSError* error = nil;
	if (![persistentStoreCoordinator removePersistentStore:persistentStore error:&error]) {
		
		// TODO: Replace this with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		error = [AppDelegate persistentStoreRemoveError:error];
		NSLog(@"Unresolved error %@, %@", error, error.userInfo);
		abort();
	}
	
	if (![[NSFileManager defaultManager] removeItemAtURL:persistentStore.URL error:&error]) {
	
		// TODO: Replace this with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		error = [AppDelegate persistentStoreRemoveError:error];
		NSLog(@"Unresolved error %@, %@", error, error.userInfo);
		abort();
	}
}


+ (NSError*)persistentStoreAddError:(NSError*)error {
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:3];
	
	dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
	dict[NSLocalizedFailureReasonErrorKey] = @"There was an error creating or loading the application's saved data.";
	dict[NSUnderlyingErrorKey] = error;
	
	error = [NSError errorWithDomain:ORN_ERROR_DOMAIN_ORNOPSAPP code:ORN_ERROR_CODE_DATA_MODEL_PERSISTENT_STORE_ADD userInfo:dict];
	
	return error;
}


+ (NSError*)persistentStoreRemoveError:(NSError*)error {
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:3];
	
	dict[NSLocalizedDescriptionKey] = @"Failed to remove the application's saved data";
	dict[NSLocalizedFailureReasonErrorKey] = @"There was an error removing or deleting the application's saved data.";
	dict[NSUnderlyingErrorKey] = error;
	
	error = [NSError errorWithDomain:ORN_ERROR_DOMAIN_ORNOPSAPP code:ORN_ERROR_CODE_DATA_MODEL_PERSISTENT_STORE_REMOVE userInfo:dict];
	
	return error;
}


#
# pragma mark - Helpers
#


+ (NSURL*)applicationDocumentsDirectoryURL {
	
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
