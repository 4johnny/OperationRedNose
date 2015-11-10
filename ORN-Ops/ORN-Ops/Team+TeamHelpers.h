//
//  Team+TeamHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-03.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "Team.h"

#
# pragma mark - Constants
#

#define TEAM_ENTITY_NAME	@"Team"
#define TEAM_TITLE_DEFAULT	@"(Team)"
#define TEAM_TITLE_NONE		@"-None-"

// NOTE: Sort keys indexed in data model
#define TEAM_FETCH_SORT_KEY1		@"name"
#define TEAM_FETCH_SORT_ASC1		YES
#define TEAM_FETCH_SORT_KEY2		@"members"
#define TEAM_FETCH_SORT_ASC2		YES
#define TEAM_FETCH_BATCH_SIZE		20

#
# pragma mark - Protocol
#

@protocol TeamModelSource <NSObject>

#
# pragma mark Properties
#

@required

@property (weak, nonatomic) Team* team;

@end

#
# pragma mark - Interface
#

@interface Team (TeamHelpers) <ORNDataObject>

#
# pragma mark Initializers
#

+ (instancetype)teamWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

#
# pragma mark Notifications
#

+ (void)addCreatedObserver:(id)observer withSelector:(SEL)selector;
+ (void)addDeletedObserver:(id)observer withSelector:(SEL)selector;
+ (void)addUpdatedObserver:(id)observer withSelector:(SEL)selector;

+ (Team*)teamFromNotification:(NSNotification*)notification;
+ (BOOL)isUpdatedLocationFromNotification:(NSNotification*)notification;
+ (BOOL)isUpdatedMascotFromNotification:(NSNotification*)notification;
+ (BOOL)isUpdatedRidesAssignedFromNotification:(NSNotification*)notification;

- (void)postNotificationCreatedWithSender:(id)sender;
- (void)postNotificationDeletedWithSender:(id)sender;

- (void)postNotificationUpdatedWithSender:(id)sender;

- (void)postNotificationUpdatedWithSender:(id)sender
					   andUpdatedLocation:(BOOL)updatedLocation;

- (void)postNotificationUpdatedWithSender:(id)sender
					   andUpdatedLocation:(BOOL)updatedLocation
						 andUpdatedMascot:(BOOL)updatedMascot;

- (void)postNotificationUpdatedWithSender:(id)sender
				  andUpdatedRidesAssigned:(BOOL)updatedRidesAssigned;

- (void)postNotificationUpdatedWithSender:(id)sender
					   andUpdatedLocation:(BOOL)updatedLocation
				  andUpdatedRidesAssigned:(BOOL)updatedRidesAssigned;

#
# pragma mark Instance Helpers
#

- (void)delete;

- (void)updateCurrentLocationWithLatitude:(CLLocationDegrees)latitude
							 andLongitude:(CLLocationDegrees)longitude
								andStreet:(NSString*)street
								  andCity:(NSString*)city
								 andState:(NSString*)state
							   andAddress:(NSString*)address
								  andTime:(NSDate*)time;

- (void)clearCurrentLocation;

- (void)persistCurrentLocationWithSender:(id)sender;
	
- (void)tryUpdateCurrentLocationWithAddressString:(NSString*)addressString
									  andGeocoder:(CLGeocoder*)geocoder
										andSender:(id)sender;
- (void)tryUpdateActiveAssignedRideRoutesWithSender:(id)sender;

- (NSString*)getTitle;
- (NSString*)getStatusText;

- (NSSet<Ride*>*)getActiveRidesAssigned;
- (NSArray<Ride*>*)getSortedActiveRidesAssigned;

- (CLLocationCoordinate2D)getLocationCurrentCoordinate;
- (MKMapItem*)mapItemForCurrentLocation;

- (NSTimeInterval)getActiveDurationAssigned;
- (CLLocationDistance)getActiveDistanceAssigned;

- (NSDecimalNumber*)getDonationsAssigned;

@end
