//
//  TeamsTableViewController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "TeamsTableViewController.h"
#import "TeamDetailTableViewController.h"
#import "Team+TeamHelpers.h"
#import "Ride+RideHelpers.h"


#
# pragma mark - Constants
#

#define TEAMS_CELL_REUSE_ID			@"teamsTableViewCell"
#define TEAMS_CELL_DATETIME_FORMAT	@"HH:mm"
#define TEAMS_CELL_FIELD_EMPTY		@"?"

#define SHOW_TEAM_DETAIL_SEQUE	@"showTeamDetailSegue"
//#define SHOW_TEAM_ADD_SEQUE	@"showTeamAddSegue"


#
# pragma mark - Interface
#

@interface TeamsTableViewController ()

@property (strong, nonatomic) NSFetchedResultsController* teamsFetchedResultsController;

@property (nonatomic) NSDateFormatter* cellDateFormatter;

@end


#
# pragma mark - Implementation
#


@implementation TeamsTableViewController


#
# pragma mark Properties
#


- (NSFetchedResultsController*)teamsFetchedResultsController {
	
	if (_teamsFetchedResultsController) return _teamsFetchedResultsController;
	
	NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:TEAM_ENTITY_NAME];
	fetchRequest.fetchBatchSize = TEAM_FETCH_BATCH_SIZE;
	fetchRequest.sortDescriptors =
	@[
	  [NSSortDescriptor sortDescriptorWithKey:TEAM_FETCH_SORT_KEY1 ascending:TEAM_FETCH_SORT_ASC1],
	  [NSSortDescriptor sortDescriptorWithKey:TEAM_FETCH_SORT_KEY2 ascending:TEAM_FETCH_SORT_ASC2],
	  ];
	
	_teamsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[Util managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
	_teamsFetchedResultsController.delegate = self;
	
	NSError* error = nil;
	if (![_teamsFetchedResultsController performFetch:&error]) {
		
		NSLog(@"Unresolved error: %@, %@", error, error.userInfo);
	}
	
	return _teamsFetchedResultsController;
}


- (NSDateFormatter*)cellDateFormatter {
	
	if (_cellDateFormatter) return _cellDateFormatter;
	
	_cellDateFormatter = [[NSDateFormatter alloc] init];
	_cellDateFormatter.dateFormat = TEAMS_CELL_DATETIME_FORMAT;
	
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

	// Hide empty table cells
	self.tableView.tableFooterView = [UIView new];
	
	[self addNotificationObservers];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
	NSLog(@"Warning: Memory Low");
}


- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
	
	if ([segue.identifier isEqualToString:SHOW_TEAM_DETAIL_SEQUE]) {
		
		// Inject team model into team view controller
		TeamDetailTableViewController* teamDetailTableViewController = (TeamDetailTableViewController*)segue.destinationViewController;
		teamDetailTableViewController.team = [self.teamsFetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
		
		// Remove "cancel" button
		teamDetailTableViewController.navigationItem.leftBarButtonItem = nil;
	}
	
	//	if ([segue.identifier isEqualToString:SHOW_TEAM_ADD_SEQUE]) {
	//		// NOTE: Empty "team" field means "Add Mode"
	//
	//		// Do nothing
	//	}
}


#
# pragma mark <UITableViewDataSource>
#


- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	
	return 1; //self.teamsFetchedResultsController.sections.count;
}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	
	return self.teamsFetchedResultsController.fetchedObjects.count;
	//	return ((id<NSFetchedResultsSectionInfo>)self.teamsFetchedResultsController.sections[section]).numberOfObjects;
}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(nonnull NSIndexPath*)indexPath {
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:TEAMS_CELL_REUSE_ID forIndexPath:indexPath];
	
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


- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
 
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		Team* team = [self.teamsFetchedResultsController objectAtIndexPath:indexPath];
		
		NSString* alertTitle = [NSString stringWithFormat:@"Delete team: %@", [team getTitle]];
		UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* _Nonnull action) {

			[team delete];
			[team postNotificationDeletedWithSender:self];
			[Util saveManagedObjectContext];
		}];
		[Util presentActionAlertWithViewController:self andTitle:alertTitle andMessage:@"Cannot be undone! Are you sure?" andAction:deleteAction andCancelHandler:^(UIAlertAction* action) {
			
			[self.tableView setEditing:NO animated:YES];
		}];
	}
}


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
  didChangeSection:(nonnull id<NSFetchedResultsSectionInfo>)sectionInfo
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
   didChangeObject:(nonnull id)anObject
	   atIndexPath:(nullable NSIndexPath*)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(nullable NSIndexPath*)newIndexPath {
	
	UITableView* tableView = self.tableView;
	
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
 // In the simplest, most efficient case, reload the table view.
 [self.tableView reloadData];
 }
 */


#
# pragma mark Notification Handlers
#


- (void)dataModelResetWithNotification:(NSNotification*)notification {
	
	self.teamsFetchedResultsController = nil;
	
	[self.tableView reloadData];
	
	[self.navigationController popToRootViewControllerAnimated:NO];
}


- (void)teamCreatedWithNotification:(NSNotification*)notification {
	
	[self.tableView reloadData];
}


- (void)teamDeletedWithNotification:(NSNotification*)notification {
	
	[self.tableView reloadData];
}


- (void)teamUpdatedWithNotification:(NSNotification*)notification {
	
	[self.tableView reloadData];
}


- (void)rideCreatedWithNotification:(NSNotification*)notification {

	[self.tableView reloadData];
}


- (void)rideDeletedWithNotification:(NSNotification*)notification {
	
	[self.tableView reloadData];
}


- (void)rideUpdatedWithNotification:(NSNotification*)notification {
	
	[self.tableView reloadData];
}


#
# pragma mark Helper Methods
#


- (void)addNotificationObservers {
	
	[Util addDataModelResetObserver:self withSelector:@selector(dataModelResetWithNotification:)];
	
	[Team addCreatedObserver:self withSelector:@selector(teamCreatedWithNotification:)];
	[Team addDeletedObserver:self withSelector:@selector(teamDeletedWithNotification:)];
	[Team addUpdatedObserver:self withSelector:@selector(teamUpdatedWithNotification:)];
	
	[Ride addCreatedObserver:self withSelector:@selector(rideCreatedWithNotification:)];
	[Ride addDeletedObserver:self withSelector:@selector(rideDeletedWithNotification:)];
	[Ride addUpdatedObserver:self withSelector:@selector(rideUpdatedWithNotification:)];
}


- (void)configureCell:(UITableViewCell*)cell atIndexPath:(nonnull NSIndexPath *)indexPath {
	
	Team* team = [self.teamsFetchedResultsController objectAtIndexPath:indexPath];
	
	// Text
	
	NSString* status = [team getStatusText];
	status = status.length > 0 ? [NSString stringWithFormat:@" (%@)", status] : @"";
	cell.textLabel.text = [NSString stringWithFormat:@"%@%@ | Rides: %d", [team getTitle], status, (int)team.ridesAssigned.count];
	
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	
	// Start Detail
	
	NSString* startDateString = [self.cellDateFormatter stringFromDate:[NSDate date]];
	
	NSString* startAddress = team.locationCurrentAddress.length > 0
	? team.locationCurrentAddress
	: TEAMS_CELL_FIELD_EMPTY;
	
	NSString* startDetail = [NSString stringWithFormat:@"Loc: %@ -> %@", startDateString, startAddress];
	
	// End Detail
	
	Ride* lastRideAssigned = [team getLastRideAssigned];

	NSDate* routeDateTimeEnd = [lastRideAssigned getRouteDateTimeEnd];
	NSString* endDateString = routeDateTimeEnd
	? [self.cellDateFormatter stringFromDate:routeDateTimeEnd]
	: TEAMS_CELL_FIELD_EMPTY;
	
	NSString* endAddress = lastRideAssigned.locationEndAddress.length > 0
	? lastRideAssigned.locationEndAddress
	: TEAMS_CELL_FIELD_EMPTY;
	
	NSString* endDetail = [NSString stringWithFormat:@"End: %@ -> %@", endDateString, endAddress];
	
	// Route Detail
	
	NSString* durationString = [NSString stringWithFormat:@"%.0f", team.assignedDuration / (NSTimeInterval)SECONDS_PER_MINUTE];
	NSString* distanceString = [NSString stringWithFormat:@"%.1f", team.assignedDistance / (CLLocationDistance)METERS_PER_KILOMETER];
	NSString* routeDetail = [NSString stringWithFormat:@"%@ min | %@ km", durationString, distanceString];
	
	// Detail Text
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@", startDetail, endDetail, routeDetail];
	cell.detailTextLabel.numberOfLines = 0;
	cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
}


@end
