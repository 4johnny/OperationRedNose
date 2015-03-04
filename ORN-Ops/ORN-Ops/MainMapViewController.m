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
#define RIDE_FETCH_SORT_ASCENDING	NO
#define TEAM_FETCH_SORT_KEY			@"name"
#define TEAM_FETCH_SORT_ASCENDING	YES

#
# pragma mark Map Constants
#

#define RIDE_START_ANNOTATION_ID			@"rideStartAnnotation"
#define RIDE_END_ANNOTATION_ID				@"rideEndAnnotation"
#define TEAM_CURRENT_NORMAL_ANNOTATION_ID	@"teamCurrentNormalAnnotation"
#define TEAM_CURRENT_MASCOT_ANNOTATION_ID	@"teamCurrentMascotAnnotation"

#define MAP_ANNOTATION_TIME_FORMAT		@"HH:mm"
#define LEFT_CALLOUT_ACCESSORY_FRAME	CGRectMake(0, 0, 35, 30)

#
# pragma mark Command Constants
#

#define ENABLE_COMMANDS	// WARNING: Demo commands change *real* data model!!!
#define COMMAND_HELP			@"ornhelp"
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

@property (strong, nonatomic) CLGeocoder* geocoder;
@property (strong, nonatomic) UIAlertController* okAlertController;

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
	
	// Configure map zoom and annotations
	[self configureView];
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
	
	if ([annotation isKindOfClass:[RidePointAnnotation class]]) return [MainMapViewController mapView:mapView viewForRidePointAnnotation:(RidePointAnnotation*)annotation];
	
	if ([annotation isKindOfClass:[TeamPointAnnotation class]]) return [MainMapViewController mapView:mapView viewForTeamPointAnnotation:(TeamPointAnnotation*)annotation];
	
	return nil;
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
		
		// Wire up delegate
		rideDetailTableViewController.delegate = self;
		
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
		
		// Wire up delegate
//		teamDetailTableViewController.delegate = self;
		
		// Push onto navigation stack
		[self.navigationController pushViewController:teamDetailTableViewController animated:YES];
		
		return;
	}
}


//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
//
//	return nil;
//}


#
# pragma mark <RideDetailTableViewControllerDelegate>
#


// TODO: Use NSNotification instead of delegate, since changes can happen outside our direct control
- (void)rideDetailTableViewController:(RideDetailTableViewController*)controller didSaveRide:(Ride*)ride {
	
	// Find ride annotations related to given ride - if none, we are done
	NSArray* annotationsAffected = [self.mainMapView.annotations filteredArrayUsingPredicate:
									[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
		
		if (![evaluatedObject isKindOfClass:[RidePointAnnotation class]]) return NO;
		
		RidePointAnnotation* ridePointAnnotation = evaluatedObject;
		return ridePointAnnotation.ride == ride;
	}]];
	
	// Refresh map annotations by removing, reinitializing, and re-adding to map view
	for (RidePointAnnotation* ridePointAnnotation in annotationsAffected) {
		
		[self.mainMapView removeAnnotation:ridePointAnnotation];
		[self.mainMapView addAnnotation:[ridePointAnnotation initWithRide:ride andRideLocationType:ridePointAnnotation.rideLocationType]];
		
		if (ridePointAnnotation.rideLocationType == RideLocationType_Start) {
			[self.mainMapView selectAnnotation:ridePointAnnotation animated:YES];
		}
	}
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
	[self clearAllAnnotationSelections];
	[self showAllAnnotations];
}


#
# pragma mark Helpers
#


- (void)configureView {
	
	// Clear any existing annotationa
	[self.mainMapView removeAnnotations:self.mainMapView.annotations];
	
	// Initially center and zoom map on juridiction region
	MKCoordinateRegion centerRegion = MKCoordinateRegionMake(JURISDICTION_COORDINATE, MKCoordinateSpanMake(MAP_SPAN_LOCATION_DELTA_CITY, MAP_SPAN_LOCATION_DELTA_CITY));
	[self.mainMapView setRegion:centerRegion animated:YES];

	// Configure ride annotations and callouts
	[self configureRidesView];
	
	// Configure team annotations and callouts
	[self configureTeamsView];
	
	// Zoom map to show all annotations
	// TODO: potentially put on timer delay, since seems to get ignored
	[self showAllAnnotations];
}


- (void)configureRidesView {
	
	// If set of rides specified, show them; o/w show all
	self.showRides = self.showRides ?: self.rideFetchedResultsController.fetchedObjects;
	
	for (Ride* ride in self.showRides) {
		
		// If no start-location coordinate, we are done with this ride
		// NOTE: Orphaned end locations will also *not* been shown
		if (!ride.locationStartLatitude || !ride.locationStartLongitude) continue;
		
		// Add annotation for start location to map
		[self.mainMapView addAnnotation:[RidePointAnnotation ridePointAnnotationWithRide:ride andRideLocationType:RideLocationType_Start]];
		
		// If no end-location coordinate, we are done with this ride
		if (!ride.locationEndLatitude || !ride.locationEndLongitude) continue;
		
		// Add annotation for end location to map
		[self.mainMapView addAnnotation:[RidePointAnnotation ridePointAnnotationWithRide:ride andRideLocationType:RideLocationType_End]];
	}
}


- (void)configureTeamsView {
	
	// If set of teams specified, show them; o/w show all
	self.showTeams = self.showTeams ?: self.teamFetchedResultsController.fetchedObjects;
	
	for (Team* team in self.showTeams) {
		
		// If no current-location coordinate, we are done with this team
		if (!team.locationCurrentLatitude || !team.locationCurrentLongitude) continue;
		
		// Add annotation for current location to map
		[self.mainMapView addAnnotation:[TeamPointAnnotation teamPointAnnotationWithTeam:team]];
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
		RidePointAnnotation* rideStartPointAnnotation = [RidePointAnnotation ridePointAnnotationWithRide:ride andRideLocationType:RideLocationType_Start];
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


- (void)clearAllAnnotationSelections {
	
	for (id<MKAnnotation> annotation in self.mainMapView.annotations) {
		
		[self.mainMapView deselectAnnotation:annotation animated:NO];
	}
}


+ (MKAnnotationView*)mapView:(MKMapView*)mapView viewForRidePointAnnotation:(RidePointAnnotation*)ridePointAnnotation {
	
	MKPinAnnotationView* ridePinAnnotationView = nil;
	
	switch (ridePointAnnotation.rideLocationType) {
			
		case RideLocationType_Start: {
			
			ridePinAnnotationView = (MKPinAnnotationView*)[MainMapViewController dequeueReusableAnnotationViewWithMapView:mapView andAnnotation:ridePointAnnotation andIdentifier:RIDE_START_ANNOTATION_ID];
			
			// Set pin color based on status
			// NOTE: Color for start of route is green by convention
			ridePinAnnotationView.pinColor = ridePointAnnotation.ride.teamAssigned ? MKPinAnnotationColorGreen : MKPinAnnotationColorPurple;
			
			// Add ride start time to left side of callout
			if (ridePointAnnotation.ride.dateTimeStart) {
				
				NSDateFormatter* startTimeDateFormatter = [[NSDateFormatter alloc] init];
				startTimeDateFormatter.dateFormat = MAP_ANNOTATION_TIME_FORMAT;
				UILabel* leftInfoView = [[UILabel alloc] initWithFrame:LEFT_CALLOUT_ACCESSORY_FRAME];
				leftInfoView.text = [startTimeDateFormatter stringFromDate:ridePointAnnotation.ride.dateTimeStart];
				leftInfoView.font = [UIFont fontWithDescriptor:leftInfoView.font.fontDescriptor size:[UIFont smallSystemFontSize]];
				leftInfoView.textAlignment = NSTextAlignmentCenter;
				ridePinAnnotationView.leftCalloutAccessoryView = leftInfoView;
			}
			
			break;
		}
			
		case RideLocationType_End: {
			
			ridePinAnnotationView = (MKPinAnnotationView*)[MainMapViewController dequeueReusableAnnotationViewWithMapView:mapView andAnnotation:ridePointAnnotation andIdentifier:RIDE_END_ANNOTATION_ID];
			
			// Set pin color
			// NOTE: Color for end of route is red by convention
			// TODO: Consider setting color based on status
			ridePinAnnotationView.pinColor = MKPinAnnotationColorRed;
			
			// Add ride end time to left side of callout
			NSLog(@"Check dataTimeEnd for annotation callout");
			if (ridePointAnnotation.ride.dateTimeEnd) {
				
				NSDateFormatter* endTimeDateFormatter = [[NSDateFormatter alloc] init];
				endTimeDateFormatter.dateFormat = MAP_ANNOTATION_TIME_FORMAT;
				UILabel* leftInfoView = [[UILabel alloc] initWithFrame:LEFT_CALLOUT_ACCESSORY_FRAME];
				leftInfoView.text = [endTimeDateFormatter stringFromDate:ridePointAnnotation.ride.dateTimeEnd];
				leftInfoView.font = [UIFont fontWithDescriptor:leftInfoView.font.fontDescriptor size:[UIFont smallSystemFontSize]];
				leftInfoView.textAlignment = NSTextAlignmentCenter;
				ridePinAnnotationView.leftCalloutAccessoryView = leftInfoView;
			}
			
			break;
		}
			
		default:
		case RideLocationType_None:
			return nil;
	}
	
	// Animate pin
	ridePinAnnotationView.animatesDrop = YES;
	
	// Add callout view to annotation
	ridePinAnnotationView.canShowCallout = YES;
	
	// Add disclosure button to right side of callout
	UIButton* rightDisclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[rightDisclosureButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
	ridePinAnnotationView.rightCalloutAccessoryView = rightDisclosureButton;
	
	return ridePinAnnotationView;
}


+ (MKAnnotationView*)mapView:(MKMapView*)mapView viewForTeamPointAnnotation:(TeamPointAnnotation*)teamPointAnnotation {
	
	MKAnnotationView* teamAnnotationView = nil;
	
	if (teamPointAnnotation.team.isMascot.boolValue) {
		
		teamAnnotationView = (MKAnnotationView*)[MainMapViewController dequeueReusableAnnotationViewWithMapView:mapView andAnnotation:teamPointAnnotation andIdentifier:TEAM_CURRENT_MASCOT_ANNOTATION_ID];
		
		teamAnnotationView.image = [UIImage imageNamed:@"ORN-Team-Mascot-Map-Annotation"];

	} else {
	
		teamAnnotationView = (MKAnnotationView*)[MainMapViewController dequeueReusableAnnotationViewWithMapView:mapView andAnnotation:teamPointAnnotation andIdentifier:TEAM_CURRENT_NORMAL_ANNOTATION_ID];
		
		teamAnnotationView.image = [UIImage imageNamed:@"ORN-Team-Map-Annotation"];
	}
	
	// Add callout view to annotation
	teamAnnotationView.canShowCallout = YES;
	
	// Add disclosure button to right side of callout
	UIButton* rightDisclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[rightDisclosureButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
	teamAnnotationView.rightCalloutAccessoryView = rightDisclosureButton;
	
	return teamAnnotationView;
}


+ (MKAnnotationView*)dequeueReusableAnnotationViewWithMapView:(MKMapView*)mapView andAnnotation:(id<MKAnnotation>)annotation andIdentifier:(NSString*)identifier {
	
	// Reuse pooled annotation if possible
	MKAnnotationView* annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (annotationView) {
		annotationView.annotation = annotation;
		return annotationView;
	}
	
	// No pooled annotation - create new one
	
	if ([identifier isEqualToString:RIDE_START_ANNOTATION_ID] ||
		[identifier isEqualToString:RIDE_END_ANNOTATION_ID])
		return [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];

	return [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
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


#
# pragma mark Command Handler
#


// Handle command string
// Returns whether command string was handled
- (BOOL)handleCommandString:(NSString*)commandString {
	
	commandString = [commandString lowercaseString];
	BOOL handled = NO;
	
	if ([COMMAND_HELP isEqualToString:commandString]) {
		
		[self presentAlertWithTitle:@"ORN Commands"
						 andMessage:[NSString stringWithFormat:
									 @"%@\n%@\n%@\n%@\n%@\n",
									 COMMAND_HELP,
									 COMMAND_DEMO,
									 COMMAND_DEMO_RIDES,
									 COMMAND_DEMO_TEAMS,
									 COMMAND_DEMO_ASSIGN
									 ]];
		handled = YES;
		
	} else if ([COMMAND_DEMO isEqualToString:commandString]) {
		
		// Run all demo commands
		[self handleCommandString:COMMAND_DEMO_RIDES];
		
		handled = YES;
		
	} else if ([COMMAND_DEMO_RIDES isEqualToString:commandString]) {
		
		// Load all demo rides
		[DemoUtil loadDemoRideDataModel:self.managedObjectContext];
		self.showRides = nil;
		self.rideFetchedResultsController = nil; // Trip refetch
		[self configureView];
		
		handled = YES;
		
	} else if ([COMMAND_DEMO_TEAMS isEqualToString:commandString]) {
		
		// Load all demo teams
		[DemoUtil loadDemoTeamDataModel:self.managedObjectContext];
		self.showTeams = nil;
		self.teamFetchedResultsController = nil; // Trip refetch
		[self configureView];
		
		handled = YES;
		
	} else if ([COMMAND_DEMO_ASSIGN isEqualToString:commandString]) {
		
		// Assign teams to rides
		
		handled = YES;
	}
	
	if (handled) {
		NSLog(@"Handled Command: %@", commandString);
	}
	
	return handled;
}


@end
