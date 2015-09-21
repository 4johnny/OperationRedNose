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

@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;

@property (nonatomic) NSDateFormatter* cellDateFormatter;

@end


#
# pragma mark - Implementation
#


@implementation TeamsTableViewController


- (NSFetchedResultsController*)fetchedResultsController {
	
	if (_fetchedResultsController) return _fetchedResultsController;
	
	NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:TEAM_ENTITY_NAME];
	fetchRequest.fetchBatchSize = TEAM_FETCH_BATCH_SIZE;
	fetchRequest.sortDescriptors =
	@[
	  [NSSortDescriptor sortDescriptorWithKey:TEAM_FETCH_SORT_KEY1 ascending:TEAM_FETCH_SORT_ASC1],
	  [NSSortDescriptor sortDescriptorWithKey:TEAM_FETCH_SORT_KEY2 ascending:TEAM_FETCH_SORT_ASC2],
	  ];
	
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[Util managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
	_fetchedResultsController.delegate = self;
	
	NSError* error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
		
		NSLog(@"Unresolved error: %@, %@", error, error.userInfo);
	}
	
	return _fetchedResultsController;
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
		teamDetailTableViewController.team = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
		
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
	
    return 1; //self.fetchedResultsController.sections.count;
}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	
    return self.fetchedResultsController.fetchedObjects.count;
//    return ((id<NSFetchedResultsSectionInfo>)self.fetchedResultsController.sections[section]).numberOfObjects;
}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	
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


- (void)teamCreatedWithNotification:(NSNotification*)notification {
	
	[self.tableView reloadData];
}


- (void)teamUpdatedWithNotification:(NSNotification*)notification {
	
	[self.tableView reloadData];
}


- (void)rideCreatedWithNotification:(NSNotification*)notification {

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
	[Team addUpdatedObserver:self withSelector:@selector(teamUpdatedWithNotification:)];
	
	[Ride addCreatedObserver:self withSelector:@selector(rideCreatedWithNotification:)];
	[Ride addUpdatedObserver:self withSelector:@selector(rideUpdatedWithNotification:)];	
}


- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
	
	Team* team = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	// Text
	
	NSString* teamTitle = [team getTitle];
	NSString* activeStatus = team.isActive ? @"Active" : @"Inactive";
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@) | Rides: %d", teamTitle, activeStatus, (int)team.ridesAssigned.count];
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	
	// Start Detail
	
	NSString* startDateString = [self.cellDateFormatter stringFromDate:[NSDate date]];
	
	NSString* startAddress = team.locationCurrentAddress.length > 0
	? team.locationCurrentAddress
	: TEAMS_CELL_FIELD_EMPTY;
	
	NSString* startDetail = [NSString stringWithFormat:@"Loc: %@ -> %@", startDateString, startAddress];
	
	// End Detail
	
	Ride* lastRideAssigned = [team getSortedRidesAssigned].lastObject;

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
