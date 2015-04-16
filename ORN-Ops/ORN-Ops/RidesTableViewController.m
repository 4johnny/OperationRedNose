//
//  RidesTableViewController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "RidesTableViewController.h"
#import "AppDelegate.h"
#import "Ride+RideHelpers.h"
#import "Team+TeamHelpers.h"


#
# pragma mark - Constants
#

#define RIDES_CELL_REUSE_ID			@"ridesTableViewCell"
#define RIDES_CELL_DATETIME_FORMAT	@"HH:mm"
#define RIDES_CELL_FIELD_EMPTY		@"?"

#define SHOW_RIDE_DETAIL_SEQUE	@"showRideDetailSeque"


#
# pragma mark - Interface
#

@interface RidesTableViewController ()

@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;

@property (nonatomic) NSDateFormatter* cellDateFormatter;

@end


#
# pragma mark - Implementation
#


@implementation RidesTableViewController


#
# pragma mark Properties
#


- (NSFetchedResultsController*)fetchedResultsController {
	
	if (_fetchedResultsController) return _fetchedResultsController;

	// Build fetch request
	NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:RIDE_ENTITY_NAME];
	fetchRequest.fetchBatchSize = RIDE_FETCH_BATCH_SIZE;
	fetchRequest.sortDescriptors =
	@[
	  [NSSortDescriptor sortDescriptorWithKey:RIDE_FETCH_SORT_KEY1 ascending:RIDE_FETCH_SORT_ASCENDING],
	  [NSSortDescriptor sortDescriptorWithKey:RIDE_FETCH_SORT_KEY2 ascending:RIDE_FETCH_SORT_ASCENDING]
	  ];
	// fetchRequest.predicate = [NSPredicate predicateWithFormat:@"<#format string#>", <#arguments#>];

	// Perform fetch
	// NOTE: nil for section name key path means "no sections".
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[Util managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
	_fetchedResultsController.delegate = self;
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
		// TODO: Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, error.userInfo);
		abort();
	}
	
	return _fetchedResultsController;
}


- (NSDateFormatter*)cellDateFormatter {
	
	if (_cellDateFormatter) return _cellDateFormatter;
	
	_cellDateFormatter = [[NSDateFormatter alloc] init];
	_cellDateFormatter.dateFormat = RIDES_CELL_DATETIME_FORMAT;
	
	return _cellDateFormatter;
}


#
# pragma mark UIViewController
#


- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	[self addNotificationObservers];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
	
	if ([segue.identifier isEqualToString:SHOW_RIDE_DETAIL_SEQUE]) {
		
		// Inject ride model into ride view controller
		id<RideModelSource> rideModelSource = segue.destinationViewController;
		rideModelSource.ride = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
	}
}


#
# pragma mark <UITableViewDataSource>
#


// Return the number of sections.
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	
	return 1; //self.fetchedResultsController.sections.count;
}


// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {

	return self.fetchedResultsController.fetchedObjects.count;
//    return ((id<NSFetchedResultsSectionInfo>)self.fetchedResultsController.sections[section]).numberOfObjects;
}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:RIDES_CELL_REUSE_ID forIndexPath:indexPath];
    
    // Configure the cell
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/
/*
// Override to support editing the table view.
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
 
    if (editingStyle == UITableViewCellEditingStyleDelete) {
 
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView*)tableView moveRowAtIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath {
}
*/
/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#
# pragma mark <NSFetchedResultsControllerDelegate>
#


- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller {
	
	// NOTE: Do *not* call reloadData between begin and end, since it will cancel animations
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController*)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type {
	
	switch (type) {
			
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		default:
			return;
	}
}


- (void)controller:(NSFetchedResultsController*)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath*)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath*)newIndexPath {
	
	UITableView *tableView = self.tableView;
	
	switch (type) {
			
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
	
	[self.tableView endUpdates];
}


/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */


#
# pragma mark Notification Handlers
#


- (void)dataModelResetWithNotification:(NSNotification*)notification {

	self.fetchedResultsController = nil;
	
	[self.tableView reloadData];
}


- (void)rideCreatedWithNotification:(NSNotification*)notification {
	
	[self.tableView reloadData];
}


- (void)rideUpdatedWithNotification:(NSNotification*)notification {

	[self.tableView reloadData];
}


- (void)teamCreatedWithNotification:(NSNotification*)notification {
	
	[self.tableView reloadData];
}


- (void)teamUpdatedWithNotification:(NSNotification*)notification {
	
	[self.tableView reloadData];
}


#
# pragma mark Helpers
#


- (void)addNotificationObservers {

	[Util addDataModelResetObserver:self withSelector:@selector(dataModelResetWithNotification:)];
	
	[Ride addCreatedObserver:self withSelector:@selector(rideCreatedWithNotification:)];
	[Ride addUpdatedObserver:self withSelector:@selector(rideUpdatedWithNotification:)];

	[Team addCreatedObserver:self withSelector:@selector(teamCreatedWithNotification:)];
	[Team addUpdatedObserver:self withSelector:@selector(teamUpdatedWithNotification:)];
}


- (void)insertNewObject:(id)sender {
	
	NSManagedObjectContext *context = self.fetchedResultsController.managedObjectContext;
	NSEntityDescription *entity = self.fetchedResultsController.fetchRequest.entity;
	
	Ride* newRide = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:context];
	newRide.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	NSLog(@"Created new Ride entity: %@", newRide);
	
	// Save the context
	NSError *error = nil;
	if (![context save:&error]) {
		
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, error.userInfo);
		abort();
	}
}


- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
	
	Ride* ride = [self.fetchedResultsController objectAtIndexPath:indexPath];

	// Text
	
	NSString* rideTitle = [ride getTitle];
	NSString* teamAssignedTitle = ride.teamAssigned ? [ride.teamAssigned getTitle] : RIDES_CELL_FIELD_EMPTY;
	NSString* sourceTitle = ride.sourceName.length > 0 ? ride.sourceName : RIDES_CELL_FIELD_EMPTY;
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d) | Team: %@ | Source: %@", rideTitle, (int)ride.passengerCount.longValue, teamAssignedTitle, sourceTitle];
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	
	// Detail Text
	
	NSString* startDateString = ride.dateTimeStart ? [self.cellDateFormatter stringFromDate:ride.dateTimeStart]: RIDES_CELL_FIELD_EMPTY;
	NSString* startAddress = ride.locationStartAddress.length > 0 ? ride.locationStartAddress : RIDES_CELL_FIELD_EMPTY;
	NSString* startDetail = [NSString stringWithFormat:@"Start: %@ -> %@", startDateString, startAddress];
	
	NSDate* routeDateTimeEnd = [ride getRouteDateTimeEnd];
	NSString* endDateString = routeDateTimeEnd ? [self.cellDateFormatter stringFromDate:routeDateTimeEnd]: RIDES_CELL_FIELD_EMPTY;
	NSString* endAddress = ride.locationEndAddress.length > 0 ? ride.locationEndAddress : RIDES_CELL_FIELD_EMPTY;
	NSString* endDetail = [NSString stringWithFormat:@"End: %@ -> %@", endDateString, endAddress];
	
	NSString* durationString = ride.routeMainDuration ? [NSString stringWithFormat:@"%.0f", ride.routeMainDuration.doubleValue / (NSTimeInterval)SECONDS_PER_MINUTE] : RIDES_CELL_FIELD_EMPTY;
	NSString* distanceString = ride.routeMainDistance ? [NSString stringWithFormat:@"%.1f", ride.routeMainDistance.doubleValue / (CLLocationDistance)METERS_PER_KILOMETER] : RIDES_CELL_FIELD_EMPTY;
	NSString* routeDetail = [NSString stringWithFormat:@"%@ min | %@ km", durationString, distanceString];
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@", startDetail, endDetail, routeDetail];
	cell.detailTextLabel.numberOfLines = 0;
	cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
}


@end
