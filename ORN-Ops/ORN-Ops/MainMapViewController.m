//
//  MainMapViewController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-24.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

#import "MainMapViewController.h"
#import "AppDelegate.h"
#import "Ride+RideHelpers.h"
#import "Team+TeamHelpers.h"
#import "RidePointAnnotation.h"
#import "TeamPointAnnotation.h"
#import "RideStartEndPolyline.h"
#import "RideTeamAssignedPolyline.h"

#import "DemoUtil.h"


#
# pragma mark - Constants
#

#
# pragma mark Data Model Constants
#

#define RIDE_FETCH_SORT_KEY1		@"dateTimeStart"
#define RIDE_FETCH_SORT_KEY2		@"locationStartLongitude"
#define RIDE_FETCH_SORT_ASCENDING	YES

#define TEAM_FETCH_SORT_KEY1		@"name"
#define TEAM_FETCH_SORT_KEY2		@"members"
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
#define COMMAND_SHOW_ALL		@"ornshowall"
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

@property (nonatomic) NSDateFormatter* annotationDateFormatter;

@property (nonatomic) UIColor* calloutAccessoryColorGreen;

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
	fetchRequest.sortDescriptors =
	@[
	  [NSSortDescriptor sortDescriptorWithKey:RIDE_FETCH_SORT_KEY1 ascending:RIDE_FETCH_SORT_ASCENDING],
	  [NSSortDescriptor sortDescriptorWithKey:RIDE_FETCH_SORT_KEY2 ascending:RIDE_FETCH_SORT_ASCENDING]
	  ];
	//fetchRequest.predicate = [NSPredicate predicateWithFormat:@"movie.id == %@", self.movie.id];
	//fetchRequest.fetchBatchSize = PAGE_LIMIT;
	//fetchRequest.fetchLimit = PAGE_LIMIT;
	
	// NOTE: nil for section name key path means "no sections"
	_rideFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[Util managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
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
	fetchRequest.sortDescriptors =
	@[
	  [NSSortDescriptor sortDescriptorWithKey:TEAM_FETCH_SORT_KEY1 ascending:TEAM_FETCH_SORT_ASCENDING],
	  [NSSortDescriptor sortDescriptorWithKey:TEAM_FETCH_SORT_KEY2 ascending:TEAM_FETCH_SORT_ASCENDING]
	  ];
	//fetchRequest.predicate = [NSPredicate predicateWithFormat:@"movie.id == %@", self.movie.id];
	//fetchRequest.fetchBatchSize = PAGE_LIMIT;
	//fetchRequest.fetchLimit = PAGE_LIMIT;
	
	// NOTE: nil for section name key path means "no sections"
	_teamFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[Util managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
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


- (NSDateFormatter*)annotationDateFormatter {

	if (_annotationDateFormatter) return _annotationDateFormatter;
	
	_annotationDateFormatter = [[NSDateFormatter alloc] init];
	_annotationDateFormatter.dateFormat = MAP_ANNOTATION_DATETIME_FORMAT;

	return _annotationDateFormatter;
}


- (UIColor*)calloutAccessoryColorGreen {

	if (_calloutAccessoryColorGreen) return _calloutAccessoryColorGreen;
	
	_calloutAccessoryColorGreen = [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.8 alpha:1];
	
	return _calloutAccessoryColorGreen;
}


#
# pragma mark UIViewController
#


- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// Configure avatar in navigation item
	// NOTE: Must be done in code - otherwise we just get a template
	self.avatarBarButtonItem.image = [[UIImage imageNamed:@"ORN-Bar-Button-Item"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	
	[Util preloadKeyboardViaTextField:self.addressTextField];
	
	[self addNotificationObservers];
	
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


// User tapped keyboard return button
// NOTE: Text field is *not* empty due to "auto-enable" of return key
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	
	// Remove focus and keyboard
	[textField resignFirstResponder];
	
#ifdef ENABLE_COMMANDS
	
	// If command present, handle it and we are done
	if ([self handleCommandString:textField.text]) {
		
		textField.text = @"";
		
		return NO; // Do not perform default text-field behaviour
	}
	
#endif
	
	// Trigger action handler for return button
	[self addressTextFieldReturnButtonPressed:textField];
	
	return NO; // Do not perform default text-field behaviour
}


#
# pragma mark <MKMapViewDelegate>
#


/*
 - (void)mapView:(MKMapView*)mapView regionDidChangeAnimated:(BOOL)animated {
 
	// NOTE: Called many times during scrolling, so keep code lightweight
 }
 */


/*
 - (void)mapView:(MKMapView*)mapView didUpdateUserLocation:(MKUserLocation*)userLocation {
 
 }
 */


- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	
	if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
	
	if ([annotation isKindOfClass:[RidePointAnnotation class]]) return [self mapView:mapView viewForRidePointAnnotation:(RidePointAnnotation*)annotation];
	
	if ([annotation isKindOfClass:[TeamPointAnnotation class]]) return [self mapView:mapView viewForTeamPointAnnotation:(TeamPointAnnotation*)annotation];
	
	return nil;
}


- (void)mapView:(MKMapView*)mapView didAddAnnotationViews:(NSArray*)views {
	
	// Animate dropping for team point annotations
	
	for (int i = 0; i < views.count; i++) {
		
		MKAnnotationView* view = views[i];
		
		// If not team annotation, we are done with this view
		if (![view.annotation isKindOfClass:[TeamPointAnnotation class]]) continue;
		
		// If team annotation does not need animating, we are done with this view
		TeamPointAnnotation* teamPointAnnotation = (TeamPointAnnotation*)view.annotation;
		if (!teamPointAnnotation.needsAnimatesDrop) continue;
		
		// Animation for team annotation has been triggered, so reset trigger
		teamPointAnnotation.needsAnimatesDrop = NO;
		
		// If annotation is not inside visible map rect, we are done with this view
		MKMapPoint point =  MKMapPointForCoordinate(view.annotation.coordinate);
		if (!MKMapRectContainsPoint(mapView.visibleMapRect, point)) continue;

		// Animate dropping view
		[Util animateDropView:view withDropHeight:self.view.frame.size.height withDuration:0.25 withDelay:(0.04 * i)];
	}
}


- (void)mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)view calloutAccessoryControlTapped:(UIControl*)control {
	
	[self.addressTextField resignFirstResponder];
	
	// If user location, we are done
	if ([view.annotation isKindOfClass:[MKUserLocation class]]) return;
	
	// If ride, navigate to ride detail controller
	if ([view.annotation isKindOfClass:[RidePointAnnotation class]]) {
		
		MKPinAnnotationView* pinAnnotationView = (MKPinAnnotationView*)view;
		
		// Create ride detail controller
		RideDetailTableViewController* rideDetailTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:RIDE_DETAIL_TABLE_VIEW_CONTROLLER_ID];
		
		// Inject ride data model
		RidePointAnnotation* ridePointAnnotation = (RidePointAnnotation*)pinAnnotationView.annotation;
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
		TeamPointAnnotation* teamPointAnnotation = (TeamPointAnnotation*)view.annotation;
		teamDetailTableViewController.team = teamPointAnnotation.team;
		
		// Push onto navigation stack
		[self.navigationController pushViewController:teamDetailTableViewController animated:YES];
		
		return;
	}
}


- (void)mapView:(MKMapView*)mapView didSelectAnnotationView:(MKAnnotationView*)view {

	if ([view.annotation isKindOfClass:[MKUserLocation class]]) return;

	if ([view.annotation isKindOfClass:[RidePointAnnotation class]]) {
		
		Ride* ride = ((RidePointAnnotation*)view.annotation).ride;
		[ride postNotificationUpdatedWithSender:self];
		NSLog(@"Rides[%d] selected: %@", (int)[self.rideFetchedResultsController.fetchedObjects indexOfObject:ride], ride);
		return;
	}
	
	if ([view.annotation isKindOfClass:[TeamPointAnnotation class]]) {
		
		Team* team = ((TeamPointAnnotation*)view.annotation).team;
		
		for (Ride* ride in team.ridesAssigned) {
		
			[ride postNotificationUpdatedWithSender:self];
		}
		NSLog(@"Teams[%d] selected: %@", (int)[self.teamFetchedResultsController.fetchedObjects indexOfObject:team], team);
		return;
	}
}


- (void)mapView:(MKMapView*)mapView didDeselectAnnotationView:(MKAnnotationView*)view {
	
	if ([view.annotation isKindOfClass:[MKUserLocation class]]) return;
	
	if ([view.annotation isKindOfClass:[RidePointAnnotation class]]) {
		
		Ride* ride = ((RidePointAnnotation*)view.annotation).ride;
		[ride postNotificationUpdatedWithSender:self];
		return;
	}

	if ([view.annotation isKindOfClass:[TeamPointAnnotation class]]) {
		
		Team* team = ((TeamPointAnnotation*)view.annotation).team;
		
		for (Ride* ride in team.ridesAssigned) {
			
			[ride postNotificationUpdatedWithSender:self];
		}
		return;
	}
}


- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id<MKOverlay>)overlay {
	
	// For ride and team selection overlays, use blue lines
	MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
	renderer.strokeColor = [UIColor blueColor];
	renderer.alpha = 0.5;
	
	// For overlay between ride start and end, use solid line
	if ([overlay isKindOfClass:[RideStartEndPolyline class]]) {
		
		renderer.lineWidth = 5.0;
		return renderer;
	}

	// For overlay between team and ride, use thinner, dotted line
	if ([overlay isKindOfClass:[RideTeamAssignedPolyline class]]) {
		
		renderer.lineWidth = 3.0;
		renderer.lineDashPattern = @[@3, @5];
		//	renderer.lineDashPhase = 6;
		return renderer;
	}
	
	return nil;
}


#
# pragma mark <MKMapViewDelegate> Helpers
#


- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForRidePointAnnotation:(RidePointAnnotation*)ridePointAnnotation {
	
	MKPinAnnotationView* ridePinAnnotationView = (MKPinAnnotationView*)[MainMapViewController dequeueReusableAnnotationViewWithMapView:mapView andAnnotation:ridePointAnnotation andIdentifier:ridePointAnnotation.rideLocationType == RideLocationType_End ? RIDE_END_ANNOTATION_ID : RIDE_START_ANNOTATION_ID];
	
	[self configureRidePinAnnotationView:ridePinAnnotationView withRidePointAnnotation:ridePointAnnotation];
	
	return ridePinAnnotationView;
}


- (MKPinAnnotationView*)configureRidePinAnnotationView:(MKPinAnnotationView*)ridePinAnnotationView withRidePointAnnotation:(RidePointAnnotation*)ridePointAnnotation {
	
	Ride* ride = ridePointAnnotation.ride;
	
	// Animate annotation if triggered, and reset trigger
	ridePinAnnotationView.animatesDrop = ridePointAnnotation.needsAnimatesDrop;
	ridePointAnnotation.needsAnimatesDrop = NO;
	
	// Set pin color based on status
	// NOTE: By convention, color for route start is green, and end is red.  If no team assigned, start is purple.
	ridePinAnnotationView.pinColor = ridePointAnnotation.rideLocationType == RideLocationType_End ? MKPinAnnotationColorRed : (ride.teamAssigned ? MKPinAnnotationColorGreen : MKPinAnnotationColorPurple);
	
	// Add/update/remove left callout accessory
	// NOTE: Do not set for update, to avoid re-animation
	if (!ridePinAnnotationView.leftCalloutAccessoryView) {
		
		ridePinAnnotationView.leftCalloutAccessoryView = [MainMapViewController leftCalloutAccessoryLabel];
	}
	if (![self configureLeftCalloutAccessoryLabel:(UILabel*)ridePinAnnotationView.leftCalloutAccessoryView withRidePointAnnotation:ridePointAnnotation]) {
		
		ridePinAnnotationView.leftCalloutAccessoryView = nil;
	}
	
	return ridePinAnnotationView;
}


- (UILabel*)configureLeftCalloutAccessoryLabel:(UILabel*)leftCalloutAccessoryLabel withRidePointAnnotation:(RidePointAnnotation*)ridePointAnnotation {
	
	Ride* ride = ridePointAnnotation.ride;
	
	// If time present, add to label with appropriate background color
	
	switch (ridePointAnnotation.rideLocationType) {
			
		case RideLocationType_Start: {
			
			if (!ride.dateTimeStart) return nil;
			
			leftCalloutAccessoryLabel.text = [self.annotationDateFormatter stringFromDate:ride.dateTimeStart];
			
			leftCalloutAccessoryLabel.backgroundColor = ride.teamAssigned ? self.calloutAccessoryColorGreen : [UIColor purpleColor];
			
			break;
		}
			
		case RideLocationType_End: {
			
			NSDate* routeDateTimeEnd = ride.getRouteDateTimeEnd;
			if (!routeDateTimeEnd) return nil;
			
			leftCalloutAccessoryLabel.text = [self.annotationDateFormatter stringFromDate:routeDateTimeEnd];
			
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
	
	MKAnnotationView* teamAnnotationView = (MKAnnotationView*)[MainMapViewController dequeueReusableAnnotationViewWithMapView:mapView andAnnotation:teamPointAnnotation andIdentifier:teamPointAnnotation.team.isMascot.boolValue ? TEAM_MASCOT_ANNOTATION_ID : TEAM_NORMAL_ANNOTATION_ID];
	
	[self configureTeamAnnotationView:teamAnnotationView withTeamPointAnnotation:teamPointAnnotation];
	
	return teamAnnotationView;
}


- (MKAnnotationView*)configureTeamAnnotationView:(MKAnnotationView*)teamAnnotationView withTeamPointAnnotation:(TeamPointAnnotation*)teamPointAnnotation {
	
	// Team* team = teamPointAnnotation.team;
	
	// NOTE: Animation of team annotation is done manually in "mapView:didAddAnnotationViews:"
	
	// Add/update/remove left callout accessory
	// NOTE: Do not set for update, to avoid re-animation
	if (!teamAnnotationView.leftCalloutAccessoryView) {
		
		teamAnnotationView.leftCalloutAccessoryView = [MainMapViewController leftCalloutAccessoryLabel];
	}
	if (![self configureLeftCalloutAccessoryLabel:(UILabel*)teamAnnotationView.leftCalloutAccessoryView withTeamPointAnnotation:teamPointAnnotation]) {
		
		teamAnnotationView.leftCalloutAccessoryView = nil;
	}
	
	return teamAnnotationView;
}


- (UILabel*)configureLeftCalloutAccessoryLabel:(UILabel*)leftCalloutAccessoryLabel withTeamPointAnnotation:(TeamPointAnnotation*)teamPointAnnotation {
	
	Team* team = teamPointAnnotation.team;
	
	// If team assigned to rides, add total busy duration to label
	
	if (!team.ridesAssigned || team.ridesAssigned.count == 0) return nil;
	
	double busyDuration = 0; // seconds
	for (Ride* rideAssigned in team.ridesAssigned) {
		
		busyDuration += rideAssigned.routeDuration.doubleValue;
	}
	leftCalloutAccessoryLabel.text = [NSString stringWithFormat:MAP_ANNOTATION_DURATION_FORMAT, busyDuration / (double)SECONDS_PER_MINUTE];
	
	leftCalloutAccessoryLabel.backgroundColor = [UIColor blueColor];
	
	return leftCalloutAccessoryLabel;
}


+ (MKAnnotationView*)dequeueReusableAnnotationViewWithMapView:(MKMapView*)mapView andAnnotation:(id<MKAnnotation>)annotation andIdentifier:(NSString*)identifier {
	
	// Reuse pooled annotation if possible
	MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (annotationView) {
		
		annotationView.annotation = annotation;
		annotationView.leftCalloutAccessoryView = nil;
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


+ (UILabel*)leftCalloutAccessoryLabel {
	
	UILabel* leftCalloutAccessoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 53)];
	leftCalloutAccessoryLabel.font = [UIFont boldSystemFontOfSize:16.0];
	leftCalloutAccessoryLabel.textAlignment = NSTextAlignmentCenter;
	leftCalloutAccessoryLabel.textColor = [UIColor whiteColor];
	leftCalloutAccessoryLabel.alpha = 0.5;
	
	return leftCalloutAccessoryLabel;
}


#
# pragma mark Action Handlers
#


- (IBAction)avatarBarButtonPressed:(UIBarButtonItem*)sender {
	
	[self configureJurisdictionRegionViewWithAnimated:YES];
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


- (IBAction)addressTextFieldReturnButtonPressed:(UITextField*)sender {
	// NOTE: Cannot wire to keyboard button, so called directly via text-field delegate
	
	[Ride tryCreateRideWithAddressString:sender.text andGeocoder:self.geocoder andSender:self];
}


#
# pragma mark Ride Notification Handlers
#


- (void)rideCreatedWithNotification:(NSNotification*)notification {

	BOOL createdFromMapView = (notification.object == self);
	
	BOOL annotationShown = [self configureRideAnnotationsWithNotification:notification andNeedsCenter:createdFromMapView andNeedsSelection:createdFromMapView];
	
	if (!createdFromMapView) return;
		
	self.addressTextField.text = @"";
	
	if (annotationShown) return;
		
	[Util presentOKAlertWithTitle:@"Alert" andMessage:@"Ride created but no start or end location annotations to show."];
}


- (void)rideUpdatedWithNotification:(NSNotification*)notification {
	
	[self configureRideAnnotationsWithNotification:notification andNeedsCenter:NO andNeedsSelection:NO];
	[self configureRideOverlaysWithNotification:notification];
}


#
# pragma mark Ride Notification Handler Helpers
#


/*
 Configure ride annotations and their views, consistent with given ride notification
 Returns whether at least one annotation is present
 */
- (BOOL)configureRideAnnotationsWithNotification:(NSNotification*)notification
								  andNeedsCenter:(BOOL)needsCenter
							   andNeedsSelection:(BOOL)needsSelection {
	
	Ride* ride = [Ride rideFromNotification:notification];
	NSArray* rideAnnotations = [self annotationsForRide:ride];
	
	// Configure start annotation
	BOOL isLocationUpdated = [Ride isUpdatedLocationStartFromNotification:notification];
	BOOL startAnnotationPresent = [self configureViewWithRide:ride
										  andRideLocationType:RideLocationType_Start
										 usingRideAnnotations:rideAnnotations
										 andIsLocationUpdated:isLocationUpdated
											   andNeedsCenter:needsCenter
											andNeedsSelection:needsSelection];
	
	// Configure end annotation
	// NOTE: Start annotation takes precedence for center and selection
	isLocationUpdated = [Ride isUpdatedLocationEndFromNotification:notification];
	BOOL endAnnotationPresent = [self configureViewWithRide:ride
										andRideLocationType:RideLocationType_End
									   usingRideAnnotations:rideAnnotations
									   andIsLocationUpdated:isLocationUpdated
											 andNeedsCenter:(needsCenter && !startAnnotationPresent)
										  andNeedsSelection:(needsSelection && !startAnnotationPresent)];
	
	return startAnnotationPresent || endAnnotationPresent;
}


/*
 Configure ride annotation and its view, consistent with given ride
 Returns whether annotation is present
 */
- (BOOL)configureViewWithRide:(Ride*)ride
		  andRideLocationType:(RideLocationType)rideLocationType
		 usingRideAnnotations:(NSArray*)rideAnnotations
		 andIsLocationUpdated:(BOOL)isLocationUpdated
			   andNeedsCenter:(BOOL)needsCenter
			andNeedsSelection:(BOOL)needsSelection {
	
	RidePointAnnotation* ridePointAnnotation = [MainMapViewController getRidePointAnnotationFromRidePointAnnotations:rideAnnotations andRideLocationType:rideLocationType];
	
	NSNumber* locationLatitude = ride.locationStartLatitude;
	NSNumber* locationLongitude = ride.locationStartLongitude;
	if (rideLocationType == RideLocationType_End) {
		
		locationLatitude = ride.locationEndLatitude;
		locationLongitude = ride.locationEndLongitude;
	}
	
	if (locationLatitude && locationLongitude) {
		
		// Updated existing annotation or create new one
		if (ridePointAnnotation) {
			
			(void)[ridePointAnnotation initWithRide:ride andRideLocationType:rideLocationType andNeedsAnimatesDrop:isLocationUpdated];
			
		} else {
			
			ridePointAnnotation = [RidePointAnnotation ridePointAnnotationWithRide:ride andRideLocationType:rideLocationType andNeedsAnimatesDrop:isLocationUpdated];
			
			[self.mainMapView addAnnotation:ridePointAnnotation];
		}
		
		// Update existing annotation view or trigger new one
		if (isLocationUpdated) {
			
			// Remove and re-add annotation to map view - automatically triggers new annotation view
			[self.mainMapView removeAnnotation:ridePointAnnotation];
			[self.mainMapView addAnnotation:ridePointAnnotation];
			
		} else {
			
			// If view exists for given annotation, update it
			MKPinAnnotationView* ridePinAnnotationView = (MKPinAnnotationView*)[self.mainMapView viewForAnnotation:ridePointAnnotation];
			if (ridePinAnnotationView) {
				
				[self configureRidePinAnnotationView:ridePinAnnotationView withRidePointAnnotation:ridePointAnnotation];
			}
		}
		
		if (needsCenter) {
			
			[self.mainMapView setCenterCoordinate:CLLocationCoordinate2DMake(locationLatitude.doubleValue, locationLongitude.doubleValue) animated:YES];
		}
		
		if (needsSelection) {
			
			[self.mainMapView selectAnnotation:ridePointAnnotation animated:YES];
		}
		
	} else {
		
		// Remove existing annotation, if present
		if (ridePointAnnotation) {
			
			[self.mainMapView removeAnnotation:ridePointAnnotation];
			ridePointAnnotation = nil;
		}
	}
	
	return (ridePointAnnotation != nil);
}


- (void)configureRideOverlaysWithNotification:(NSNotification*)notification {

	[self configureRideStartEndOverlaysWithNotification:notification];
	[self configureRideTeamAssignedOverlaysWithNotification:notification];
}


- (void)configureRideStartEndOverlaysWithNotification:(NSNotification*)notification {

//	Ride* ride = [Ride rideFromNotification:notification];

}


/*
 Configure ride-team assigned overlay, consistent with given ride notification
 */
- (void)configureRideTeamAssignedOverlaysWithNotification:(NSNotification*)notification {

	// Remove ride-team assigned overlay, if present
	Ride* ride = [Ride rideFromNotification:notification];
	RideTeamAssignedPolyline* rideTeamAssignedPolyline = [MainMapViewController getRideTeamAssignedPolylineFromRideOverlays:[self overlaysForRide:ride]];
	[self.mainMapView removeOverlay:rideTeamAssignedPolyline];
	
	// If neither ride nor team assigned is selected, we are done
	if (![self isSelectedAnnotationForRide:ride] && ![self isSelectedAnnotationForTeam:ride.teamAssigned]) return;
	
	// If no ride-team assigned or insufficient location data, we are done
	if (!ride.teamAssigned ||
		!ride.teamAssigned.locationCurrentLatitude ||
		!ride.teamAssigned.locationCurrentLongitude ||
		!ride.locationStartLatitude ||
		!ride.locationStartLongitude
		) return;
	
	// Get coordinate of ride start
	CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(ride.locationStartLatitude.doubleValue, ride.locationStartLongitude.doubleValue);

	// Update existing overlay or create new one
	rideTeamAssignedPolyline = rideTeamAssignedPolyline
	? [rideTeamAssignedPolyline initWithRide:ride andStartCoordinate:&startCoordinate]
	: [RideTeamAssignedPolyline rideTeamAssignedPolylineWithRide:ride andStartCoordinate:&startCoordinate];

	// Add ride-team assigned overlay to map view
	[self.mainMapView addOverlay:rideTeamAssignedPolyline level:MKOverlayLevelAboveLabels];
}


- (NSArray*)annotationsForRide:(Ride*)ride {
	
	return [self.mainMapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
		
		return [evaluatedObject conformsToProtocol:@protocol(RideModelSource)] && ((id<RideModelSource>)evaluatedObject).ride == ride;
	}]];
}


+ (RidePointAnnotation*)getRidePointAnnotationFromRidePointAnnotations:(NSArray*)annotations andRideLocationType:(RideLocationType)rideLocationType {
	
	// Return first annotation found of given ride location type
	// NOTE: Should be max 1
	for (RidePointAnnotation* ridePointAnnotation in annotations) {
		
		if (ridePointAnnotation.rideLocationType == rideLocationType) return ridePointAnnotation;
	}
	
	return nil;
}


- (BOOL)isSelectedAnnotationForRide:(Ride*)ride {
	
	if (!ride) return NO;
	
	// NOTE: In current MapKit, only one annotation can be selected at a time
	MKPointAnnotation* selectedAnnotation = self.mainMapView.selectedAnnotations.firstObject;
	
	return [selectedAnnotation conformsToProtocol:@protocol(RideModelSource)] && ((id<RideModelSource>)selectedAnnotation).ride == ride;
}


- (NSArray*)overlaysForRide:(Ride*)ride {
	
	return [self.mainMapView.overlays filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
		
		return [evaluatedObject conformsToProtocol:@protocol(RideModelSource)] && ((id<RideModelSource>)evaluatedObject).ride == ride;
	}]];
}


+ (RideStartEndPolyline*)getRideStartEndPolylineFromRideOverlays:(NSArray*)overlays {
	
	// Return first overlay found of ride start-end polyline class
	// NOTE: Should be max 1
	for (id<MKOverlay> overlay in overlays) {
		
		if ([overlay isKindOfClass:[RideStartEndPolyline class]]) return (RideStartEndPolyline*)overlay;
	}
	
	return nil;
}


+ (RideTeamAssignedPolyline*)getRideTeamAssignedPolylineFromRideOverlays:(NSArray*)overlays {
	
	// Return first overlay found of ride-team assigned polyline class
	// NOTE: Should be max 1
	for (id<MKOverlay> overlay in overlays) {
		
		if ([overlay isKindOfClass:[RideTeamAssignedPolyline class]]) return (RideTeamAssignedPolyline*)overlay;
	}
	
	return nil;
}


#
# pragma mark Team Notification Handlers
#


- (void)teamCreatedWithNotification:(NSNotification*)notification {

	[self configureTeamAnnotationsWithNotification:notification andNeedsCenter:NO andNeedsSelection:NO];
}


- (void)teamUpdatedWithNotification:(NSNotification*)notification {
	
	[self configureTeamAnnotationsWithNotification:notification andNeedsCenter:NO andNeedsSelection:NO];
	// NOTE: Overlays for teams are handled by assigned rides
}


#
# pragma mark Team Notification Handler Helpers
#


/*
 Configure team annotations and their views, consistent with given team notification
 Returns whether at least one annotation is present
 */
- (BOOL)configureTeamAnnotationsWithNotification:(NSNotification*)notification
								  andNeedsCenter:(BOOL)needsCenter
							   andNeedsSelection:(BOOL)needsSelection {
	
	Team* team = [Team teamFromNotification:notification];
	NSArray* teamAnnotations = [self annotationsForTeam:team];
	
	// Configure annotation
	BOOL isLocationUpdated = [Team isUpdatedLocationFromNotification:notification];
	BOOL annotationPresent = [self configureViewWithTeam:team
									usingTeamAnnotations:teamAnnotations
									andIsLocationUpdated:isLocationUpdated
										  andNeedsCenter:needsCenter
									   andNeedsSelection:needsSelection];
	
	return annotationPresent;
}


/*
 Configure team annotation and its view, consistent with given team
 Returns whether annotation is present
 */
- (BOOL)configureViewWithTeam:(Team*)team
		 usingTeamAnnotations:(NSArray*)teamAnnotations
		 andIsLocationUpdated:(BOOL)isLocationUpdated
			   andNeedsCenter:(BOOL)needsCenter
			andNeedsSelection:(BOOL)needsSelection {
	
	TeamPointAnnotation* teamPointAnnotation = [MainMapViewController getTeamPointAnnotationFromTeamPointAnnotations:teamAnnotations];
	
	NSNumber* locationLatitude = team.locationCurrentLatitude;
	NSNumber* locationLongitude = team.locationCurrentLongitude;
	
	if (locationLatitude && locationLongitude) {
		
		// Updated existing annotation or create new one
		if (teamPointAnnotation) {
			
			(void)[teamPointAnnotation initWithTeam:team andNeedsAnimatesDrop:isLocationUpdated];
			
		} else {
			
			teamPointAnnotation = [TeamPointAnnotation teamPointAnnotationWithTeam:team andNeedsAnimatesDrop:isLocationUpdated];
			
			[self.mainMapView addAnnotation:teamPointAnnotation];
		}
		
		// Update existing annotation view or trigger new one
		if (isLocationUpdated) {
			
			// Remove and re-add annotation to map view - automatically triggers new annotation view
			[self.mainMapView removeAnnotation:teamPointAnnotation];
			[self.mainMapView addAnnotation:teamPointAnnotation];
			
		} else {
			
			// If view exists for given annotation, update it
			MKAnnotationView* teamAnnotationView = [self.mainMapView viewForAnnotation:teamPointAnnotation];
			if (teamAnnotationView) {
				
				[self configureTeamAnnotationView:teamAnnotationView withTeamPointAnnotation:teamPointAnnotation];
			}
		}
		
		if (needsCenter) {
			
			[self.mainMapView setCenterCoordinate:CLLocationCoordinate2DMake(locationLatitude.doubleValue, locationLongitude.doubleValue) animated:YES];
		}
		
		if (needsSelection) {
			
			[self.mainMapView selectAnnotation:teamPointAnnotation animated:YES];
		}
		
	} else {
		
		if (teamPointAnnotation) {
			
			[self.mainMapView removeAnnotation:teamPointAnnotation];
			teamPointAnnotation = nil;
		}
	}
	
	return (teamPointAnnotation != nil);
}


- (NSArray*)annotationsForTeam:(Team*)team {
	
	return [self.mainMapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
		
		return [evaluatedObject conformsToProtocol:@protocol(TeamModelSource)] && ((id<TeamModelSource>)evaluatedObject).team == team;
	}]];
}


+ (TeamPointAnnotation*)getTeamPointAnnotationFromTeamPointAnnotations:(NSArray*)annotations {
	
	// Return first annotation found
	// NOTE: Should be max 1
	return annotations.firstObject;
}


- (BOOL)isSelectedAnnotationForTeam:(Team*)team {
	
	if (!team) return NO;
	
	MKPointAnnotation* selectedAnnotation = self.mainMapView.selectedAnnotations.firstObject;
	
	return [selectedAnnotation conformsToProtocol:@protocol(TeamModelSource)] && ((id<TeamModelSource>)selectedAnnotation).team == team;
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
		
		[Util presentOKAlertWithTitle:@"ORN Commands"
						   andMessage:[NSString stringWithFormat:
									   @"%@\n%@\n%@\n%@\n%@\n%@\n%@",
									   COMMAND_HELP,
									   COMMAND_SHOW_ALL,
									   COMMAND_DELETE_ALL,
									   COMMAND_DEMO,
									   COMMAND_DEMO_RIDES,
									   COMMAND_DEMO_TEAMS,
									   COMMAND_DEMO_ASSIGN
									   ]];
		isCommandHandled = YES;
		
	} else if ([COMMAND_SHOW_ALL isEqualToString:commandString]) {
		
		[self showAllAnnotations];
		
		isCommandHandled = YES;
		
	} else if ([COMMAND_DELETE_ALL isEqualToString:commandString]) {
		
		UIAlertAction* deleteAllAlertAction = [UIAlertAction actionWithTitle:@"Delete All" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			
			// Delete all rides and teams
			// TODO: Intead, just ask AppDelegate to delete and recreate the backing DB file
			AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
			[appDelegate deleteAllObjectsWithEntityName:RIDE_ENTITY_NAME];
			[appDelegate deleteAllObjectsWithEntityName:TEAM_ENTITY_NAME];
			
			// Reset map
			[self clearAllAnnotations];
			[self configureJurisdictionRegionViewWithAnimated:NO];
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
		[self configureJurisdictionRegionView];
		[DemoUtil loadDemoRides];
		
		needsDataModelSave = YES;
		isCommandHandled = YES;
		
	} else if ([COMMAND_DEMO_TEAMS isEqualToString:commandString]) {
		
		// Load all demo teams
		[self configureJurisdictionRegionView];
		[DemoUtil loadDemoTeams];

		needsDataModelSave = YES;
		isCommandHandled = YES;
		
	} else if ([COMMAND_DEMO_ASSIGN isEqualToString:commandString]) {
		
		// Assign teams to rides
		[DemoUtil loadDemoAssignTeams:self.teamFetchedResultsController.fetchedObjects toRides:self.rideFetchedResultsController.fetchedObjects];
		
		needsDataModelSave = YES;
		isCommandHandled = YES;
	}
	
	if (isCommandHandled) {
		NSLog(@"Handled Command: %@", commandString);
		
		if (needsDataModelSave) {
			
			[Util saveManagedObjectContext];
		}
	}
	
	return isCommandHandled;
}


#
# pragma mark Helpers
#


- (void)addNotificationObservers {
	
	[Ride addCreatedObserver:self withSelector:@selector(rideCreatedWithNotification:)];
	[Ride addUpdatedObserver:self withSelector:@selector(rideUpdatedWithNotification:)];

	[Team addCreatedObserver:self withSelector:@selector(teamCreatedWithNotification:)];
	[Team addUpdatedObserver:self withSelector:@selector(teamUpdatedWithNotification:)];
}


- (void)configureView {
	
	// Zoom map to jurisdiction region and load persisted data model
	// NOTE: Delay to wait for orientation to be established
	[self performSelector:@selector(configureJurisdictionRegionView) withObject:nil afterDelay:1.0];
	[self performSelector:@selector(loadDataModel) withObject:nil afterDelay:2.5];
}


- (void)loadDataModel {
	
	[self loadRidesDataModel];
	[self loadTeamsDataModel];
}


- (void)loadRidesDataModel {
	
	for (Ride* ride in self.rideFetchedResultsController.fetchedObjects) {
		
		[ride postNotificationUpdatedWithSender:self andUpdatedLocationStart:YES andUpdatedLocationEnd:YES];
	}
}


- (void)loadTeamsDataModel {
	
	for (Team* team in self.teamFetchedResultsController.fetchedObjects) {
		
		[team postNotificationUpdatedWithSender:self andUpdatedLocation:YES];
	}
}


- (void)configureJurisdictionRegionViewWithAnimated:(BOOL)animated {
	
	MKCoordinateRegion centerRegion = MKCoordinateRegionMake(JURISDICTION_COORDINATE, MKCoordinateSpanMake(MAP_SPAN_LOCATION_DELTA_CITY, MAP_SPAN_LOCATION_DELTA_CITY));
	
	[self.mainMapView setRegion:centerRegion animated:animated];
}


- (void)configureJurisdictionRegionView {
	
	[self configureJurisdictionRegionViewWithAnimated:YES];
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


@end
