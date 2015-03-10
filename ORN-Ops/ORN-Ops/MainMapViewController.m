//
//  MainMapViewController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-24.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
//#import <AddressBookUI/AddressBookUI.h>

#import "MainMapViewController.h"
#import "AppDelegate.h"
#import "Ride+RideHelpers.h"
#import "RidePointAnnotation.h"
#import "TeamPointAnnotation.h"
#import "RideTeamAssignedPolyline.h"


#import "DemoUtil.h"


#
# pragma mark - Constants
#

#
# pragma mark Jurisdication Constants
#

#define CHARITY_NAME				@"KidSport"
#define JURISDICTION_NAME			@"Tri-Cities, Burnaby, New Westminster"
#define JURISDICTION_COORDINATE		BURNABY_COORDINATE
#define JURISDICTION_SEARCH_RADIUS	100000 // metres

#
# pragma mark Data Model Constants
#

#define RIDE_FETCH_SORT_KEY			@"dateTimeStart"
#define RIDE_FETCH_SORT_ASCENDING	YES
#define TEAM_FETCH_SORT_KEY			@"name"
#define TEAM_FETCH_SORT_ASCENDING	YES

#
# pragma mark Map Constants
#

#define RIDE_START_ANNOTATION_ID	@"rideStartAnnotation"
#define RIDE_END_ANNOTATION_ID		@"rideEndAnnotation"
#define TEAM_NORMAL_ANNOTATION_ID	@"teamNormalAnnotation"
#define TEAM_MASCOT_ANNOTATION_ID	@"teamMascotAnnotation"

#define MAP_ANNOTATION_DATETIME_FORMAT	@"HH:mm"
#define MAP_ANNOTATION_DURATION_FORMAT	@"%.0f min"

#
# pragma mark Command Constants
#

#define ENABLE_COMMANDS	// WARNING: Demo commands change *real* data model!!!
#define COMMAND_HELP			@"ornhelp"
#define COMMAND_DELETE_ALL		@"orndeleteall"
#define COMMAND_DEMO			@"orndemo"
#define COMMAND_DEMO_RIDES		@"orndemorides"
#define COMMAND_DEMO_TEAMS		@"orndemoteams"
#define COMMAND_DEMO_ASSIGN		@"orndemoassign"


#
# pragma mark - Interface
#


@interface MainMapViewController ()


#
# pragma mark Properties
#


@property (strong, nonatomic) NSFetchedResultsController* rideFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController* teamFetchedResultsController;

@property (nonatomic) CLGeocoder* geocoder;
@property (nonatomic) UIAlertController* okAlertController;
@property (nonatomic) NSDateFormatter* annotationDateFormatter;

@property (nonatomic) NSArray* showRides;
@property (nonatomic) NSArray* showTeams;


@end


#
# pragma mark - Implementation
#


@implementation MainMapViewController


#
# pragma mark Property Accessors
#


- (NSFetchedResultsController*)rideFetchedResultsController {
	
	if (_rideFetchedResultsController) return _rideFetchedResultsController;
	
	// Create fetch request for rides
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:RIDE_ENTITY_NAME];
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:RIDE_FETCH_SORT_KEY ascending:RIDE_FETCH_SORT_ASCENDING]];
	//fetchRequest.predicate = [NSPredicate predicateWithFormat:@"movie.id == %@", self.movie.id];
	//fetchRequest.fetchBatchSize = PAGE_LIMIT;
	//fetchRequest.fetchLimit = PAGE_LIMIT;
	
	// NOTE: nil for section name key path means "no sections"
	_rideFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	_rideFetchedResultsController.delegate = self;
	
	NSError *error = nil;
	if ([_rideFetchedResultsController performFetch:&error]) return _rideFetchedResultsController;
	
	// TODO: Replace this with code to handle the error appropriately.
	// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	NSLog(@"Unresolved error %@, %@", error, error.userInfo);
	abort();
	
	return _rideFetchedResultsController;
}


- (NSFetchedResultsController*)teamFetchedResultsController {
	
	if (_teamFetchedResultsController) return _teamFetchedResultsController;
	
	// Create fetch request for teams
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TEAM_ENTITY_NAME];
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:TEAM_FETCH_SORT_KEY ascending:TEAM_FETCH_SORT_ASCENDING]];
	//fetchRequest.predicate = [NSPredicate predicateWithFormat:@"movie.id == %@", self.movie.id];
	//fetchRequest.fetchBatchSize = PAGE_LIMIT;
	//fetchRequest.fetchLimit = PAGE_LIMIT;
	
	// NOTE: nil for section name key path means "no sections"
	_teamFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	_teamFetchedResultsController.delegate = self;
	
	NSError *error = nil;
	if ([_teamFetchedResultsController performFetch:&error]) return _teamFetchedResultsController;
	
	// TODO: Replace this with code to handle the error appropriately.
	// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	NSLog(@"Unresolved error %@, %@", error, error.userInfo);
	abort();
	
	return _teamFetchedResultsController;
}


- (CLGeocoder*)geocoder {
	
	if (_geocoder) return _geocoder;
	
	_geocoder = [[CLGeocoder alloc] init];
	
	return _geocoder;
}


- (UIAlertController*)okAlertController {
	
	if (_okAlertController) return _okAlertController;
	
	UIAlertAction* okAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
	_okAlertController = [UIAlertController alertControllerWithTitle:@"Error" message:nil preferredStyle:UIAlertControllerStyleAlert];
	[_okAlertController addAction:okAlertAction];
	
	return _okAlertController;
}


- (NSDateFormatter*)annotationDateFormatter {

	if (_annotationDateFormatter) return _annotationDateFormatter;
	
	_annotationDateFormatter = [[NSDateFormatter alloc] init];
	_annotationDateFormatter.dateFormat = MAP_ANNOTATION_DATETIME_FORMAT;

	return _annotationDateFormatter;
}


#
# pragma mark UIViewController
#


- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// Trigger keyboard preload to avoid UX delay
	[Util preloadKeyboardViaTextField:self.addressTextField];
	
	// Configure avatar in navigation item
	// NOTE: Must be done in code - otherwise we just get a template
	self.avatarBarButtonItem.image = [[UIImage imageNamed:@"ORN-Bar-Button-Item"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	
	// Wire up observers for update notifications for rides and teams
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rideUpdatedWithNotification:) name:RIDE_UPDATED_NOTIFICATION_NAME object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teamUpdatedWithNotification:) name:TEAM_UPDATED_NOTIFICATION_NAME object:nil];
	
	// Configure map with annotations, and zoom to show them all
	// NOTE: Delay so that orientation is established
	[self configureRegionView];
	[self performSelector:@selector(configureViewWithAnimation:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5];
	[self performSelector:@selector(showAllAnnotations) withObject:nil afterDelay:1];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


/*
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#
# pragma mark <NSFetchedResultsControllerDelegate>
#


- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
	
	// NOTE: Even if method is empty, at least one protocol method must be implemented for fetch-results controller to track changes
}


#
# pragma mark <UITextFieldDelegate>
#


// User hit keyboard return key
// NOTE: Text field is *not* empty due to "auto-enable" of return key
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	
	// Remove focus and keyboard
	[textField resignFirstResponder];
	
#ifdef ENABLE_COMMANDS
	
	// If command present, handle it and we are done
	if ([self handleCommandString:self.addressTextField.text]) {
		
		self.addressTextField.text = @"";
		
		return NO; // Do not perform default text-field behaviour
	}
	
#endif
	
	// Configure view with address string
	[self configureViewWithAddressString:self.addressTextField.text];
	
	return NO; // Do not perform default text-field behaviour
}


#
# pragma mark <MKMapViewDelegate>
#


//- (void)mapView:(MKMapView*)mapView regionDidChangeAnimated:(BOOL)animated {
//
//	// NOTE: Called many times during scrolling, so keep code lightweight
//}


//- (void)mapView:(MKMapView*)mapView didUpdateUserLocation:(MKUserLocation*)userLocation {
//
//}


- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	
	if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
	
	if ([annotation isKindOfClass:[RidePointAnnotation class]]) return [self mapView:mapView viewForRidePointAnnotation:(RidePointAnnotation*)annotation];
	
	if ([annotation isKindOfClass:[TeamPointAnnotation class]]) return [self mapView:mapView viewForTeamPointAnnotation:(TeamPointAnnotation*)annotation];
	
	return nil;
}


- (void)mapView:(MKMapView*)mapView didAddAnnotationViews:(NSArray*)views {
	
	// Animate dropping for team point annotations
	for (MKAnnotationView* view in views) {
		
		// If not team annotation, we are done with this view
		if (![view.annotation isKindOfClass:[TeamPointAnnotation class]]) continue;
		
		// If team annotation does not need animating, we are done with this view
		TeamPointAnnotation* teamPointAnnotation = view.annotation;
		if (!teamPointAnnotation.needsAnimation) continue;
		
		// Animation for team annotation has been triggered, so reset trigger
		teamPointAnnotation.needsAnimation = NO;
		
		// If annotation is not inside visible map rect, we are done with this view
		MKMapPoint point =  MKMapPointForCoordinate(view.annotation.coordinate);
		if (!MKMapRectContainsPoint(mapView.visibleMapRect, point)) continue;
		
		// Remember end frame for annotation
		CGRect endFrame = view.frame;
		
		// Move annotation out of view
		view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - self.view.frame.size.height, view.frame.size.width, view.frame.size.height);
		
		// Animate drop, completing with squash effect
		[UIView animateWithDuration:0.25 delay:(0.04 * [views indexOfObject:view]) options: UIViewAnimationOptionCurveLinear animations:^{
			
			view.frame = endFrame;
			
		} completion:^(BOOL finished) {
			
			if (!finished) return; // Exit block
			
			// Animate squash, completing with un-squash
			[UIView animateWithDuration:0.05 animations:^{
				
				view.transform = CGAffineTransformMakeScale(1.0, 0.8);
				
			} completion:^(BOOL finished){
				
				if (!finished) return; // Exit block
					
				[UIView animateWithDuration:0.1 animations:^{
					
					view.transform = CGAffineTransformIdentity;
				}];
			}];
		}];
	}
}


- (void)mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)view calloutAccessoryControlTapped:(UIControl*)control {
	
	// If user location, we are done
	if ([view.annotation isKindOfClass:[MKUserLocation class]]) return;
	
	// If ride, navigate to ride detail controller
	if ([view.annotation isKindOfClass:[RidePointAnnotation class]]) {
		
		MKPinAnnotationView* pinAnnotationView = (MKPinAnnotationView*)view;
		
		// Create ride detail controller
		RideDetailTableViewController* rideDetailTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:RIDE_DETAIL_TABLE_VIEW_CONTROLLER_ID];
		
		// Inject ride data model
		RidePointAnnotation* ridePointAnnotation = pinAnnotationView.annotation;
		rideDetailTableViewController.ride = ridePointAnnotation.ride;
		
		// Push onto navigation stack
		[self.navigationController pushViewController:rideDetailTableViewController animated:YES];
		
		return;
	}
	
	// If team, navigate to team detail controller
	if ([view.annotation isKindOfClass:[TeamPointAnnotation class]]) {
		
		// Create team detail controller
		TeamDetailTableViewController* teamDetailTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:TEAM_DETAIL_TABLE_VIEW_CONTROLLER_ID];
		
		// Inject team data model
		TeamPointAnnotation* teamPointAnnotation = view.annotation;
		teamDetailTableViewController.team = teamPointAnnotation.team;
		
		// Push onto navigation stack
		[self.navigationController pushViewController:teamDetailTableViewController animated:YES];
		
		return;
	}
}


- (void)mapView:(MKMapView*)mapView didSelectAnnotationView:(MKAnnotationView*)view {
	
	NSLog(@"didSelectAnnotationView: %@", view);
	
	if ([view.annotation isKindOfClass:[RidePointAnnotation class]]) {
		
		[self mapView:mapView didSelectRidePointAnnotationWithRide:((RidePointAnnotation*)view.annotation).ride];
		return;
	}
	
	if ([view.annotation isKindOfClass:[TeamPointAnnotation class]]) {
		
		[self mapView:mapView didSelectTeamPointAnnotationWithTeam:((TeamPointAnnotation*)view.annotation).team];
		return;
	}
}


- (void)mapView:(MKMapView*)mapView didDeselectAnnotationView:(MKAnnotationView*)view {
	
	NSLog(@"didDeselectAnnotationView: %@", view);
	
	// Remove route overlays
	[self clearAllOverlays];
	
//	RidePointAnnotation* ridePointAnnotation = view.annotation;
//	Ride* ride = ridePointAnnotation.ride;
	
	// Find route overlays related to given ride - if none, we are done
	// NOTE: There should be max 1 overlay
//	NSArray* annotationsAffected =
//	[self.mainMapView.annotations filteredArrayUsingPredicate:
//	 [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
//		
//		if (![evaluatedObject isKindOfClass:[RidePointAnnotation class]]) return NO;
//		RidePointAnnotation* ridePointAnnotation = evaluatedObject;
//		
//		return ridePointAnnotation.ride == ride;
//	}]];
//	
//	// Refresh map annotations - remove, re-init, re-add, and re-select
//	for (RidePointAnnotation* ridePointAnnotation in annotationsAffected) {
//		
//		BOOL isAnnotationSelected = [self.mainMapView.selectedAnnotations containsObject:ridePointAnnotation];
//		
//		[self.mainMapView removeAnnotation:ridePointAnnotation];
//		[self.mainMapView addAnnotation:[ridePointAnnotation initWithRide:ride andRideLocationType:ridePointAnnotation.rideLocationType andNeedsAnimation:needsAnimation]];
//		
//		if (isAnnotationSelected) {
//			[self.mainMapView selectAnnotation:ridePointAnnotation animated:needsAnimation];
//		}
//	}
}


- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id<MKOverlay>)overlay {

	MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
	renderer.strokeColor = [UIColor blueColor];
	renderer.alpha = 0.5;
	renderer.lineWidth = 5.0;

	// For overlay between team and ride use dotted line
	if ([overlay isKindOfClass:[RideTeamAssignedPolyline class]]) {
		
		renderer.lineDashPattern = @[@5, @10];
		//	renderer.lineDashPhase = 6;
	}
	
	return renderer;
}


#
# pragma mark <ORNDataModelSource>
#


+ (void)saveManagedObjectContext {
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate saveManagedObjectContext];
}


#
# pragma mark Action Handlers
#


- (IBAction)avatarBarButtonPressed:(UIBarButtonItem *)sender {
	
	// Re-orientate map back to initial perspective
	[self configureRegionView];
}


- (IBAction)mapTypeChanged:(UISegmentedControl*)sender {
	
	switch (self.mapTypeSegmentedControl.selectedSegmentIndex) {
			
		default:
		case 0:
			self.mainMapView.mapType = MKMapTypeStandard;
			break;
			
		case 1:
			self.mainMapView.mapType = MKMapTypeHybrid;
			break;
			
		case 2:
			self.mainMapView.mapType = MKMapTypeSatellite;
			break;
	}
}


#
# pragma mark Notification Handlers
#


- (void)rideUpdatedWithNotification:(NSNotification*)notification {
	
	// Find map annotations for given ride - if none, we are done
	// NOTE: Should be max 2, one each for start and end locations
	Ride* ride = notification.userInfo[RIDE_ENTITY_NAME];
	NSArray* annotationsAffected = [self.mainMapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
		
		return [evaluatedObject isKindOfClass:[RidePointAnnotation class]] && ((RidePointAnnotation*)evaluatedObject).ride == ride;
	}]];
	if (annotationsAffected.count == 0) return;
	
	// Grab start and end annotations explicitly, if present
	RidePointAnnotation* ridePointAnnotationStart = nil;
	RidePointAnnotation* ridePointAnnotationEnd = nil;
	for (RidePointAnnotation* ridePointAnnotation in annotationsAffected) {
		
		switch (ridePointAnnotation.rideLocationType) {
				
			case RideLocationType_Start:
				ridePointAnnotationStart = ridePointAnnotation;
				break;
				
			case RideLocationType_End:
				ridePointAnnotationEnd = ridePointAnnotation;
				break;
				
			default:
			case RideLocationType_None:
				break;
		}
	}
	
	// If start annotation is present, update it and its view
	if (ridePointAnnotationStart) {
		
		BOOL updatedLocationStart = (notification.userInfo[RIDE_UPDATED_LOCATION_START_NOTIFICATION_KEY] && ((NSNumber*)notification.userInfo[RIDE_UPDATED_LOCATION_START_NOTIFICATION_KEY]).boolValue);
		
		ridePointAnnotationStart = [ridePointAnnotationStart initWithRide:ride andRideLocationType:RideLocationType_Start andNeedsAnimation:updatedLocationStart];
		
		if (updatedLocationStart) {
			
			// Remove and re-add to map view - automatically triggers new annotation view
			[self.mainMapView removeAnnotation:ridePointAnnotationStart];
			[self.mainMapView addAnnotation:ridePointAnnotationStart];
			
		} else {
			
			// If view exists for given annotation, update it
			MKPinAnnotationView* ridePinAnnotationView = (MKPinAnnotationView*)[self.mainMapView viewForAnnotation:ridePointAnnotationStart];
			if (ridePinAnnotationView) {
				
				[self updateRidePinAnnotationView:ridePinAnnotationView withRidePointAnnotation:ridePointAnnotationStart];
			}
		}
	}
	
	// If end annotation is present, update it and its view - remove and re-add to map view if location updated
	if (ridePointAnnotationEnd) {
		
		BOOL updatedLocationEnd = (notification.userInfo[RIDE_UPDATED_LOCATION_END_NOTIFICATION_KEY] && ((NSNumber*)notification.userInfo[RIDE_UPDATED_LOCATION_END_NOTIFICATION_KEY]).boolValue);
		
		ridePointAnnotationEnd = [ridePointAnnotationEnd initWithRide:ride andRideLocationType:RideLocationType_End andNeedsAnimation:updatedLocationEnd];
		
		if (updatedLocationEnd) {
			
			[self.mainMapView removeAnnotation:ridePointAnnotationEnd];
			[self.mainMapView addAnnotation:ridePointAnnotationEnd];
			
		} else {
			
			// If annotation view exists for given annotation, update it
			MKPinAnnotationView* ridePinAnnotationView = (MKPinAnnotationView*)[self.mainMapView viewForAnnotation:ridePointAnnotationEnd];
			if (ridePinAnnotationView) {
				
				[self updateRidePinAnnotationView:ridePinAnnotationView withRidePointAnnotation:ridePointAnnotationEnd];
			}
		}
	}
}


- (void)teamUpdatedWithNotification:(NSNotification*)notification {
	
	// Find map annotations related to given team - if none, we are done
	// NOTE: Should be max 1
	Team* team = notification.userInfo[TEAM_ENTITY_NAME];
	NSArray* annotationsAffected = [self.mainMapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
		
		return [evaluatedObject isKindOfClass:[TeamPointAnnotation class]] && ((TeamPointAnnotation*)evaluatedObject).team == team;
	}]];
	if (annotationsAffected.count == 0) return;
	
	// Grab team annotation explicitly
	TeamPointAnnotation* teamPointAnnotation = annotationsAffected.firstObject;
	
	// Update team annotation and its view
	BOOL updatedLocation = (notification.userInfo[TEAM_UPDATED_LOCATION_NOTIFICATION_KEY] && ((NSNumber*)notification.userInfo[TEAM_UPDATED_LOCATION_NOTIFICATION_KEY]).boolValue);
	
	teamPointAnnotation = [teamPointAnnotation initWithTeam:team andNeedsAnimation:updatedLocation];
	
	if (updatedLocation) {
		
		// Remove and re-add to map view - automatically triggers new annotation view
		[self.mainMapView removeAnnotation:teamPointAnnotation];
		[self.mainMapView addAnnotation:teamPointAnnotation];
		
	} else {
		
		// If view exists for given annotation, update it
		MKAnnotationView* teamAnnotationView = [self.mainMapView viewForAnnotation:teamPointAnnotation];
		if (teamAnnotationView) {
			
			[self updateTeamAnnotationView:teamAnnotationView withTeamPointAnnotation:teamPointAnnotation];
		}
	}
}


#
# pragma mark Command Handlers
#


// Handle command string
// Returns whether command string was handled
- (BOOL)handleCommandString:(NSString*)commandString {
	
	commandString = [commandString lowercaseString];
	
	BOOL isCommandHandled = NO;
	BOOL needsDataModelSave = NO;
	
	if ([COMMAND_HELP isEqualToString:commandString]) {
		
		[self presentAlertWithTitle:@"ORN Commands"
						 andMessage:[NSString stringWithFormat:
									 @"%@\n%@\n%@\n%@\n%@\n%@",
									 COMMAND_HELP,
									 COMMAND_DELETE_ALL,
									 COMMAND_DEMO,
									 COMMAND_DEMO_RIDES,
									 COMMAND_DEMO_TEAMS,
									 COMMAND_DEMO_ASSIGN
									 ]];
		isCommandHandled = YES;
		
	} else if ([COMMAND_DELETE_ALL isEqualToString:commandString]) {
		
		UIAlertAction* deleteAllAlertAction = [UIAlertAction actionWithTitle:@"Delete All" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			
			// Delete all rides and teams
			// TODO: Intead, just ask AppDelegate to delete and recreate the backing DB file
			AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
			[appDelegate deleteAllObjectsWithEntityName:RIDE_ENTITY_NAME];
			[appDelegate deleteAllObjectsWithEntityName:TEAM_ENTITY_NAME];
			
			// Reset map
			[self clearAllAnnotations];
			[self configureRegionView];
		}];
		UIAlertController* deleteAllAlertController = [UIAlertController alertControllerWithTitle:@"!!! Warning !!!" message:@"About to delete all data, which cannot be undone!  Are you absolutely sure?!" preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* cancelAlertAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
		[deleteAllAlertController addAction:deleteAllAlertAction];
		[deleteAllAlertController addAction:cancelAlertAction];
		
		[self presentViewController:deleteAllAlertController animated:YES completion:nil];
		
		isCommandHandled = YES;
		
	} else if ([COMMAND_DEMO isEqualToString:commandString]) {
		
		// Run all demo commands
		[self handleCommandString:COMMAND_DEMO_RIDES];
		[self handleCommandString:COMMAND_DEMO_TEAMS];
		[self handleCommandString:COMMAND_DEMO_ASSIGN];
		
		isCommandHandled = YES;
		
	} else if ([COMMAND_DEMO_RIDES isEqualToString:commandString]) {
		
		// Load all demo rides
		[DemoUtil loadDemoRidesIntoManagedObjectContext:self.managedObjectContext];
		self.rideFetchedResultsController = nil; // Trip refetch
		[self configureRidesViewWithAnimation:YES];
		[self showAllAnnotations];
		
		needsDataModelSave = YES;
		isCommandHandled = YES;
		
	} else if ([COMMAND_DEMO_TEAMS isEqualToString:commandString]) {
		
		// Load all demo teams
		[DemoUtil loadDemoTeamsIntoManagedObjectContext:self.managedObjectContext];
		self.teamFetchedResultsController = nil; // Trip refetch
		[self configureTeamsViewWithAnimation:YES];
		[self showAllAnnotations];
		
		needsDataModelSave = YES;
		isCommandHandled = YES;
		
	} else if ([COMMAND_DEMO_ASSIGN isEqualToString:commandString]) {
		
		// Assign teams to rides
		[DemoUtil loadDemoAssignTeams:self.teamFetchedResultsController.fetchedObjects toRides:self.rideFetchedResultsController.fetchedObjects];
		[self configureRidesViewWithAnimation:NO];
		[self configureTeamsViewWithAnimation:NO];
		[self showAllAnnotations];
		
		needsDataModelSave = YES;
		isCommandHandled = YES;
	}
	
	if (isCommandHandled) {
		NSLog(@"Handled Command: %@", commandString);
		
		if (needsDataModelSave) {
			[MainMapViewController saveManagedObjectContext];
		}
	}
	
	return isCommandHandled;
}


#
# pragma mark Helpers
#


- (void)configureViewWithAnimation:(BOOL)needsAnimation {
	
	// Configure ride annotations and callouts
	[self configureRidesViewWithAnimation:needsAnimation];
	
	// Configure team annotations and callouts
	[self configureTeamsViewWithAnimation:needsAnimation];
}


- (void)configureViewWithAnimationSelector:(NSNumber*)needsAnimation {
	
	[self configureViewWithAnimation:needsAnimation.boolValue];
}


- (void)configureRegionView {
	
	MKCoordinateRegion centerRegion = MKCoordinateRegionMake(JURISDICTION_COORDINATE, MKCoordinateSpanMake(MAP_SPAN_LOCATION_DELTA_CITY, MAP_SPAN_LOCATION_DELTA_CITY));
	
	[self.mainMapView setRegion:centerRegion animated:YES];
}


- (void)configureRidesViewWithAnimation:(BOOL)needsAnimation {
	
	self.showRides = self.rideFetchedResultsController.fetchedObjects;
	
	for (Ride* ride in self.showRides) {
		
		// If no start-location coordinate, we are done with this ride
		// NOTE: Orphaned end locations will also *not* been shown
		if (!ride.locationStartLatitude || !ride.locationStartLongitude) continue;
		
		// Add annotation for start location to map
		[self.mainMapView addAnnotation:[RidePointAnnotation ridePointAnnotationWithRide:ride andRideLocationType:RideLocationType_Start andNeedsAnimation:needsAnimation]];
		
		// If no end-location coordinate, we are done with this ride
		if (!ride.locationEndLatitude || !ride.locationEndLongitude) continue;
		
		// Add annotation for end location to map
		[self.mainMapView addAnnotation:[RidePointAnnotation ridePointAnnotationWithRide:ride andRideLocationType:RideLocationType_End andNeedsAnimation:needsAnimation]];
	}
}


- (void)configureTeamsViewWithAnimation:(BOOL)needsAnimation {
	
	self.showTeams = self.teamFetchedResultsController.fetchedObjects;
	
	for (Team* team in self.showTeams) {
		
		// If no current-location coordinate, we are done with this team
		if (!team.locationCurrentLatitude || !team.locationCurrentLongitude) continue;
		
		// Add annotation for current location to map
		[self.mainMapView addAnnotation:[TeamPointAnnotation teamPointAnnotationWithTeam:team andNeedsAnimation:needsAnimation]];
	}
}


- (void)configureViewWithAddressString:(NSString*)addressString {
	
	// Geocode given address string relative to jurisdiction
	
	CLCircularRegion* jurisdictionRegion = [[CLCircularRegion alloc] initWithCenter:JURISDICTION_COORDINATE radius:JURISDICTION_SEARCH_RADIUS identifier:@"ORN Jurisdication Region"];
	
	[self.geocoder geocodeAddressString:addressString inRegion:jurisdictionRegion completionHandler:^(NSArray* placemarks, NSError* error) {
		
		// NOTES: Completion block executes on main thread. Do not run more than one reverse-geocode simultaneously.
		
		// If there is a problem, log it; alert the user; and we are done.
		if (error || placemarks.count < 1) {
			
			if (error) {
				NSLog(@"Geocode Error: %@ %@", error.localizedDescription, error.userInfo);
			} else if (placemarks.count < 1) {
				NSLog(@"Geocode Error: No placemarks for address string: %@", addressString);
			}
			
			[self presentAlertWithTitle:@"Error" andMessage:@"Cannot find address."];
			
			return;
		}
		
		// Address resolved successfully to have at least one placemark
		CLPlacemark* placemark = placemarks[0];
		NSLog(@"Geocode location: %@", placemark.location);
		NSLog(@"Geocode locality: %@", placemark.locality);
		NSLog(@"Geocode address: %@", placemark.addressDictionary);
		
		// Use first placemark as start location for new ride
		Ride* ride = [MainMapViewController rideFromPlacemark:placemark inManagedObjectContext:self.managedObjectContext];
		[MainMapViewController saveManagedObjectContext];
		NSLog(@"Ride: %@", ride);
		
		// Clear entry field and annotate ride on map view
		self.addressTextField.text = @"";
		RidePointAnnotation* rideStartPointAnnotation = [RidePointAnnotation ridePointAnnotationWithRide:ride andRideLocationType:RideLocationType_Start andNeedsAnimation:YES];
		[self.mainMapView addAnnotation:rideStartPointAnnotation];
		[self.mainMapView setCenterCoordinate:CLLocationCoordinate2DMake(ride.locationStartLatitude.doubleValue, ride.locationStartLongitude.doubleValue) animated:YES];
		[self.mainMapView selectAnnotation:rideStartPointAnnotation animated:YES];
	}];
}


- (void)presentAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
	
	self.okAlertController.title = title;
	self.okAlertController.message = message;
	
	[self presentViewController:self.okAlertController animated:YES completion:nil];
}


- (void)showAllAnnotations {
	
	[self.mainMapView showAnnotations:self.mainMapView.annotations animated:YES];
}


- (void)clearAllAnnotations {
	
	[self.mainMapView removeAnnotations:self.mainMapView.annotations];
}


- (void)clearAllAnnotationSelections {
	
	for (id<MKAnnotation> annotation in self.mainMapView.annotations) {
		
		[self.mainMapView deselectAnnotation:annotation animated:NO];
	}
}


- (void)clearAllOverlays {

	[self.mainMapView removeOverlays:self.mainMapView.overlays];
}


- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForRidePointAnnotation:(RidePointAnnotation*)ridePointAnnotation {

	// Grab pooled/new ride annotation view
	MKPinAnnotationView* ridePinAnnotationView = (MKPinAnnotationView*)[MainMapViewController dequeueReusableAnnotationViewWithMapView:mapView andAnnotation:ridePointAnnotation andIdentifier:ridePointAnnotation.rideLocationType == RideLocationType_End ? RIDE_END_ANNOTATION_ID : RIDE_START_ANNOTATION_ID];

	// Update view based on given annotation
	[self updateRidePinAnnotationView:ridePinAnnotationView withRidePointAnnotation:ridePointAnnotation];
	
	return ridePinAnnotationView;
}


- (MKPinAnnotationView*)updateRidePinAnnotationView:(MKPinAnnotationView*)ridePinAnnotationView withRidePointAnnotation:(RidePointAnnotation*)ridePointAnnotation {
	
	Ride* ride = ridePointAnnotation.ride;
	
	// Animate annotation if triggered, and reset trigger
	ridePinAnnotationView.animatesDrop = ridePointAnnotation.needsAnimation;
	ridePointAnnotation.needsAnimation = NO;
	
	// Set pin color based on status
	// NOTE: By convention, color for route start is green, and end is red.  If no team assigned, start is purple.
	ridePinAnnotationView.pinColor = ridePointAnnotation.rideLocationType == RideLocationType_End ? MKPinAnnotationColorRed : (ride.teamAssigned ? MKPinAnnotationColorGreen : MKPinAnnotationColorPurple);
	
	// Add/update/remove left callout accessory
	// NOTE: Do not assign for update, to avoid re-animation
	if (!ridePinAnnotationView.leftCalloutAccessoryView) {
		
		ridePinAnnotationView.leftCalloutAccessoryView = [MainMapViewController leftCalloutAccessoryLabel];
	}
	if (![self updateLeftCalloutAccessoryLabel:(UILabel*)ridePinAnnotationView.leftCalloutAccessoryView withRidePointAnnotation:ridePointAnnotation]) {
		
		ridePinAnnotationView.leftCalloutAccessoryView = nil;
	}

	return ridePinAnnotationView;
}


- (UILabel*)updateLeftCalloutAccessoryLabel:(UILabel*)leftCalloutAccessoryLabel withRidePointAnnotation:(RidePointAnnotation*)ridePointAnnotation {

	Ride* ride = ridePointAnnotation.ride;
	
	// If time present, add to label with appropriate background color
	
	switch (ridePointAnnotation.rideLocationType) {
			
		case RideLocationType_Start: {
			
			if (!ride.dateTimeStart) return nil;
			
			leftCalloutAccessoryLabel.text = [self.annotationDateFormatter stringFromDate:ride.dateTimeStart];
			
			leftCalloutAccessoryLabel.backgroundColor = ride.teamAssigned ? [UIColor greenColor] : [UIColor purpleColor];
			
			break;
		}
			
		case RideLocationType_End: {
			
			if (!ride.dateTimeEnd) return nil;
			
			leftCalloutAccessoryLabel.text = [self.annotationDateFormatter stringFromDate:ride.dateTimeEnd];
			
			leftCalloutAccessoryLabel.backgroundColor = [UIColor redColor];
			
			break;
		}
			
		default:
		case RideLocationType_None:
			break;
	}

	return leftCalloutAccessoryLabel;
}


- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForTeamPointAnnotation:(TeamPointAnnotation*)teamPointAnnotation {
	
	// Grab pooled/new team annotation view
	MKAnnotationView* teamAnnotationView = (MKAnnotationView*)[MainMapViewController dequeueReusableAnnotationViewWithMapView:mapView andAnnotation:teamPointAnnotation andIdentifier:teamPointAnnotation.team.isMascot.boolValue ? TEAM_MASCOT_ANNOTATION_ID : TEAM_NORMAL_ANNOTATION_ID];

	// Update view based on given annotation
	[self updateTeamAnnotationView:teamAnnotationView withTeamPointAnnotation:teamPointAnnotation];

	return teamAnnotationView;
}


- (MKAnnotationView*)updateTeamAnnotationView:(MKAnnotationView*)teamAnnotationView withTeamPointAnnotation:(TeamPointAnnotation*)teamPointAnnotation {
	
	// Team* team = teamPointAnnotation.team;
	
	// NOTE: Animation of team annotation is done manually in "mapView:didAddAnnotationViews:"

	// Add/update/remove left callout accessory
	// NOTE: Do not assign for update, to avoid re-animation
	if (!teamAnnotationView.leftCalloutAccessoryView) {
		
		teamAnnotationView.leftCalloutAccessoryView = [MainMapViewController leftCalloutAccessoryLabel];
	}
	if (![self updateLeftCalloutAccessoryLabel:(UILabel*)teamAnnotationView.leftCalloutAccessoryView withTeamPointAnnotation:teamPointAnnotation]) {
		
		teamAnnotationView.leftCalloutAccessoryView = nil;
	}
	
	return teamAnnotationView;
}


- (UILabel*)updateLeftCalloutAccessoryLabel:(UILabel*)leftCalloutAccessoryLabel withTeamPointAnnotation:(TeamPointAnnotation*)teamPointAnnotation {
	
	Team* team = teamPointAnnotation.team;
	
	// If team assigned to rides, add total busy duration to label
	
	if (!team.ridesAssigned || team.ridesAssigned.count == 0) return nil;
		
	// TODO: Use proper calculation for duration until available
	double busyDuration = 0; // seconds
	for (Ride* rideAssigned in team.ridesAssigned) {
		
		busyDuration += rideAssigned.duration.doubleValue;
	}
	leftCalloutAccessoryLabel.text = [NSString stringWithFormat:MAP_ANNOTATION_DURATION_FORMAT, busyDuration / (double)SECONDS_PER_MINUTE];
	
	leftCalloutAccessoryLabel.backgroundColor = [UIColor blueColor];
	
	return leftCalloutAccessoryLabel;
}


+ (UILabel*)leftCalloutAccessoryLabel {
	
	UILabel* leftCalloutAccessoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 53)];
	leftCalloutAccessoryLabel.font = [UIFont boldSystemFontOfSize:14.0];
	leftCalloutAccessoryLabel.textAlignment = NSTextAlignmentCenter;
	leftCalloutAccessoryLabel.textColor = [UIColor whiteColor];
	leftCalloutAccessoryLabel.alpha = 0.5;
	
	return leftCalloutAccessoryLabel;
}


- (void)mapView:(MKMapView*)mapView didSelectRidePointAnnotationWithRide:(Ride*)ride {

	// Add polyline from team assigned location to ride start, if possible
	RideTeamAssignedPolyline* rideTeamAssignedPolylineToRideStart = nil;
	if (ride.teamAssigned && ride.teamAssigned.locationCurrentLatitude && ride.teamAssigned.locationCurrentLongitude && ride.locationStartLatitude && ride.locationStartLongitude) {
		
		CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(ride.locationStartLatitude.doubleValue, ride.locationStartLongitude.doubleValue);
		
		rideTeamAssignedPolylineToRideStart = [RideTeamAssignedPolyline rideTeamPolylineWithRide:ride andStartCoordinate:&startCoordinate];
		
		[self.mainMapView addOverlay:rideTeamAssignedPolylineToRideStart level:MKOverlayLevelAboveLabels];
	}

	// If cannot get directions request, we are done with this ride
	MKDirectionsRequest* directionsRequest = ride.getDirectionsRequest;
	if (!directionsRequest) return;
	
	// Determine route for ride, and add overlay to map asynchronously
	MKDirections* directions = [[MKDirections alloc] initWithRequest:directionsRequest];
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse* response, NSError* error) {
		
		// NOTES: Completion block executes on main thread. Do not run more than one directions calculation simultaneously on this object.
		if (error) {
			NSLog(@"ETA Error: %@ %@", error.localizedDescription, error.userInfo);
			return;
		}
		
		// Route directions calculated successfully, so grab first one
		// NOTE: Should be exactly 1, since we did not request alternate routes
		MKRoute* route = response.routes.firstObject;
		
		// Update expected travel time for ride, since may have changed
		ride.duration = [NSNumber numberWithDouble:route.expectedTravelTime]; // seconds
		NSLog(@"ETA: %.0f sec -> %.2f min", route.expectedTravelTime, route.expectedTravelTime / (double)SECONDS_PER_MINUTE);
		
		// Determine end time by adding ETA seconds to start time
		ride.dateTimeEnd = [NSDate dateWithTimeInterval:route.expectedTravelTime sinceDate:ride.dateTimeStart];
		
		// Store distance in ride
		ride.distance = [NSNumber numberWithDouble:route.distance]; // meters
		
		// Notify that ride and assigned team have updated
		[[NSNotificationCenter defaultCenter] postNotificationName:RIDE_UPDATED_NOTIFICATION_NAME object:self userInfo:@{RIDE_ENTITY_NAME:ride}];
		if (ride.teamAssigned) {
			[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:self userInfo:@{TEAM_ENTITY_NAME:ride.teamAssigned}];
		}
		
		// If ride or team assigned not still selected, we are done
		MKPointAnnotation* selectedAnnotation = self.mainMapView.selectedAnnotations.firstObject;
		if (!([selectedAnnotation isKindOfClass:[RidePointAnnotation class]] && ((RidePointAnnotation*)selectedAnnotation).ride == ride) &&
			!([selectedAnnotation isKindOfClass:[TeamPointAnnotation class]] && ((TeamPointAnnotation*)selectedAnnotation).team == ride.teamAssigned)) return;

		// Remove existing ride-team assigned polyline, if present
		if (rideTeamAssignedPolylineToRideStart) {
			[self.mainMapView removeOverlay:rideTeamAssignedPolylineToRideStart];
		}
		
		// Add polyline from team assigned location to actual route start, if possible
		if (ride.teamAssigned && ride.teamAssigned.locationCurrentLatitude && ride.teamAssigned.locationCurrentLongitude) {
			
			CLLocationCoordinate2D startCoordinate = MKCoordinateForMapPoint(route.polyline.points[0]);
			
			RideTeamAssignedPolyline* rideTeamAssignedPolylineToRouteStart = [RideTeamAssignedPolyline rideTeamPolylineWithRide:ride andStartCoordinate:&startCoordinate];
			
			[self.mainMapView addOverlay:rideTeamAssignedPolylineToRouteStart level:MKOverlayLevelAboveLabels];
		}
		
		// Add route polyline from ride start to end
		[self.mainMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];

		// TODO: Consider features that also utilize the route steps and advisory notices
		//		NSLog(@"Route Steps (%d):", (int)route.steps.count);
		//		for (MKRouteStep* step in route.steps) {
		//			NSLog(@"\t%@", step.instructions);
		//		}
		//
		//		NSLog(@"Route Advisory Notices (%d):", (int)route.advisoryNotices.count);
		//		for (NSString* advisoryNotice in route.advisoryNotices) {
		//			NSLog(@"\t%@", advisoryNotice);
		//		}
	}];
}


- (void)mapView:(MKMapView*)mapView didSelectTeamPointAnnotationWithTeam:(Team*)team {
	
	if (!team.ridesAssigned) return;
	
	for (Ride* ride in team.ridesAssigned) {

		[self mapView:mapView didSelectRidePointAnnotationWithRide:ride];
	}
}


+ (MKAnnotationView*)dequeueReusableAnnotationViewWithMapView:(MKMapView*)mapView andAnnotation:(id<MKAnnotation>)annotation andIdentifier:(NSString*)identifier {
	
	// Reuse pooled annotation if possible
	MKAnnotationView* annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (annotationView) {
		annotationView.annotation = annotation;
		return annotationView;
	}
	
	// Create new annotation
	MKAnnotationView* view = nil;
	
	if ([identifier isEqualToString:RIDE_START_ANNOTATION_ID] ||
		[identifier isEqualToString:RIDE_END_ANNOTATION_ID]) {
		
		view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		
	} else if ([identifier isEqualToString:TEAM_MASCOT_ANNOTATION_ID] ||
			   [identifier isEqualToString:TEAM_NORMAL_ANNOTATION_ID]) {
	
		view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		view.image = [UIImage imageNamed:[identifier isEqualToString:TEAM_MASCOT_ANNOTATION_ID] ? @"ORN-Team-Mascot-Map-Annotation" : @"ORN-Team-Map-Annotation"];
	}

	// Enable callout view for annotation
	view.canShowCallout = YES;
	
	// Add disclosure button to right side of callout
	UIButton* rightDisclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[rightDisclosureButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
	view.rightCalloutAccessoryView = rightDisclosureButton;
	
	return view;
}


+ (Ride*)rideFromPlacemark:(CLPlacemark*)placemark inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	return [Ride rideWithManagedObjectContext:managedObjectContext
				   andLocationStartCoordinate:placemark.location.coordinate
					  andLocationStartAddress:[MainMapViewController addressStringWithPlacemark:placemark]
						 andLocationStartCity:placemark.locality];
}


+ (NSString*)addressStringWithPlacemark:(CLPlacemark*)placemark {
	
	NSString* street = placemark.addressDictionary[@"Street"];
	NSString* city = placemark.addressDictionary[@"City"];
	
	if (street && city) return [NSString stringWithFormat:@"%@, %@", street, city];
	
	return [NSString stringWithFormat:@"%@ (%.3f,%.3f)", placemark.name, placemark.location.coordinate.latitude, placemark.location.coordinate.longitude];
	
	//	return ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
}


@end
