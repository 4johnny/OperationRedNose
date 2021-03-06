//
//  AppDelegate.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-22.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

// NOTE: Uses Telegram Bot: https://core.telegram.org/bots/api

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "AppDelegate.h"
#import "MainTabBarController.h"

#import "Ride+RideHelpers.h"
#import "Team+TeamHelpers.h"


#
# pragma mark - Constants
#

#define CORE_DATA_STORE_SQL_FILE_NAME	@"ORN-Ops.sqlite"
#define CORE_DATA_MODEL_RESOURCE_NAME	@"ORN-Ops"

#define LONG_POLL_TIMEOUT	120 // seconds

#
# pragma mark Action Constants
#

// NOTE: Must be all lower case

#define ACTION_INVOKE_KEY			@"action"
#define ACTION_INVOKE_CREATE_VAL	@"create"

#define ACTION_ENTITY_KEY			@"entity"
#define ACTION_ATTRIBUTES_KEY		@"attributes"

#define ACTION_ATTRIBUTES_KEY		@"attributes"

#
# pragma mark Telegram Constants
#

//#define URL_TELEGRAM_GET_ME_FORMAT			@"https://api.telegram.org/bot%@/getMe"
#define URL_TELEGRAM_GET_UPDATES_FORMAT		@"https://api.telegram.org/bot%@/getUpdates"
#define URL_TELEGRAM_SEND_MESSAGE_FORMAT	@"https://api.telegram.org/bot%@/sendMessage"

#define TELEGRAM_SEND_MESSAGE_TIMEOUT	30 // seconds

#define TELEGRAM_COMMAND_NAME_CANCEL			@"/cancel"
#define TELEGRAM_COMMAND_NAME_NEW_RIDE_FORM		@"/new_ride_form"
//#define TELEGRAM_COMMAND_NAME_NEW_RIDE			@"/new_ride"


#
# pragma mark - Interface
#


@interface AppDelegate ()

#
# pragma mark Properties
#

@property (nonatomic) CLGeocoder* geocoder1;
@property (nonatomic) CLGeocoder* geocoder2;

@property (strong, nonatomic) NSURLSessionDataTask* telegramDataTask;

// Not persisted
@property (strong, nonatomic) NSMutableDictionary<NSNumber*,NSDictionary<NSString*,id>*>* telegramBotRideStateByUserID;

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


#
# pragma mark Initializers
#


+ (AppDelegate*)sharedAppDelegate {
	
	return (AppDelegate*)[UIApplication sharedApplication].delegate;
}


#
# pragma mark Property Accessors
#


- (CLGeocoder*)geocoder1 {
	
	if (_geocoder1) return _geocoder1;
	
	_geocoder1 = [[CLGeocoder alloc] init];
	
	return _geocoder1;
}


- (CLGeocoder*)geocoder2 {
	
	if (_geocoder2) return _geocoder2;
	
	_geocoder2 = [[CLGeocoder alloc] init];
	
	return _geocoder2;
}


// TODO: Persist Telegram auth token to keychain instead of user defaults
- (NSString*)telegramBotAuthToken {
	
	return [[NSUserDefaults standardUserDefaults] valueForKey:@"telegramBotAuthToken"];
}


- (void)setTelegramBotAuthToken:(NSString*)telegramBotAuthToken {
	
	NSLog(@"Saving Telegram bot auth token to user defaults: %@", telegramBotAuthToken);
	
	[[NSUserDefaults standardUserDefaults] setValue:telegramBotAuthToken forKey:@"telegramBotAuthToken"];
}


- (NSNumber*)telegramBotOffset {

	return [[NSUserDefaults standardUserDefaults] valueForKey:@"telegramBotOffset"];
}


- (void)setTelegramBotOffset:(NSNumber*)telegramBotOffset {
	
	NSLog(@"Saving Telegram bot offset to user defaults: %@", telegramBotOffset);
	
	[[NSUserDefaults standardUserDefaults] setValue:telegramBotOffset forKey:@"telegramBotOffset"];
}


- (NSMutableDictionary<NSNumber*,NSDictionary<NSString*,id>*>*)telegramBotRideStateByUserID {
	
	if (_telegramBotRideStateByUserID) return _telegramBotRideStateByUserID;
	
	_telegramBotRideStateByUserID = [NSMutableDictionary dictionary];
	
	return _telegramBotRideStateByUserID;
}


#
# pragma mark <UIApplicationDelegate>
#


- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
	// Override point for customization after application launch.

	[Fabric with:@[[Crashlytics class]]];
	
	if (self.telegramBotAuthToken.length > 0) {
		
		[self launchPollTelegramURLDataTask];
	}
	
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
# pragma mark Core Data Stack
#


#
# pragma mark Core Data Accessors
#


- (NSManagedObjectContext*)managedObjectContext {
	
	if (_managedObjectContext) return _managedObjectContext;
	
	NSPersistentStoreCoordinator* psc = self.persistentStoreCoordinator;
	if (!psc) return nil;
	
	_managedObjectContext = [[NSManagedObjectContext alloc] init];
	_managedObjectContext.persistentStoreCoordinator = psc;
	
	return _managedObjectContext;
}


- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
	
	if (_persistentStoreCoordinator) return _persistentStoreCoordinator;
	
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	NSURL* storeURL = [[AppDelegate applicationDocumentsDirectoryURL] URLByAppendingPathComponent:CORE_DATA_STORE_SQL_FILE_NAME];
	
	NSError* error = nil;
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
		
		error = [AppDelegate persistentStoreAddError:error];
		NSLog(@"Unresolved error: %@, %@", error, error.userInfo);
	}
	
	return _persistentStoreCoordinator;
}


- (NSManagedObjectModel*)managedObjectModel {
	
	if (_managedObjectModel) return _managedObjectModel;
	
	NSURL* modelURL = [[NSBundle mainBundle] URLForResource:CORE_DATA_MODEL_RESOURCE_NAME withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	
	if (!_managedObjectModel) {
		
		NSLog(@"Unresolved error: Managed Object Model not found");
	}
	
	return _managedObjectModel;
}


#
# pragma mark Core Data Helpers
#


- (void)saveManagedObjectContext {
	
	NSManagedObjectContext* moc = self.managedObjectContext;
	if (!moc || !moc.hasChanges) return;
	
	NSError* error = nil;
	if (![moc save:&error]) {
	
		NSLog(@"Unresolved error: %@, %@", error, error.userInfo);
	}
}


- (void)deleteAllObjectsWithEntityName:(NSString*)entityName {
	
	NSManagedObjectContext* moc = self.managedObjectContext;
	
	NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
	[fetchRequest setIncludesPropertyValues:NO]; // Only fetch managedObjectID
	
	NSError* error;
	NSArray<NSManagedObject*>* fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
	for (NSManagedObject* object in fetchedObjects) {
		
		[moc deleteObject:object];
	}
	
	[self saveManagedObjectContext];
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
		
		error = [AppDelegate persistentStoreRemoveError:error];
		NSLog(@"Unresolved error: %@, %@", error, error.userInfo);
	}
	
	if (![[NSFileManager defaultManager] removeItemAtURL:persistentStore.URL error:&error]) {
	
		error = [AppDelegate persistentStoreRemoveError:error];
		NSLog(@"Unresolved error: %@, %@", error, error.userInfo);
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
# pragma mark Telegram Methods
#


- (BOOL)handleTelegramCommandMessage:(NSDictionary<NSString*,id>*)message {
	
	// Validate command message structure
	
	NSString* commandText = message[@"text"];
	NSAssert([commandText isKindOfClass:[NSString class]], @"Message must be string");
	if (![commandText isKindOfClass:[NSString class]]) return NO;
	
	NSDictionary<NSString*,id>* chat = message[@"chat"];
	NSAssert([chat isKindOfClass:[NSDictionary class]], @"Chat must be dictionary");
	NSAssert(chat.count > 0, @"Chat dictionary must exist");
	if (![chat isKindOfClass:[NSDictionary class]] ||
		chat.count <= 0) return NO;
	
	NSString* chatUserName = chat[@"username"];
	NSAssert([chatUserName isKindOfClass:[NSString class]], @"Chat user name must be string");
	if (![chatUserName isKindOfClass:[NSString class]]) return NO;
	
	NSNumber* chatUserID = chat[@"id"];
	NSAssert([chatUserID isKindOfClass:[NSNumber class]], @"Chat user ID must be integer");
	if (![chatUserID isKindOfClass:[NSNumber class]]) return NO;
	
	// Handle command, if possible
	
	commandText = commandText.lowercaseString;
	if (commandText.length <= 0) return NO;
	
	if ([TELEGRAM_COMMAND_NAME_CANCEL isEqualToString:commandText]) {

		//	NSLog(@"Cancelling ride-create workflow for user: %@ (%@)", chatUserName, chatUserID);
		//	[self.telegramBotRideStateByUserID removeObjectForKey:chatUserID];
		//	NSLog(@"Ride state: %@", self.telegramBotRideStateByUserID);
		
		return YES;
	}
	
	if ([TELEGRAM_COMMAND_NAME_NEW_RIDE_FORM isEqualToString:commandText]) {
		
		NSLog(@"Providing ride-create form to user: %@ (%@)", chatUserName, chatUserID);

		[self sendTelegramRideCreateFormWithChatUserID:chatUserID andMessage:message];
		
		return YES;
	}
	
	//	if ([TELEGRAM_COMMAND_NAME_NEW_RIDE isEqualToString:commandText]) {
	//
	//		NSLog(@"Starting ride-create workflow for user: %@ (%@)", chatUserName, chatUserID);
	//
	//		self.telegramBotRideStateByUserID[chatUserID] =
	//		@{
	//		  @"createdDateTime" :	[NSDate date],
	//		  @"ride" :				[Ride rideWithManagedObjectModel:self.managedObjectModel],
	//		  };
	//		NSLog(@"Ride state: %@", self.telegramBotRideStateByUserID);
	//
	//		return YES;
	//	}
	
	return NO;
}

										  
//- (BOOL)handleTelegramWorkflowMessage:(NSDictionary<NSString*,id>*)message {
//	
//	return NO;
//}


- (BOOL)handleTelegramAction:(NSDictionary<NSString*,id>*)action {
	
	NSAssert(action.count > 0, @"Action must exist");
	if (action.count <= 0) return NO;
	
	NSString* actionName = action[ACTION_INVOKE_KEY];
	NSString* entityName = action[ACTION_ENTITY_KEY];
	NSDictionary<NSString*,id>* attributes = action[ACTION_ATTRIBUTES_KEY];
	NSAssert(actionName.length > 0, @"Action name must exist");
	NSAssert(entityName.length > 0, @"Entity name must exist");
	NSAssert(attributes.count > 0, @"Attributes must exist");
	if (actionName.length <= 0 ||
		entityName.length <= 0 ||
		attributes.count <= 0) return NO;
	
	actionName = actionName.lowercaseString;
	entityName = entityName.lowercaseString;
	
	if ([RIDE_ENTITY_NAME.lowercaseString isEqualToString:entityName]) {
		
		if ([ACTION_INVOKE_CREATE_VAL isEqualToString:actionName]) {
			
			NSLog(@"Trying to create new ride");
			
			Ride* newRide = [Ride rideWithAttributes:attributes andManagedObjectContext:self.managedObjectContext andGeocoder1:self.geocoder1 andGeocoder2:self.geocoder2 andSender:self];
			if (newRide) {
				
				[self saveManagedObjectContext];
				[newRide postNotificationCreatedWithSender:self];
				
				NSLog(@"Created new ride");
				return YES;
			}
			
			NSLog(@"Cannot create new ride");
			
		} // else if (ACTION_INVOKE_ isEqualToString:actionName]) { ... }
		
	} // else if ([TEAM_ENTITY_NAME.lowercaseString isEqualToString:entityName]) { ... }
	
	return NO;
}


- (BOOL)handleTelegramFormMessage:(NSDictionary<NSString*,id>*)message {

	NSString* messageText = message[@"text"];
	NSDictionary<NSString*,id>* attributes = [self attributesFromMessageText:messageText];
	if (attributes.count <= 0) return NO;
	
	NSDictionary<NSString*,id>* action =
	@{
	  ACTION_INVOKE_KEY :		ACTION_INVOKE_CREATE_VAL,
	  ACTION_ENTITY_KEY :		RIDE_ENTITY_NAME,
	  ACTION_ATTRIBUTES_KEY :	attributes,
	  };
	
	return [self handleTelegramAction:action];
}


- (BOOL)handleTelegramActionMessage:(NSDictionary<NSString*,id>*)message {
	
	NSString* messageText = message[@"text"];
	NSDictionary<NSString*,id>* action = [Util dictionaryFromString:messageText];
	if (action.count <= 0) return NO;
	
	return [self handleTelegramAction:action];
}


- (BOOL)handleTelegramMessage:(NSDictionary<NSString*,id>*)message {
	
	NSString* messageText = message[@"text"];
	if (messageText.length <= 0) return NO;
	
	NSRange commandCharRange = [messageText rangeOfString:@"/"];
	if (commandCharRange.location == 0) {
	
		NSLog(@"Trying to handle message as command");
		if ([self handleTelegramCommandMessage:message]) return YES;
		NSLog(@"Cannot handle command message");
		
		return NO;
	}
	
	//	NSLog(@"Trying to handle message as workflow");
	//	if ([self handleTelegramWorkflowMessage:message]) return YES;
	//	NSLog(@"Cannot handle workflow message");
	
	NSLog(@"Trying to handle message as form");
	if ([self handleTelegramFormMessage:message]) return YES;
	NSLog(@"Cannot handle form message");
	
	NSLog(@"Trying to handle message as action");
	if ([self handleTelegramActionMessage:message]) return YES;
	NSLog(@"Cannot handle action message");
	
	return NO;
}


- (void)sendTelegramRideCreateFormWithChatUserID:(NSNumber*)chatUserID
									  andMessage:(NSDictionary<NSString*,id>*)message {
	
	NSAssert(chatUserID.integerValue > 0, @"Chat user ID must exist");
	NSAssert(message.count > 0 , @"Message must exist");
	if (chatUserID.integerValue <= 0 ||
		message.count <= 0) return;
	
	NSString* messageText =
	
	RIDE_ATTRIBUTE_NAME_DATE_TIME_START @": \n"
	RIDE_ATTRIBUTE_NAME_SOURCE_NAME @": \n"
	
	RIDE_ATTRIBUTE_NAME_PASSENGER_NAME_FIRST @": \n"
	RIDE_ATTRIBUTE_NAME_PASSENGER_NAME_LAST @": \n"
	RIDE_ATTRIBUTE_NAME_PASSENGER_PHONE_NUMBER @": \n"
	RIDE_ATTRIBUTE_NAME_PASSENGER_COUNT @": \n"
	
	RIDE_ATTRIBUTE_NAME_LOCATION_START_ADDRESS @": \n"
	RIDE_ATTRIBUTE_NAME_LOCATION_END_ADDRESS @": \n"
	RIDE_ATTRIBUTE_NAME_LOCATION_TRANSFER_FROM @": \n"
	RIDE_ATTRIBUTE_NAME_LOCATION_TRANSFER_TO @": \n"
	
	RIDE_ATTRIBUTE_NAME_VEHICLE_DESCRIPTION @": \n"
	RIDE_ATTRIBUTE_NAME_VEHICLE_TRANSMISSION @" (" RIDE_ATTRIBUTE_VALUE_VEHICLE_TRANSMISSION_AUTOMATIC @" / " RIDE_ATTRIBUTE_VALUE_VEHICLE_TRANSMISSION_MANUAL @")" @": \n"
	RIDE_ATTRIBUTE_NAME_VEHICLE_SEAT_BELT_COUNT @": \n"
	
	RIDE_ATTRIBUTE_NAME_NOTES @": \n"
	;
	
	
	NSURLRequest* urlRequest = [AppDelegate urlRequestForTelegramBotSendMessageWithChatUserID:chatUserID andMessageText:messageText];
	NSAssert(urlRequest, @"URL request for Telegram bot update must exist");
	if (!urlRequest) return;
	
	NSURLSessionDataTask* dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData* _Nullable data, NSURLResponse* _Nullable response, NSError* _Nullable error) {
		
		//	NSLog(@"URL response for Telegram bot update running on thread: %@", [NSThread currentThread]);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			//	NSLog(@"Processing response for Telegram bot update on thread: %@", [NSThread currentThread]);
			
			if (!data) {
				NSLog(@"URL Client Connection Error - %@ %@", error.localizedDescription, error.userInfo[NSURLErrorFailingURLStringErrorKey]);
				return;
			}
			
			NSHTTPURLResponse* httpUrlResponse = (NSHTTPURLResponse*)response;
			if (httpUrlResponse.statusCode != HTTP_RESPONSE_STATUS_OK) {
				
				NSLog(@"URL Server Connection Error - %d %@", (int)httpUrlResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpUrlResponse.statusCode]);
				return;
			}
			
			// We have data - convert it to JSON dictionary
			NSError* error = nil;
			NSDictionary* responseJSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
			if (!responseJSONDictionary) {
				NSLog(@"JSON Deserialization Error - %@ %@", error.localizedDescription, error.userInfo);
				return;
			}
			NSLog(@"URL-response JSON for Telegram bot update: %@", responseJSONDictionary);
			
		});
	}];
	[dataTask resume];
}


+ (NSMutableURLRequest*)urlRequestForTelegramBotUpdateWithOffset:(NSNumber*)offset
													andAuthToken:(NSString*)authToken {

	// NOTE: Offset maybe nil
	NSAssert(authToken.length > 0, @"Telegram bot auth token must exist");
	if (authToken.length <= 0) return nil;
	
	NSString* urlString = [NSString stringWithFormat:URL_TELEGRAM_GET_UPDATES_FORMAT, authToken];
	NSURL* url = [NSURL URLWithString:urlString];
	//	NSLog(@"URL for Telegram bot update: %@", telegramBotUpdateURL);

	NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
	urlRequest.HTTPMethod = @"POST";
	urlRequest.timeoutInterval = LONG_POLL_TIMEOUT; // seconds
	[urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	NSMutableDictionary<NSString*,id>* httpBodyJSONDictionary =
	[@{
	   @"timeout" :	@(LONG_POLL_TIMEOUT),
	   } mutableCopy];
	
	if (offset) {
		httpBodyJSONDictionary[@"offset"] = offset;
	}
	NSLog(@"URL-request JSON for Telegram bot update: %@", httpBodyJSONDictionary);
	
	NSError* error = nil;
	urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:httpBodyJSONDictionary options:kNilOptions error:&error];
	if (error) {
		NSLog(@"JSON Serialization Error - %@ %@", error.localizedDescription, error.userInfo);
		return nil;
	}
	
	NSLog(@"URL request for Telegram bot update: %@", urlRequest);
	
	return urlRequest;
}


+ (NSMutableURLRequest*)urlRequestForTelegramBotSendMessageWithChatUserID:(NSNumber*)chatUserID
														   andMessageText:(NSString*)messageText {
	
	AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
	
	NSAssert(chatUserID.integerValue > 0, @"Chat user ID must exist");
	if (chatUserID.integerValue <= 0) return nil;
	
	NSString* telegramBotAuthToken = appDelegate.telegramBotAuthToken;
	NSAssert(telegramBotAuthToken.length > 0, @"Telegram bot auth token must exist");
	if (telegramBotAuthToken.length <= 0) return nil;
	
	NSString* urlString = [NSString stringWithFormat:URL_TELEGRAM_SEND_MESSAGE_FORMAT, telegramBotAuthToken];
	NSURL* url = [NSURL URLWithString:urlString];
	//	NSLog(@"URL for Telegram bot message: %@", url);
	
	NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
	urlRequest.HTTPMethod = @"POST";
	urlRequest.timeoutInterval = TELEGRAM_SEND_MESSAGE_TIMEOUT; // seconds
	[urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	NSDictionary<NSString*,id>* httpBodyJSONDictionary =
	@{
	  @"chat_id" :	chatUserID,
	  @"text" :		messageText ?: @"",
	  };
	NSLog(@"URL-request JSON for Telegram bot message: %@", httpBodyJSONDictionary);
	
	NSError* error = nil;
	urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:httpBodyJSONDictionary options:kNilOptions error:&error];
	if (error) {
		NSLog(@"JSON Serialization Error - %@ %@", error.localizedDescription, error.userInfo);
		return nil;
	}
	
	NSLog(@"URL request for Telegram bot message: %@", urlRequest);
	
	return urlRequest;
}


- (void)launchPollTelegramURLDataTask {
	
	if (self.telegramBotAuthToken.length <= 0) return;
	
	NSURLRequest* urlRequest = [AppDelegate urlRequestForTelegramBotUpdateWithOffset:self.telegramBotOffset andAuthToken:self.telegramBotAuthToken];
	NSAssert(urlRequest, @"URL request for Telegram bot update must exist");
	if (!urlRequest) return;
	
	self.telegramDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData* _Nullable data, NSURLResponse* _Nullable response, NSError* _Nullable error) {
		
		//	NSLog(@"URL response for Telegram bot update running on thread: %@", [NSThread currentThread]);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			@try {
				
				//	NSLog(@"Processing response for Telegram bot update on thread: %@", [NSThread currentThread]);
				
				if (!data) {
					NSLog(@"URL Client Connection Error - %@ %@", error.localizedDescription, error.userInfo[NSURLErrorFailingURLStringErrorKey]);
					return;
				}
				
				NSHTTPURLResponse* httpUrlResponse = (NSHTTPURLResponse*)response;
				if (httpUrlResponse.statusCode != HTTP_RESPONSE_STATUS_OK) {
					
					NSLog(@"URL Server Connection Error - %d %@", (int)httpUrlResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpUrlResponse.statusCode]);
					return;
				}
				
				// We have data - convert it to JSON dictionary
				NSError* error = nil;
				NSDictionary* responseJSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
				if (!responseJSONDictionary) {
					NSLog(@"JSON Deserialization Error - %@ %@", error.localizedDescription, error.userInfo);
					return;
				}
				NSLog(@"URL-response JSON for Telegram bot update: %@", responseJSONDictionary);
				
				// We have JSON dictionary - grab Telegram update
				
				BOOL telegramResponseOK = ((NSNumber*)responseJSONDictionary[@"ok"]).boolValue;
				if (!telegramResponseOK) {
					NSLog(@"Telegram response failed");
					return;
				}
				
				// Grab messages
				NSArray<NSDictionary<NSString*,id>*>* messageResults = responseJSONDictionary[@"result"];
				if (messageResults.count <= 0) {
					NSLog(@"No Telegram bot messages");
					return;
				}
				NSNumber* lastMessageUpdateID = nil;
				for (NSDictionary<NSString*,id>* messageResult in messageResults) {
					
					lastMessageUpdateID = messageResult[@"update_id"];
					NSDictionary<NSString*,id>* message = messageResult[@"message"];
					NSLog(@"Received Telegram update ID: %@; message: %@", lastMessageUpdateID, message);
					if (lastMessageUpdateID.integerValue <= 0 ||
						message.count <= 0) {
						NSLog(@"Ignoring invalid update");
						continue;
					}

					// Yield to UI, since processing Telegram messages from external users
					NSLog(@"Dispatching handler for Telegram message");
					dispatch_async(dispatch_get_main_queue(), ^{
						
						(void)[self handleTelegramMessage:message];
					});
				}
				
				// Bump up offset for next poll
				if (lastMessageUpdateID) {
					self.telegramBotOffset = @(lastMessageUpdateID.integerValue + 1);
				}
				
			} @finally {
				
				// Launch next poll
				[self launchPollTelegramURLDataTask];
			}
		});
	}];
	
	[self.telegramDataTask resume];
}


- (void)cancelPollTelegramURLDataTask {
	
	// NOTE: Cancelling twice clears Telegram auth token
	
	if (self.telegramDataTask) {
		
		[self.telegramDataTask cancel];
		self.telegramDataTask = nil;
		
	} else {
		
		self.telegramBotAuthToken = nil;
	}
}


- (void)startTelegramBotPoll {
	
	if (self.telegramBotAuthToken.length <= 0) return;
	
	NSLog(@"Starting poll for bot");
	
	[self launchPollTelegramURLDataTask];
}


- (void)stopTelegramBotPoll {
	
	NSLog(@"Stopping poll for bot");
	
	[self cancelPollTelegramURLDataTask];
}


- (NSDictionary<NSString*,id>*)attributesFromMessageText:(NSString*)messageText {

	if (!messageText) return nil;
	if (messageText.length <= 0) return @{};
	
	NSArray<NSString*>* messageLines = [messageText componentsTrimAllNewline];
	if (messageLines.count <= 0) return @{};
	
	NSMutableDictionary<NSString*,id>* attributes = [NSMutableDictionary<NSString*,id> dictionaryWithCapacity:messageLines.count];
	
	BOOL isNotes = NO;
	NSMutableString* notes = [NSMutableString string];
	
	for (NSString* messageLine in messageLines) {
		
		NSRange attributeSeparatorRange = [messageLine rangeOfString:@":"];
		if (attributeSeparatorRange.location == NSNotFound) {
			
			if (isNotes) {
			
				[notes appendString:[messageLine stringByAppendingString:@"\n"]];
			}
			
			continue;
		}
		
		NSString* attributeName = [[messageLine substringToIndex:attributeSeparatorRange.location] trim];
		if (attributeName.length <= 0) continue;
		
		NSString* attributeValue = [[messageLine substringFromIndex:(attributeSeparatorRange.location + 1)] trim];
		
		isNotes = [RIDE_ATTRIBUTE_NAME_NOTES isEqualToString:attributeName];
		if (isNotes) {
		
			[notes appendString:[attributeValue stringByAppendingString:@"\n"]];
			
			continue;
		}
		
		if ([RIDE_ATTRIBUTE_NAME_DATE_TIME_START isEqualToString:attributeName]) {
			
			// Grab hour & minute
			NSRange timeSeparatorRange = [attributeValue rangeOfString:@":"];
			if (timeSeparatorRange.location == NSNotFound) continue;
			
			NSString* hourText = [[attributeValue substringToIndex:timeSeparatorRange.location] trim];
			if (hourText.length <= 0) continue;
			NSInteger hourDelta = hourText.integerValue;
			if (hourDelta > 6) { // Assume PM
				
				hourDelta -= 12;
			}
			
			// Determine base date
			NSString* minuteText = [[attributeValue substringFromIndex:(timeSeparatorRange.location + 1)] trim];
			if (minuteText.length <= 0) continue;
			NSInteger minute = minuteText.integerValue;
			
			// Determine midnight of base date from now
			NSDate* now = [NSDate date];
			NSDate* dateTimeStart = [now dateByFlooringToDay];
			NSCalendar* currentCalendar = [NSCalendar currentCalendar];
			NSDateComponents* dateComponents = [currentCalendar components:NSCalendarUnitHour fromDate:now];
			if (dateComponents.hour > 12) { // 24-hour clock
				
				dateTimeStart = [currentCalendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:dateTimeStart options:kNilOptions];
			}

			
			// Determine start date-time relative to base date
			dateComponents.hour = hourDelta;
			dateComponents.minute = minute;
			
			dateTimeStart = [currentCalendar dateByAddingComponents:dateComponents toDate:dateTimeStart options:kNilOptions];
			
			attributes[attributeName] = dateTimeStart;
			
			continue;
		}
		
		if ([RIDE_ATTRIBUTE_NAME_PASSENGER_COUNT isEqualToString:attributeName] ||
			[RIDE_ATTRIBUTE_NAME_VEHICLE_SEAT_BELT_COUNT isEqualToString:attributeName]) {
			
			attributes[attributeName] = @(attributeValue.integerValue);
			
			continue;
		}
			
		if ([attributeName rangeOfString:RIDE_ATTRIBUTE_NAME_VEHICLE_TRANSMISSION].location == 0) {
			
			if (attributeValue.length <= 0) {
				
				attributes[RIDE_ATTRIBUTE_NAME_VEHICLE_TRANSMISSION] = RIDE_ATTRIBUTE_VALUE_VEHICLE_TRANSMISSION_AUTOMATIC;
				
				continue;
			}
			
			attributeValue = attributeValue.lowercaseString;
			
			if ([attributeValue rangeOfString:@"m"].location == 0) {
				
				attributeValue = RIDE_ATTRIBUTE_VALUE_VEHICLE_TRANSMISSION_MANUAL;
			}
			
			attributes[RIDE_ATTRIBUTE_NAME_VEHICLE_TRANSMISSION] = attributeValue;
			
			continue;
		}
	
		attributes[attributeName] = attributeValue;
	}
	
	if (notes) {
		
		attributes[RIDE_ATTRIBUTE_NAME_NOTES] = [notes trim];
	}
	
	return attributes;
}


#
# pragma mark Helper Methods
#


+ (NSURL*)applicationDocumentsDirectoryURL {
	
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
