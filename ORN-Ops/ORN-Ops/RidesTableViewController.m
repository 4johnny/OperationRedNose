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


#define RIDE_FETCH_BATCH_SIZE	20
#define RIDE_SORT_KEY			@"dateTimeStart"
#define RIDE_SORT_ASCENDING		YES

#define TIME_FORMAT				@"HH:mm"

#define RIDES_CELL_REUSE_ID		@"ridesTableViewCell"
#define SHOW_RIDE_DETAIL_SEQUE	@"showRideDetailSeque"


#
# pragma mark - Interface
#

@interface RidesTableViewController ()

@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;

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
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:RIDE_ENTITY_NAME];
	fetchRequest.fetchBatchSize = RIDE_FETCH_BATCH_SIZE;
	fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:RIDE_SORT_KEY ascending:RIDE_SORT_ASCENDING]];
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


#
# pragma mark UIViewController
#


- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// Wire up observers for update notifications for rides and teams
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideUpdatedWithNotification:) name:RIDE_UPDATED_NOTIFICATION_NAME object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teamUpdatedWithNotification:) name:TEAM_UPDATED_NOTIFICATION_NAME object:nil];
	
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
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		RideDetailTableViewController* rideDetailTableViewController = segue.destinationViewController;
		rideDetailTableViewController.ride = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/
/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/
/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#
# pragma mark <NSFetchedResultsControllerDelegate>
#


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	
	// NOTE: Do *not* call reloadData between begin and end, since it will cancel animations
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
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


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
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


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	
	[self.tableView endUpdates];
}


/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */


#
# pragma mark Notification Handlers
#


- (void)rideUpdatedWithNotification:(NSNotification*)notification {

	[self.tableView reloadData];
}


- (void)teamUpdatedWithNotification:(NSNotification*)notification {
	
	[self.tableView reloadData];
}


#
# pragma mark Helpers
#


- (void)insertNewObject:(id)sender {
	
	NSManagedObjectContext *context = self.fetchedResultsController.managedObjectContext;
	NSEntityDescription *entity = self.fetchedResultsController.fetchRequest.entity;
	
	Ride* newRide = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:context];
	newRide.dateTimeStart = [NSDate date];
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


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	Ride* ride = [self.fetchedResultsController objectAtIndexPath:indexPath];

	NSDateFormatter* startTimeDateFormatter = [[NSDateFormatter alloc] init];
	startTimeDateFormatter.dateFormat = TIME_FORMAT;

	cell.textLabel.text = ride.locationStartAddress;
	cell.detailTextLabel.text = [startTimeDateFormatter stringFromDate:ride.dateTimeStart];
}


@end
