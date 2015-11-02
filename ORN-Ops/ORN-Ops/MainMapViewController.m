//
//  MainMapViewController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-24.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import "MainMapViewController.h"
#import "Ride+RideHelpers.h"
#import "Team+TeamHelpers.h"
#import "RidePointAnnotation.h"
#import "TeamPointAnnotation.h"
#import "TeamAnnotationView.h"
#import "RidePolyline.h"

#import "DemoUtil.h"


#
# pragma mark - Constants
#

#
# pragma mark Map Constants
#

#define RIDE_START_ANNOTATION_ID	@"rideStartAnnotation"
#define RIDE_END_ANNOTATION_ID		@"rideEndAnnotation"
#define RIDE_POLYLINE_ANNOTATION_ID	@"ridePolylineAnnotation"

#define TEAM_NORMAL_ANNOTATION_ID	@"teamNormalAnnotation"
#define TEAM_MASCOT_ANNOTATION_ID	@"teamMascotAnnotation"

#define MAP_ANNOTATION_DATETIME_FORMAT	@"HH:mm"
#define MAP_ANNOTATION_DURATION_FORMAT	@"%.0f min"
#define MAP_ANNOTATION_DISTANCE_FORMAT	@"%.1f km"
#define MAP_ANNOTATION_FIELD_EMPTY		@"?"

#define DISPATCH_DATETIME_FORMAT		@"HH:mm"

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
# pragma mark Enums
#


typedef NS_ENUM(NSInteger, PolylineMode) {

	PolylineMode_None = 	0,
	
	PolylineMode_Connect =	1,
	PolylineMode_Route =	2,
};


typedef NS_OPTIONS(NSUInteger, ConfigureOptions) {
	
	Configure_None =		0,
	
	Configure_Center =	1 << 0,
	Configure_Select =	1 << 1,
	Configure_Delete =	1 << 2,
};


#
# pragma mark - Interface
#

@interface MainMapViewController () <MFMessageComposeViewControllerDelegate>

#
# pragma mark Properties
#

@property (strong, nonatomic) NSFetchedResultsController* ridesFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController* teamsFetchedResultsController;

@property (nonatomic) PolylineMode polylineMode;
@property (nonatomic) CLGeocoder* geocoder;
@property (nonatomic) NSDateFormatter* annotationDateFormatter;
@property (nonatomic) NSDateFormatter* dispatchDateFormatter;
@property (nonatomic) UIColor* calloutAccessoryColorGreen;

@property (weak, nonatomic) id<MKAnnotation> rideTeamPanAssignmentAnchorAnnotation;
@property (weak, nonatomic) id<MKAnnotation> previousSelectedAnnotation;

@property (weak, nonatomic) UIAlertController* actionSheetController;
@property (weak, nonatomic) RideDetailTableViewController* rideDetailTableViewController;
@property (weak, nonatomic) TeamDetailTableViewController* teamDetailTableViewController;

@end


#
# pragma mark - Implementation
#


@implementation MainMapViewController


#
# pragma mark Property Accessors
#


- (NSFetchedResultsController*)rideFetchedResultsController {
	
	if (_ridesFetchedResultsController) return _ridesFetchedResultsController;
	
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:RIDE_ENTITY_NAME];
	fetchRequest.sortDescriptors =
	@[
	  [NSSortDescriptor sortDescriptorWithKey:RIDE_FETCH_SORT_KEY1 ascending:RIDE_FETCH_SORT_ASC1],
	  [NSSortDescriptor sortDescriptorWithKey:RIDE_FETCH_SORT_KEY2 ascending:RIDE_FETCH_SORT_ASC2],
	  ];
	
	_ridesFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[Util managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
	_ridesFetchedResultsController.delegate = self;
	
	NSError* error = nil;
	if (![_ridesFetchedResultsController performFetch:&error]) {
		
		NSLog(@"Unresolved error: %@, %@", error, error.userInfo);
	}
	
	return _ridesFetchedResultsController;
}


- (NSFetchedResultsController*)teamsFetchedResultsController {
	
	if (_teamsFetchedResultsController) return _teamsFetchedResultsController;
	
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TEAM_ENTITY_NAME];
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


- (NSDateFormatter*)dispatchDateFormatter {
	
	if (_dispatchDateFormatter) return _dispatchDateFormatter;
	
	_dispatchDateFormatter = [[NSDateFormatter alloc] init];
	_dispatchDateFormatter.dateFormat = DISPATCH_DATETIME_FORMAT;
	
	return _dispatchDateFormatter;
}


- (UIColor*)calloutAccessoryColorGreen {

	if (_calloutAccessoryColorGreen) return _calloutAccessoryColorGreen;
	
	_calloutAccessoryColorGreen = HSB(120.0, 1.0, 0.8);
	
	return _calloutAccessoryColorGreen;
}


#
# pragma mark UIResponder
#


- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
	
	[super touchesBegan:touches withEvent:event];
	
	[self prepRideTeamPanAssignment];
}


- (void)touchesMoved:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {

	[super touchesMoved:touches withEvent:event];
	
	[self anchorRideTeamPanAssignment];
}


- (void)touchesEnded:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
	
	[super touchesEnded:touches withEvent:event];
	
	[self panAssignRideTeam];
}


- (void)touchesCancelled:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {

	[super touchesCancelled:touches withEvent:event];

	[self cancelAnchorRideTeamPanAssignment];
}


#
# pragma mark UIResponder Helpers
#


- (void)prepRideTeamPanAssignment {
	// NOTE: Even if touching an annotation, it is not "selected" until first move

	self.rideTeamPanAssignmentAnchorAnnotation = nil;
}


- (void)anchorRideTeamPanAssignment {
	// NOTE: We rely on move events being imperceptibly close together to give effect of selecting annotation where user touched down
	
	if (self.rideTeamPanAssignmentAnchorAnnotation) return;
	self.rideTeamPanAssignmentAnchorAnnotation = self.mainMapView.selectedAnnotations.firstObject;
}


- (void)panAssignRideTeam {

	// If we do not have two selected annotations, we are done
	
	id<MKAnnotation> firstSelectedAnnotation = self.rideTeamPanAssignmentAnchorAnnotation;
	if (!firstSelectedAnnotation) return;
	self.rideTeamPanAssignmentAnchorAnnotation = nil;
	
	id<MKAnnotation> lastSelectedAnnotation = self.mainMapView.selectedAnnotations.firstObject;
	if (!lastSelectedAnnotation) return;
	
	// If annotations do not have one ride and one team, or they are already assigned to each other, we are done
	Ride* ride;
	Team* team;
	if ([firstSelectedAnnotation conformsToProtocol:@protocol(RideModelSource)] &&
		[lastSelectedAnnotation conformsToProtocol:@protocol(TeamModelSource)]) {
		
		ride = ((id<RideModelSource>)firstSelectedAnnotation).ride;
		team = ((id<TeamModelSource>)lastSelectedAnnotation).team;
		
	} else if ([firstSelectedAnnotation conformsToProtocol:@protocol(TeamModelSource)] &&
			   [lastSelectedAnnotation conformsToProtocol:@protocol(RideModelSource)]) {
		
		team = ((id<TeamModelSource>)firstSelectedAnnotation).team;
		ride = ((id<RideModelSource>)lastSelectedAnnotation).ride;
	}
	if (!ride || !team || ride.teamAssigned == team) return;
	
	// Ask user if should assign ride and team
	
	UIAlertAction* assignAlertAction = [UIAlertAction actionWithTitle:@"Assign" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
		
		// Assign team to ride, including route recalculations and notifications
		[ride assignTeam:team withSender:self];
		
		// Persist in store
		[Util saveManagedObjectContext];
	}];
	
	NSString* message = [NSString stringWithFormat:@"Team: %@\nRide: %@", [team getTitle], [ride getTitle]];
	[Util presentActionAlertWithViewController:self andTitle:@"Assign team to ride?" andMessage:message andAction:assignAlertAction andCancelHandler:nil];
}


- (void)cancelAnchorRideTeamPanAssignment {
	
	self.rideTeamPanAssignmentAnchorAnnotation = nil;
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
	
	self.polylineMode = PolylineMode_Connect;
	
	[self addNotificationObservers];
	
	[self configureView];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
	NSLog(@"Warning: Memory Low");
}


#
# pragma mark <UIContentContainer>
#


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	
	[[self.actionSheetController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


#
# pragma mark <NSFetchedResultsControllerDelegate>
#


- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
	
	// NOTE: Even if method is empty, at least one protocol method must be implemented for fetch-results controller to track changes
}


#
# pragma mark <UITextFieldDelegate>
#


/*
 User tapped keyboard return button
 NOTE: Text field is *not* empty due to "auto-enable" of return key
 */
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
	
	if ([annotation isKindOfClass:[RidePointAnnotation class]])
		return [self mapView:mapView viewForRidePointAnnotation:(RidePointAnnotation*)annotation];
	
	if ([annotation isKindOfClass:[TeamPointAnnotation class]])
		return [self mapView:mapView viewForTeamPointAnnotation:(TeamPointAnnotation*)annotation];
	
	if ([annotation isKindOfClass:[RidePolyline class]])
		return [self mapView:mapView viewForRidePolylineAnnotation:(RidePolyline*)annotation];

	return nil;
}


- (void)mapView:(MKMapView*)mapView didAddAnnotationViews:(NSArray<MKAnnotationView*>*)views {
	
	// Animate dropping for team point annotations
	
	int i = 0;
	for (MKAnnotationView* view in views) {

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
		
		i++;
	}
}


- (void)mapView:(MKMapView*)mapView didSelectAnnotationView:(nonnull MKAnnotationView*)view {

	if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
		
		// Do nothing (for now)
		
	} else if ([view.annotation isKindOfClass:[RidePointAnnotation class]]) {
		
		Ride* ride = ((RidePointAnnotation*)view.annotation).ride;
		
		// Notify selection changed, if not on same ride as previous selected annotation
		if (!self.previousSelectedAnnotation ||
			![self.previousSelectedAnnotation isKindOfClass:[RidePointAnnotation class]] ||
			ride != ((RidePointAnnotation*)self.previousSelectedAnnotation).ride) {
		
			[ride postNotificationUpdatedWithSender:self];
		}
		
		NSLog(@"Rides[%lu] selected: %@", (unsigned long)[self.rideFetchedResultsController.fetchedObjects indexOfObject:ride], ride);
		
	} else if ([view.annotation isKindOfClass:[TeamPointAnnotation class]]) {
		
		Team* team = ((TeamPointAnnotation*)view.annotation).team;
		
		for (Ride* ride in team.ridesAssigned) {
		
			[ride postNotificationUpdatedWithSender:self];
		}
		
		NSLog(@"Teams[%lu] selected: %@", (unsigned long)[self.teamsFetchedResultsController.fetchedObjects indexOfObject:team], team);
	}

	// Remember selected annotation for next selection
	self.previousSelectedAnnotation = view.annotation;
}


- (void)mapView:(MKMapView*)mapView didDeselectAnnotationView:(nonnull MKAnnotationView*)view {
	
	// Delay deselection handler until _after_ new selection, if any
	// NOTE: Push to next iteration of run loop
	[self performSelector:@selector(deselectedAnnotationView:) withObject:view afterDelay:0.0];
}


- (void)deselectedAnnotationView:(nonnull MKAnnotationView*)view {
	
	if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
		
		// Do nothing (for now)
		
	} else if ([view.annotation isKindOfClass:[RidePointAnnotation class]]) {
		
		Ride* ride = ((RidePointAnnotation*)view.annotation).ride;
		[ride postNotificationUpdatedWithSender:self];
		
	} else if ([view.annotation isKindOfClass:[TeamPointAnnotation class]]) {
		
		Team* team = ((TeamPointAnnotation*)view.annotation).team;
		
		for (Ride* ride in team.ridesAssigned) {
			
			[ride postNotificationUpdatedWithSender:self];
		}
	}

	// Clear remembered selected annotation if no annotation selected anymore
	if (self.mainMapView.selectedAnnotations.count == 0) {
		
		self.previousSelectedAnnotation = nil;
	}
}


- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(nonnull id<MKOverlay>)overlay {
	
	if ([overlay isKindOfClass:[MKPolygon class]]) // Jurisdication inverse overlay
	{
		MKPolygonRenderer* renderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
		renderer.alpha = 0.2;
		renderer.fillColor = [UIColor grayColor];
		
		return renderer;
	}
	
	if ([overlay isKindOfClass:[RidePolyline class]]) {
		
		RidePolyline* ridePolyline = (RidePolyline*)overlay;
		
		MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay:ridePolyline];
		renderer.alpha = 0.5;
		renderer.lineWidth = 5.0;
		
		switch (ridePolyline.rideRouteType) {

			case RideRouteType_Prep:
				
				// Dotted line
				renderer.lineDashPattern = @[ @3, @8 ]; // renderer.lineDashPhase = 6;
				renderer.strokeColor = [UIColor blueColor];
				break;
				
			case RideRouteType_Wait:
				
				// Dotted line
				renderer.lineDashPattern = @[ @3, @8 ]; // renderer.lineDashPhase = 6;
				renderer.strokeColor = [UIColor orangeColor];
				break;

			default:
			case RideRouteType_None:
			case RideRouteType_Main:
				
				// Solid line
				renderer.strokeColor = [UIColor blueColor];
				break;
		}
		
		return renderer;
	}
	
	return nil;
}


- (void)mapView:(MKMapView*)mapView annotationView:(nonnull MKAnnotationView*)view calloutAccessoryControlTapped:(nonnull UIControl*)control {
	
	[self.addressTextField resignFirstResponder];
	
	UIButtonType buttonType = ((UIButton*)control).buttonType;
	
	if ([view.annotation isKindOfClass:[MKUserLocation class]]) return;
	
	if ([view.annotation isKindOfClass:[RidePointAnnotation class]]) {
		
		Ride* ride = ((RidePointAnnotation*)view.annotation).ride;
		
		switch (buttonType) {
				
			case UIButtonTypeDetailDisclosure: {
				
				[self presentActionSheetWithCalloutAccessoryControl:control andRide:ride];
				return;
				
			} // case
				
			case UIButtonTypeCustom: {
				
				[self launchMapsAppWithRide:ride];
				return;
				
			} // case
				
			default:
				return;
				
		} // switch
		
	} // if
	
	if ([view.annotation isKindOfClass:[TeamPointAnnotation class]]) {
		
		Team* team = ((TeamPointAnnotation*)view.annotation).team;
		
		switch (buttonType) {
				
			case UIButtonTypeDetailDisclosure: {
				
				[self presentActionSheetWithCalloutAccessoryControl:control andTeam:team];
				return;
				
			} // case
				
			case UIButtonTypeCustom: {
				
				[self launchMapsAppWithTeam:team];
				return;
				
			} // case
				
			default:
				return;
				
		} // switch
		
	} // if
}


- (void)mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {

	if ([view.annotation isKindOfClass:[MKUserLocation class]]) return;
	
	if ([view.annotation isKindOfClass:[RidePointAnnotation class]]) return;
		
	if ([view.annotation isKindOfClass:[TeamPointAnnotation class]]) return;
}


#
# pragma mark <MKMapViewDelegate> Helpers
#


- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForRidePointAnnotation:(RidePointAnnotation*)ridePointAnnotation {
	
	MKPinAnnotationView* ridePinAnnotationView = (MKPinAnnotationView*)[self dequeueReusableAnnotationViewWithMapView:mapView andAnnotation:ridePointAnnotation andIdentifier:ridePointAnnotation.rideLocationType == RideLocationType_End ? RIDE_END_ANNOTATION_ID : RIDE_START_ANNOTATION_ID];
	
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
	ridePinAnnotationView.pinColor = ridePointAnnotation.rideLocationType == RideLocationType_End
	? MKPinAnnotationColorRed
	: (ride.teamAssigned ? MKPinAnnotationColorGreen : MKPinAnnotationColorPurple);
	
	// Add/update/remove left callout accessory
	// NOTE: Do not set for update, to avoid re-animation
	if (!ridePinAnnotationView.leftCalloutAccessoryView) {
		
		ridePinAnnotationView.leftCalloutAccessoryView = [self leftCalloutAccessoryButtonWithWidth:60];
	}
	if (![self configureLeftCalloutAccessoryButton:(UIButton*)ridePinAnnotationView.leftCalloutAccessoryView withRidePointAnnotation:ridePointAnnotation]) {
		
		ridePinAnnotationView.leftCalloutAccessoryView = nil;
	}
	
	return ridePinAnnotationView;
}


- (UIButton*)configureLeftCalloutAccessoryButton:(UIButton*)leftCalloutAccessoryButton withRidePointAnnotation:(RidePointAnnotation*)ridePointAnnotation {
	
	Ride* ride = ridePointAnnotation.ride;
	
	// If time present, add to label with appropriate background color
	
	switch (ridePointAnnotation.rideLocationType) {
			
		case RideLocationType_Start: {
			
			NSTimeInterval waitDuration = [ride durationWithRideRouteType:RideRouteType_Wait];
			NSDate* dateTimeStart = ride.dateTimeStart;
			if (waitDuration < 0 && !dateTimeStart) return nil;
			
			NSString* assignedDateTimeStartString = waitDuration >= 0 ? [self.annotationDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:waitDuration]] : MAP_ANNOTATION_FIELD_EMPTY;
			
			NSString* dateTimeStartString = dateTimeStart ? [self.annotationDateFormatter stringFromDate:dateTimeStart] : MAP_ANNOTATION_FIELD_EMPTY;
			
			[leftCalloutAccessoryButton setTitle:[NSString stringWithFormat:@"%@\n(%@)", assignedDateTimeStartString, dateTimeStartString] forState:UIControlStateNormal];
			
			leftCalloutAccessoryButton.backgroundColor = ride.teamAssigned ? self.calloutAccessoryColorGreen : [UIColor purpleColor];
			
			break;
		}
			
		case RideLocationType_End: {
			
			NSTimeInterval waitDuration = [ride durationWithRideRouteType:RideRouteType_Wait];
			NSNumber* routeMainDuration = ride.routeMainDuration;
			NSDate* routeDateTimeEnd = ride.getRouteDateTimeEnd;
			if ((waitDuration < 0 || !routeMainDuration) &&
				!routeDateTimeEnd) return nil;
			
			NSString* assignedRouteDateTimeEndString = waitDuration >= 0 && routeMainDuration ? [self.annotationDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(waitDuration + routeMainDuration.doubleValue)]] : MAP_ANNOTATION_FIELD_EMPTY;
			
			NSString* routeDateTimeEndString = routeDateTimeEnd ? [self.annotationDateFormatter stringFromDate:routeDateTimeEnd] : MAP_ANNOTATION_FIELD_EMPTY;
			
			[leftCalloutAccessoryButton setTitle:[NSString stringWithFormat:@"%@\n(%@)", assignedRouteDateTimeEndString, routeDateTimeEndString] forState:UIControlStateNormal];
			
			leftCalloutAccessoryButton.backgroundColor = [UIColor redColor];
			
			break;
		}
			
		default:
		case RideLocationType_None:
			break;
	}

	return leftCalloutAccessoryButton;
}


- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForTeamPointAnnotation:(TeamPointAnnotation*)teamPointAnnotation {
	
	MKAnnotationView* teamAnnotationView = (MKAnnotationView*)[self dequeueReusableAnnotationViewWithMapView:mapView andAnnotation:teamPointAnnotation andIdentifier:teamPointAnnotation.team.isMascot.boolValue ? TEAM_MASCOT_ANNOTATION_ID : TEAM_NORMAL_ANNOTATION_ID];
	
	[self configureTeamAnnotationView:teamAnnotationView withTeamPointAnnotation:teamPointAnnotation];
	
	return teamAnnotationView;
}


- (MKAnnotationView*)configureTeamAnnotationView:(MKAnnotationView*)teamAnnotationView withTeamPointAnnotation:(TeamPointAnnotation*)teamPointAnnotation {
	
	// Team* team = teamPointAnnotation.team;
	
	// NOTE: Animation of team annotation is done manually in "mapView:didAddAnnotationViews:"
	
	// Add/update/remove left callout accessory
	// NOTE: Do not set for update, to avoid re-animation
	if (!teamAnnotationView.leftCalloutAccessoryView) {
		
		teamAnnotationView.leftCalloutAccessoryView = [self leftCalloutAccessoryButtonWithWidth:70];
	}
	if (![self configureLeftCalloutAccessoryButton:(UIButton*)teamAnnotationView.leftCalloutAccessoryView withTeamPointAnnotation:teamPointAnnotation]) {
		
		teamAnnotationView.leftCalloutAccessoryView = nil;
	}
	
	return teamAnnotationView;
}


- (UIButton*)configureLeftCalloutAccessoryButton:(UIButton*)leftCalloutAccessoryButton withTeamPointAnnotation:(TeamPointAnnotation*)teamPointAnnotation {
	
	Team* team = teamPointAnnotation.team;
	
	// If team assigned to rides, add total route duration and distance to label
	
	if (!team.ridesAssigned || team.ridesAssigned.count == 0) return nil;
	
	NSString* leftCalloutAccessoryFormat = [NSString stringWithFormat:@"%@\n%@", MAP_ANNOTATION_DURATION_FORMAT, MAP_ANNOTATION_DISTANCE_FORMAT];
	
	[leftCalloutAccessoryButton setTitle:
	 [NSString stringWithFormat:leftCalloutAccessoryFormat,
	  [team assignedDuration] / (NSTimeInterval)SECONDS_PER_MINUTE,
	  [team assignedDistance] / (CLLocationDistance)METERS_PER_KILOMETER]
								forState:UIControlStateNormal];
	
	leftCalloutAccessoryButton.backgroundColor = [UIColor blueColor];
	
	return leftCalloutAccessoryButton;
}


- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForRidePolylineAnnotation:(RidePolyline*)ridePolylineAnnotation {
	
	MKAnnotationView* ridePolylineAnnotationView = (MKAnnotationView*)[self dequeueReusableAnnotationViewWithMapView:mapView andAnnotation:ridePolylineAnnotation andIdentifier:RIDE_POLYLINE_ANNOTATION_ID];

	[self configureRidePolylineAnnotationView:ridePolylineAnnotationView withRidePolylineAnnotation:ridePolylineAnnotation];
	
	return ridePolylineAnnotationView;
}


- (MKAnnotationView*)configureRidePolylineAnnotationView:(MKAnnotationView*)ridePolylineAnnotationView withRidePolylineAnnotation:(RidePolyline*)ridePolylineAnnotation {
	
	Ride* ride = ridePolylineAnnotation.ride;
	RideRouteType rideRouteType = ridePolylineAnnotation.rideRouteType;
	
	// Add/update polyline annotation label with route duration and distance
	
	UILabel* polylineAnnotationLabel = ridePolylineAnnotationView.subviews.firstObject;
	
	polylineAnnotationLabel.backgroundColor = rideRouteType == RideRouteType_Wait ? [UIColor orangeColor] : [UIColor blueColor];

	NSString* polylineAnnotationFormat = [NSString stringWithFormat:@"%@\n%@", MAP_ANNOTATION_DURATION_FORMAT, MAP_ANNOTATION_DISTANCE_FORMAT];
	
	polylineAnnotationLabel.text =
	[NSString stringWithFormat:polylineAnnotationFormat,
	 [ride durationWithRideRouteType:rideRouteType] / (NSTimeInterval)SECONDS_PER_MINUTE,
	 [ride distanceWithRideRouteType:rideRouteType] / (CLLocationDistance)METERS_PER_KILOMETER];

	return ridePolylineAnnotationView;
}


- (MKAnnotationView*)dequeueReusableAnnotationViewWithMapView:(MKMapView*)mapView andAnnotation:(id<MKAnnotation>)annotation andIdentifier:(NSString*)identifier {
	
	// Reuse pooled annotation view if possible
	MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (annotationView) {
		
		annotationView.annotation = annotation;
		annotationView.leftCalloutAccessoryView = nil;
		return annotationView;
	}
	
	// Create new annotation view
	
	if ([identifier isEqualToString:RIDE_START_ANNOTATION_ID] ||
		[identifier isEqualToString:RIDE_END_ANNOTATION_ID]) {
		
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		annotationView.canShowCallout = YES;
		annotationView.rightCalloutAccessoryView = [self rightCalloutAccessoryButton];
		
	} else if ([identifier isEqualToString:TEAM_MASCOT_ANNOTATION_ID] ||
			   [identifier isEqualToString:TEAM_NORMAL_ANNOTATION_ID]) {
		
		annotationView = [[TeamAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		((TeamAnnotationView*)annotationView).mapView = self.mainMapView;
		annotationView.image = [UIImage imageNamed:[identifier isEqualToString:TEAM_MASCOT_ANNOTATION_ID] ? @"ORN-Team-Mascot-Map-Annotation" : @"ORN-Team-Map-Annotation"];
		annotationView.canShowCallout = YES;
		annotationView.draggable = YES;
		annotationView.rightCalloutAccessoryView = [self rightCalloutAccessoryButton];

	} else if ([identifier isEqualToString:RIDE_POLYLINE_ANNOTATION_ID]) {
		
		annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		UILabel* polylineAnnotationLabel = [MainMapViewController polylineAnnotationLabel];
		[annotationView addSubview:polylineAnnotationLabel];
		annotationView.centerOffset = CGPointMake(-polylineAnnotationLabel.bounds.size.width / 2.0,
												  -polylineAnnotationLabel.bounds.size.height);
	}

	return annotationView;
}


- (UIButton*)leftCalloutAccessoryButtonWithWidth:(CGFloat)width {

	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, width, 53);
	
	[button addTarget:self action:@selector(leftCalloutAccessoryButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
	[button addTarget:self action:@selector(leftCalloutAccessoryButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	
	button.alpha = 0.5;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	button.titleLabel.textAlignment = NSTextAlignmentCenter;
	button.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
	button.titleLabel.numberOfLines = 0;
	button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;

	return button;
}


- (UIButton*)rightCalloutAccessoryButton {

	UIButton* button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	
	return button;
}


- (void)presentActionSheetWithActions:(NSArray<UIAlertAction*>*)alertActions andReferenceView:(UIView*)referenceView {
	
	UIAlertController* actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	for (UIAlertAction* alertAction in alertActions) {
		
		[actionSheetController addAction:alertAction];
	}
	
	// Add "cancel" action to sheet
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
	[actionSheetController addAction:cancelAction];
	
	// Configure popover for iPad
	UIPopoverPresentationController* alertPopoverPresentationController = actionSheetController.popoverPresentationController;
	alertPopoverPresentationController.sourceView = self.view;
	CGRect sourceRect = [referenceView convertRect:referenceView.frame toView:self.view];
	alertPopoverPresentationController.sourceRect = sourceRect;
	alertPopoverPresentationController.permittedArrowDirections =
	(
	 UIPopoverArrowDirectionDown |
	 UIPopoverArrowDirectionLeft
	 );
	
	// Present action sheet
	[self presentViewController:actionSheetController animated:YES completion:nil];
	self.actionSheetController = actionSheetController;
}


- (void)presentActionSheetWithReferenceView:(UIView*)referenceView andRide:(Ride*)ride {
	
	NSAssert(ride, @"Ride must exist");
	if (!ride) return;

	UIAlertAction* callAction = [UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
		
		[self launchPhoneAppWithRide:ride];
	}];
	
	UIAlertAction* directionsAction = [UIAlertAction actionWithTitle:@"Directions" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
		
		[self launchMapsAppWithRide:ride];
	}];
	
	UIAlertAction* detailAction = [UIAlertAction actionWithTitle:@"Details" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
		
		[self showDetailViewControllerWithRide:ride];
	}];

	UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* _Nonnull action) {
		
		[Util presentDeleteAlertWithViewController:self andDataObject:ride andCancelHandler:nil];
	}];
	
	[self presentActionSheetWithActions:@[callAction, directionsAction, detailAction, deleteAction] andReferenceView:referenceView];
}


- (void)presentActionSheetWithReferenceView:(UIView*)referenceView andTeam:(Team*)team {
	
	NSAssert(team, @"Team must exist");
	if (!team) return;
	
	UIAlertAction* dispatchAction = [UIAlertAction actionWithTitle:@"Dispatch" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
		
		[self launchMessagesAppWithDispatchForTeam:team];
	}];
	
	UIAlertAction* callAction = [UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
		
		[self launchPhoneAppWithTeam:team];
	}];
	
	UIAlertAction* directionsAction = [UIAlertAction actionWithTitle:@"Directions" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
		
		[self launchMapsAppWithTeam:team];
	}];
	
	UIAlertAction* detailAction = [UIAlertAction actionWithTitle:@"Details" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
		
		[self showDetailViewControllerWithTeam:team];
	}];
	
	UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* _Nonnull action) {
		
		[Util presentDeleteAlertWithViewController:self andDataObject:team andCancelHandler:nil];
	}];
	
	[self presentActionSheetWithActions:@[dispatchAction, callAction, directionsAction, detailAction, deleteAction] andReferenceView:referenceView];
}


- (void)presentActionSheetWithCalloutAccessoryControl:(UIControl*)control andRide:(Ride*)ride {
	
	UIView* mapAnnotationCalloutView = control.superview.superview; // internal MKSmallCalloutContainerView
	
	[self presentActionSheetWithReferenceView:mapAnnotationCalloutView andRide:ride];
}


- (void)presentActionSheetWithCalloutAccessoryControl:(UIControl*)control andTeam:(Team*)team {
	
	UIView* mapAnnotationCalloutView = control.superview.superview; // internal MKSmallCalloutContainerView
	
	[self presentActionSheetWithReferenceView:mapAnnotationCalloutView andTeam:team];
}


+ (UILabel*)polylineAnnotationLabel {
	
	UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 30)];

	label.alpha = 0.9;
	label.textColor = [UIColor whiteColor];
	
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont boldSystemFontOfSize:10.0];
	label.numberOfLines = 0;
	label.lineBreakMode = NSLineBreakByWordWrapping;
	
	label.clipsToBounds = YES;
	label.layer.cornerRadius = 5.0;
	
	return label;
}


#
# pragma mark <MFMessageComposeViewControllerDelegate>
#


- (void)messageComposeViewController:(MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result {
	
	[self dismissViewControllerAnimated:YES completion:^{
		
		switch (result) {
				
			case MessageComposeResultSent:
				
				NSLog(@"Team dispatch message was sent");
				//	[Util presentOKAlertWithViewController:self andTitle:@"Dispatch Info" andMessage:@"Team dispatch message was sent"];
				
				break;
				
			case MessageComposeResultCancelled:
				
				[Util presentOKAlertWithViewController:self andTitle:@"Dispatch Warning" andMessage:@"Team dispatch message was cancelled"];
				
				break;
				
			case MessageComposeResultFailed:
				
				[Util presentOKAlertWithViewController:self andTitle:@"Dispatch Error" andMessage:@"Team dispatch message failed to send"];
				
				break;
				
			default:
				NSAssert(NO, @"Should never get here");
				break;
		}
	}];
}


#
# pragma mark Action Handlers
#


- (IBAction)avatarBarButtonPressed:(UIBarButtonItem*)sender {
	
	[self configureJurisdictionRegionViewWithAnimated:YES];
}


- (IBAction)lineTypeChanged:(UISegmentedControl*)sender {
	
	self.polylineMode = self.lineTypeSegmentedControl.selectedSegmentIndex == 1 ? PolylineMode_Route : PolylineMode_Connect;
	
	// If no selected ride or team, we are done
	id<MKAnnotation> selectedAnnotation = self.mainMapView.selectedAnnotations.firstObject;
	if (!selectedAnnotation) return;
	
	// Notify selected ride or team
	if ([selectedAnnotation conformsToProtocol:@protocol(RideModelSource)]) {
		
		Ride* ride = ((id<RideModelSource>)selectedAnnotation).ride;
		[ride postNotificationUpdatedWithSender:self];
		return;
	}
	
	if ([selectedAnnotation conformsToProtocol:@protocol(TeamModelSource)]) {
		
		Team* team = ((id<TeamModelSource>)selectedAnnotation).team;
		for (Ride* ride in team.ridesAssigned) {
			
			[ride postNotificationUpdatedWithSender:self];
		}
		return;
	}
}


- (BOOL)moveMapCameraVerticalWithAnimated:(BOOL)animated {

	if (self.mainMapView.camera.pitch <= 0) return NO;
	
	MKMapCamera* mapCamera = [self.mainMapView.camera copy];
	mapCamera.altitude = mapCamera.distanceFromCenter;
	mapCamera.pitch = 0;
	
	[self.mainMapView setCamera:mapCamera animated:animated];
	
	return YES;
}


- (IBAction)mapTypeChanged:(UISegmentedControl*)sender {
	
	switch (self.mapTypeSegmentedControl.selectedSegmentIndex) {
			
		default:
		case 0: // Standard
			
			self.mainMapView.mapType = MKMapTypeStandard;
			break;
			
		case 1: { // Hybrid

			double delayInSeconds = [self moveMapCameraVerticalWithAnimated:YES] ? 0.6 : 0;
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				
				self.mainMapView.mapType = MKMapTypeHybrid;
			});
			
			break;
		}
			
		case 2: { // Satellite
			
			double delayInSeconds = [self moveMapCameraVerticalWithAnimated:YES] ? 0.6  : 0;
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

				self.mainMapView.mapType = MKMapTypeSatellite;
			});
						   
			break;
		}
	}
}


- (IBAction)addressTextFieldReturnButtonPressed:(UITextField*)sender {
	// NOTE: Cannot wire to keyboard button, so called directly via text-field delegate
	
	[Ride tryCreateRideWithAddressString:sender.text andGeocoder:self.geocoder andSender:self];
}


- (IBAction)leftCalloutAccessoryButtonTouchDown:(UIButton*)sender {
	// NOTE: Wired programmatically
	
	sender.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
}


- (IBAction)leftCalloutAccessoryButtonTouchUpInside:(UIButton*)sender {
	// NOTE: Wired programmatically
	
	sender.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
}


#
# pragma mark Action Handler Helpers
#


- (void)launchMessagesAppWithDispatchForTeam:(Team*)team {
	
	NSAssert(team, @"Team must exist");
	if (!team) return;
	
	if (team.ridesAssigned.count <= 0) {
		
		[Util presentOKAlertWithViewController:self andTitle:@"Dispatch Alert" andMessage:@"Team has no rides assigned"];
		return;
	}
	
	if (team.emailAddress.length <= 0 && team.phoneNumber.length <= 0) {
		
		[Util presentOKAlertWithViewController:self andTitle:@"Dispatch Alert" andMessage:@"Team has no email or phone #"];
		return;
	}
	
	if (![MFMessageComposeViewController canSendText]) {
		
		[Util presentOKAlertWithViewController:self andTitle:@"Dispatch Alert" andMessage:@"Messages app not available"];
		return;
	}
	
	// Populate data model for Messages app
	
	MFMessageComposeViewController* messageComposeViewController = [[MFMessageComposeViewController alloc] init];
	messageComposeViewController.messageComposeDelegate = self;
	
	// Prefer Apple ID e-mail over phone number
	messageComposeViewController.recipients =
	@[
	  team.emailAddress.length > 0 ? team.emailAddress : team.phoneNumber
	  ];
	
	Ride* ride = [team getFirstRideAssigned];
	NSAssert(ride, @"First ride assigned must exist");
	
	messageComposeViewController.body =
	
	[NSString stringWithFormat:
	 @"ORN Dispatch\n\n"
	 @"%@, %@, %lu passengers (%@)\n"
	 @"%@, %@, %lu seatbelts\n\n"
	 @"From: %@ (%@ min, %@ km)\n\n"
	 @"To: %@ (%@ min, %@ km)",
	 
	 ride.passengerNameFirst,
	 (ride.passengerPhoneNumber.length > 0 ? ride.passengerPhoneNumber : @"(no phone #)"),
	 ride.passengerCount.unsignedLongValue,
	 [self.annotationDateFormatter stringFromDate:ride.dateTimeStart],
	 
	 (ride.vehicleDescription.length > 0 ? ride.vehicleDescription : @"(no vehicle description)"),
	 (ride.vehicleTransmission.integerValue == VehicleTransmission_Manual ? @"manual" : @"automatic"),
	 ride.vehicleSeatBeltCount.unsignedLongValue,
	 
	 ride.locationStartAddress,
	 [NSString stringWithFormat:@"%.0f", ride.routePrepDuration.doubleValue / (NSTimeInterval)SECONDS_PER_MINUTE],
	 [NSString stringWithFormat:@"%.1f", ride.routePrepDistance.doubleValue / (CLLocationDistance)METERS_PER_KILOMETER],
	 
	 ride.locationEndAddress,
	 [NSString stringWithFormat:@"%.0f", ride.routeMainDuration.doubleValue / (NSTimeInterval)SECONDS_PER_MINUTE],
	 [NSString stringWithFormat:@"%.1f", ride.routeMainDistance.doubleValue / (CLLocationDistance)METERS_PER_KILOMETER]
	 ];
	
	[self presentViewController:messageComposeViewController animated:YES completion:nil];
}


- (void)launchPhoneAppWithRide:(Ride*)ride {
	
	[self launchPhoneAppWithPhoneNumber:ride.passengerPhoneNumber andEntityName:@"Ride"];
}


- (void)launchPhoneAppWithTeam:(Team*)team {

	[self launchPhoneAppWithPhoneNumber:team.phoneNumber andEntityName:@"Team"];
}


- (void)launchPhoneAppWithPhoneNumber:(NSString*)phoneNumber andEntityName:(NSString*)entityName {
	
	NSAssert(entityName.length > 0, @"Object name must exist");
	if (entityName.length <= 0) return;
	
	if (phoneNumber.length <= 0) {
		
		[Util presentOKAlertWithViewController:self andTitle:@"Call Alert" andMessage:[NSString stringWithFormat:@"%@ has no phone #", entityName]];
		return;
	}
	
	NSString* encodedPhoneString = [phoneNumber stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet phoneNumberCharacterSet]];
	if (!encodedPhoneString) {
		
		[Util presentOKAlertWithViewController:self andTitle:@"Call Alert" andMessage:[NSString stringWithFormat:@"%@ phone # not valid", entityName]];
		return;
	}
	
	UIApplication* sharedApplication = [UIApplication sharedApplication];
	
	// NOTE: Scheme "telprompt" may not be available, so fall back to known scheme "tel".
	NSURL* callURL = [NSURL URLWithString:[@"telprompt:" stringByAppendingString:encodedPhoneString]];
	if (![sharedApplication canOpenURL:callURL]) {

		callURL = [NSURL URLWithString:[@"tel:" stringByAppendingString:encodedPhoneString]];
		if (![sharedApplication canOpenURL:callURL]) {
			
			[Util presentOKAlertWithViewController:self andTitle:@"Call Alert" andMessage:@"Phone app not available"];
			return;
		}
	}
	
	[sharedApplication openURL:callURL];
}


- (void)launchMapsAppWithRide:(Ride*)ride {
	
	NSAssert(ride, @"Ride must exist");
	if (!ride) return;
	
	NSMutableArray<MKMapItem*>* mapItems = [NSMutableArray arrayWithCapacity:2];
	
	MKMapItem* mapItem = [ride mapItemWithRideLocationType:RideLocationType_Start];
	if (mapItem) {
		
		[mapItems addObject:mapItem];
	}
	
	mapItem = [ride mapItemWithRideLocationType:RideLocationType_End];
	if (mapItem) {
		
		[mapItems addObject:mapItem];
	}
	
	if (mapItems.count < 2) {
		
		mapItem = [ride.teamAssigned mapItemForCurrentLocation];
		
		if (mapItem) {
			
			[mapItems insertObject:mapItem atIndex:0];
		}
	}
	
	NSDictionary<NSString*,id>* launchOptions = mapItems.count == 2
	? @{ MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving }
	: nil;
	
	if (![MKMapItem openMapsWithItems:mapItems launchOptions:launchOptions]) {
		
		NSLog(@"Failed to open ride directions in Maps app");
	}
}


- (void)launchMapsAppWithTeam:(Team*)team {
	
	NSAssert(team, @"Team must exist");
	if (!team) return;
	
	NSMutableArray<MKMapItem*>* mapItems = [NSMutableArray arrayWithCapacity:2];
	
	MKMapItem* mapItem = [team mapItemForCurrentLocation];
	if (mapItem) {
		
		[mapItems addObject:mapItem];
	}
	
	Ride* firstRideAssigned = [team getFirstRideAssigned];
	mapItem = [firstRideAssigned mapItemWithRideLocationType:RideLocationType_Start];
	if (mapItem) {
		
		[mapItems addObject:mapItem];
	}
	
	NSDictionary<NSString*,id>* launchOptions = mapItems.count == 2
	? @{ MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving }
	: nil;
	
	if (![MKMapItem openMapsWithItems:mapItems launchOptions:launchOptions]) {
		
		NSLog(@"Failed to open team directions in Maps app");
	}
}


- (void)showDetailViewControllerWithRide:(Ride*)ride {
	
	NSAssert(ride, @"Ride must exist");
	if (!ride) return;
	
	// Create ride detail controller
	self.rideDetailTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:RIDE_DETAIL_TABLE_VIEW_CONTROLLER_ID];
	
	// Remove "cancel" button
	self.rideDetailTableViewController.navigationItem.leftBarButtonItem = nil;
	
	// Inject data model
	self.rideDetailTableViewController.ride = ride;
	
	// Push onto navigation stack
	[self.navigationController pushViewController:self.rideDetailTableViewController animated:YES];
}


- (void)showDetailViewControllerWithTeam:(Team*)team {
	
	NSAssert(team, @"Team must exist");
	if (!team) return;
	
	// Create team detail controller
	self.teamDetailTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:TEAM_DETAIL_TABLE_VIEW_CONTROLLER_ID];
	
	// Remove "cancel" button
	self.teamDetailTableViewController.navigationItem.leftBarButtonItem = nil;
	
	// Inject data model
	self.teamDetailTableViewController.team = team;
	
	// Push onto navigation stack
	[self.navigationController pushViewController:self.teamDetailTableViewController animated:YES];
}


#
# pragma mark Notification Handlers
#


- (void)dataModelResetWithNotification:(NSNotification*)notification {
	
	self.ridesFetchedResultsController = nil;
	self.teamsFetchedResultsController = nil;
	
	[self clearAllAnnotations];
	[self clearAllOverlays];
	
	[self configureView];
	
	[self.navigationController popToRootViewControllerAnimated:NO];
}


- (void)annotationViewDragEndedWithNotification:(NSNotification*)notification {

	NSAssert([notification.object isKindOfClass:[MKAnnotationView class]], @"Notification must be from map annotation view");
	
	MKAnnotationView* annotationView = notification.object;
	id<MKAnnotation> annotation = annotationView.annotation;
	
	if ([annotation isKindOfClass:[MKUserLocation class]]) return;
	
	if ([annotation isKindOfClass:[RidePointAnnotation class]]) return;
	
	if ([annotation isKindOfClass:[TeamPointAnnotation class]]) {
		
		[self.mainMapView deselectAnnotation:annotation animated:NO];
		
		Team* team = ((TeamPointAnnotation*)annotation).team;
		
		CLLocationCoordinate2D dropCoordinate = annotation.coordinate;
		
		UIAlertAction* moveAction = [UIAlertAction actionWithTitle:@"Move" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
			
			[team updateCurrentLocationWithLatitude:dropCoordinate.latitude andLongitude:dropCoordinate.longitude andStreet:nil andCity:nil andState:nil andAddress:nil andTime:nil];
			
			[team persistCurrentLocationWithSender:self];
			[self.mainMapView selectAnnotation:annotation animated:NO];
			
			NSString* addressString = [NSString stringWithFormat:@"%f,%f", dropCoordinate.latitude, dropCoordinate.longitude];
			[team tryUpdateCurrentLocationWithAddressString:addressString
												andGeocoder:self.geocoder
												  andSender:self]; // async
		}];
		
		NSString* title = @"Move team to location?";
		NSString* message = [NSString stringWithFormat:@"Team: %@\nLocation: (%.7f,%.7f)", [team getTitle], dropCoordinate.latitude, dropCoordinate.longitude];
		[Util presentActionAlertWithViewController:self andTitle:title andMessage:message andAction:moveAction andCancelHandler:^(UIAlertAction* action) {
			
			// Move team annotation view back to its pre-drag location
			[team postNotificationUpdatedWithSender:self andUpdatedLocation:YES];
			[self.mainMapView selectAnnotation:annotation animated:NO];
		}];
	}
}


#
# pragma mark Ride Notification Handlers
#


- (void)rideCreatedWithNotification:(NSNotification*)notification {

	BOOL createdFromMapView = (notification.object == self);
	
	BOOL annotationShown = [self configureRideAnnotationsWithNotification:notification andOptions:(createdFromMapView ? ( Configure_Center | Configure_Select ) : Configure_None)];
	
	if (!createdFromMapView) return;
		
	self.addressTextField.text = @"";
	
	if (annotationShown) return;
		
	[Util presentOKAlertWithViewController:self andTitle:@"Creation Alert" andMessage:@"Ride created but no location annotations to show"];
}


- (void)rideDeletedWithNotification:(NSNotification*)notification {

	if (self.rideDetailTableViewController.ride == [Ride rideFromNotification:notification]) {
		
		[self.navigationController popToRootViewControllerAnimated:YES];
	}

	(void)[self configureRideAnnotationsWithNotification:notification andOptions:Configure_Delete];
	(void)[self configureRideOverlaysWithNotification:notification andOptions:Configure_Delete];
}


- (void)rideUpdatedWithNotification:(NSNotification*)notification {
	
	(void)[self configureRideAnnotationsWithNotification:notification andOptions:Configure_None];
	(void)[self configureRideOverlaysWithNotification:notification andOptions:Configure_None];
}


#
# pragma mark Ride Notification Handler Helpers
#


/*
 Configure ride annotations and their views, consistent with given ride notification
 Returns whether at least one annotation is present
 */
- (BOOL)configureRideAnnotationsWithNotification:(NSNotification*)notification
									  andOptions:(ConfigureOptions)options {
	
	Ride* ride = [Ride rideFromNotification:notification];
	NSArray<id<MKAnnotation>>* rideAnnotations = [self annotationsForRide:ride];
	
	// Configure start annotation
	BOOL isLocationUpdated = [Ride isUpdatedLocationStartFromNotification:notification];
	BOOL startAnnotationPresent = [self configureViewWithRide:ride
										  andRideLocationType:RideLocationType_Start
										 usingRideAnnotations:rideAnnotations
										 andIsLocationUpdated:isLocationUpdated
												   andOptions:options];
	
	// Configure end annotation
	// NOTE: Start annotation takes precedence for center and selection
	isLocationUpdated = [Ride isUpdatedLocationEndFromNotification:notification];
	if (startAnnotationPresent) {
		options &= ~( Configure_Center | Configure_Select );
	}
	BOOL endAnnotationPresent = [self configureViewWithRide:ride
										andRideLocationType:RideLocationType_End
									   usingRideAnnotations:rideAnnotations
									   andIsLocationUpdated:isLocationUpdated
												 andOptions:options];
	
	return startAnnotationPresent || endAnnotationPresent;
}


/*
 Configure ride annotation and its view, consistent with given ride
 Returns whether annotation is present
 */
- (BOOL)configureViewWithRide:(Ride*)ride
		  andRideLocationType:(RideLocationType)rideLocationType
		 usingRideAnnotations:(NSArray<id<MKAnnotation>>*)rideAnnotations
		 andIsLocationUpdated:(BOOL)isLocationUpdated
				   andOptions:(ConfigureOptions)options {
	
	RidePointAnnotation* ridePointAnnotation = [MainMapViewController getRidePointAnnotationFromRideAnnotations:rideAnnotations andRideLocationType:rideLocationType];
	BOOL wasRidePointAnnotationInMapView = (ridePointAnnotation != nil);
	BOOL wasRidePointAnnotationSelected = (wasRidePointAnnotationInMapView && ridePointAnnotation == self.mainMapView.selectedAnnotations.firstObject);
	
	// Remove existing annotation if location updated
	BOOL didRemoveRidePointAnnotationFromMapView = NO;
	if (isLocationUpdated) {
		
		if (wasRidePointAnnotationInMapView) {
			
			[self.mainMapView removeAnnotation:ridePointAnnotation];
			
			didRemoveRidePointAnnotationFromMapView = YES;
		}
	}
	
	// If deleting, we are done
	if (options & Configure_Delete) return NO;

	// If no location, we are done
	NSNumber* locationLatitude = [ride latitudeWithRideLocationType:rideLocationType];
	NSNumber* locationLongitude = [ride longitudeWithRideLocationType:rideLocationType];
	if (!locationLatitude || !locationLongitude) return NO;
	
	// Update existing annotation or create new one
	ridePointAnnotation = [RidePointAnnotation ridePointAnnotation:ridePointAnnotation withRide:ride andRideLocationType:rideLocationType andNeedsAnimatesDrop:isLocationUpdated];
	if (!ridePointAnnotation) return NO;
	if (wasRidePointAnnotationInMapView && !didRemoveRidePointAnnotationFromMapView) {
		
		MKPinAnnotationView* ridePinAnnotationView = (MKPinAnnotationView*)[self.mainMapView viewForAnnotation:ridePointAnnotation];
		if (ridePinAnnotationView) {
			
			[self configureRidePinAnnotationView:ridePinAnnotationView withRidePointAnnotation:ridePointAnnotation];
		}
		
	} else {
	
		// NOTE: Automatically triggers new annotation view
		[self.mainMapView addAnnotation:ridePointAnnotation];
	}
	
	if (options & Configure_Center) {
		
		[self.mainMapView setCenterCoordinate:CLLocationCoordinate2DMake(locationLatitude.doubleValue, locationLongitude.doubleValue) animated:YES];
	}
	
	if ((options & Configure_Select) || wasRidePointAnnotationSelected) {
		
		[self.mainMapView selectAnnotation:ridePointAnnotation animated:YES];
	}
	
	return YES;
}


/*
 Configure ride overlays, consistent with given ride notification
 Returns whether at least one overlay is present
 */
- (BOOL)configureRideOverlaysWithNotification:(NSNotification*)notification
								   andOptions:(ConfigureOptions)options {

	Ride* ride = [Ride rideFromNotification:notification];
	NSArray<id<MKOverlay>>* rideOverlays = [self overlaysForRide:ride];
	
	BOOL isRideSelected = [self isSelectedAnnotationForRide:ride];
	BOOL isTeamAssignedSelected = [self isSelectedAnnotationForTeam:ride.teamAssigned];
	
	BOOL mainOverlayPresent =
	[self configureViewWithRide:ride
			   andRideRouteType:RideRouteType_Main
			  usingRideOverlays:rideOverlays
			  andIsRideSelected:isRideSelected
	  andIsTeamAssignedSelected:isTeamAssignedSelected
					 andOptions:options];
	
	BOOL prepOverlayPresent =
	[self configureViewWithRide:ride
			   andRideRouteType:RideRouteType_Prep
			  usingRideOverlays:rideOverlays
			  andIsRideSelected:isRideSelected
	  andIsTeamAssignedSelected:isTeamAssignedSelected
					 andOptions:options];
	
	BOOL waitOverlayPresent =
	[self configureViewWithRide:ride
			   andRideRouteType:RideRouteType_Wait
			  usingRideOverlays:rideOverlays
			  andIsRideSelected:isRideSelected
	  andIsTeamAssignedSelected:isTeamAssignedSelected
					 andOptions:options];

	return mainOverlayPresent || prepOverlayPresent || waitOverlayPresent;
}


/*
 Configure ride polyline overlay and its annotation, consistent with given ride
 Returns whether overlay and annotation are present
 */
- (BOOL)configureViewWithRide:(Ride*)ride
			 andRideRouteType:(RideRouteType)rideRouteType
			usingRideOverlays:(NSArray<id<MKOverlay>>*)rideOverlays
			andIsRideSelected:(BOOL)isRideSelected
	andIsTeamAssignedSelected:(BOOL)isTeamAssignedSelected
				   andOptions:(ConfigureOptions)options {

	RidePolyline* ridePolyline = [MainMapViewController getRidePolylineFromRideOverlays:rideOverlays andRideRouteType:rideRouteType];
	BOOL wasRidePolylineInMapView = (ridePolyline != nil);
	
	// Remove existing overlay with annotation, if necessary
	BOOL didRemoveRidePolylineAnnotationFromMapView = NO;
	if (wasRidePolylineInMapView) {
		
		[self.mainMapView removeOverlay:ridePolyline];
		[self.mainMapView removeAnnotation:ridePolyline];
		
		didRemoveRidePolylineAnnotationFromMapView = YES;
	}
	
	// If deleting, we are done
	if (options & Configure_Delete) return NO;
	
	// If ride or team assigned is not selected, we are done
	switch (rideRouteType) {
		
		case RideRouteType_Main:
			
			if (!isRideSelected && !isTeamAssignedSelected) return NO;
			break;
			
		case RideRouteType_Prep:
			
			if (!isTeamAssignedSelected) return NO;
			break;
			
		case RideRouteType_Wait:

			if (!isRideSelected) return NO;
			break;
		
		default:
		case RideRouteType_None:
			return NO;
	}

	// Update existing overlay with annotation or create new ones, if possible
	// NOTE: Overlays must always be re-added in order to trigger its view update properly
	MKPolyline* polyline = self.polylineMode == PolylineMode_Route ? [ride polylineWithRideRouteType:rideRouteType] : nil;
	ridePolyline = [RidePolyline ridePolyline:ridePolyline
								 withPolyline:polyline
									  andRide:ride
							 andRideRouteType:rideRouteType];
	if (!ridePolyline) return NO;
	[self.mainMapView addOverlay:ridePolyline level:MKOverlayLevelAboveLabels];
	if (wasRidePolylineInMapView && !didRemoveRidePolylineAnnotationFromMapView) {
		
		MKAnnotationView* ridePolylineAnnotationView = (MKAnnotationView*)[self.mainMapView viewForAnnotation:ridePolyline];
		if (ridePolylineAnnotationView) {
			
			[self configureRidePolylineAnnotationView:ridePolylineAnnotationView withRidePolylineAnnotation:ridePolyline];
		}
		
	} else {
		
		// NOTE: Automatically triggers new annotation view
		[self.mainMapView addAnnotation:ridePolyline];
	}
	
	return YES;
}


- (NSArray<RidePointAnnotation*>*)annotationsForRide:(Ride*)ride {
	
	return (NSArray<RidePointAnnotation*>*)[self.mainMapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id _Nonnull evaluatedObject, NSDictionary<NSString*,id>* _Nullable bindings) {
		
		return [evaluatedObject conformsToProtocol:@protocol(RideModelSource)] && ((id<RideModelSource>)evaluatedObject).ride == ride;
	}]];
}


+ (RidePointAnnotation*)getRidePointAnnotationFromRideAnnotations:(NSArray<id<MKAnnotation>>*)rideAnnotations andRideLocationType:(RideLocationType)rideLocationType {
	
	// Return first ride point annotation found of given ride location type
	// NOTE: Should be max 1
	for (id<MKAnnotation> rideAnnotation in rideAnnotations) {
		
		if (![rideAnnotation isKindOfClass:[RidePointAnnotation class]]) continue;
		
		RidePointAnnotation* ridePointAnnotation = (RidePointAnnotation*)rideAnnotation;
		
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


- (NSArray<id<MKOverlay>>*)overlaysForRide:(Ride*)ride {
	
	return [self.mainMapView.overlays filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString*,id>* _Nullable bindings) {
		
		return [evaluatedObject conformsToProtocol:@protocol(RideModelSource)] && ((id<RideModelSource>)evaluatedObject).ride == ride;
	}]];
}


+ (RidePolyline*)getRidePolylineFromRideOverlays:(NSArray<id<MKOverlay>>*)rideOverlays andRideRouteType:(RideRouteType)rideRouteType {
	
	// Return first ride polyline overlay found of given ride route type
	// NOTE: Should be max 1
	for (id<MKOverlay> rideOverlay in rideOverlays) {
		
		if (![rideOverlay isKindOfClass:[RidePolyline class]]) continue;
			
		RidePolyline* ridePolylineOverlay = (RidePolyline*)rideOverlay;
		if (ridePolylineOverlay.rideRouteType == rideRouteType) return ridePolylineOverlay;
	}
	
	return nil;
}


#
# pragma mark Team Notification Handlers
#


- (void)teamCreatedWithNotification:(NSNotification*)notification {
	
	[self configureTeamAnnotationsWithNotification:notification andOptions:Configure_None];
}


- (void)teamDeletedWithNotification:(NSNotification*)notification {
	
	if (self.teamDetailTableViewController.team == [Team teamFromNotification:notification]) {
		
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
	
	[self configureTeamAnnotationsWithNotification:notification andOptions:Configure_Delete];
	// NOTE: Overlays for teams are handled by assigned rides
}


- (void)teamUpdatedWithNotification:(NSNotification*)notification {
	
	[self configureTeamAnnotationsWithNotification:notification andOptions:Configure_None];
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
									  andOptions:(ConfigureOptions)options {
	
	Team* team = [Team teamFromNotification:notification];
	NSArray<TeamPointAnnotation*>* teamAnnotations = [self annotationsForTeam:team];
	
	// Configure annotation
	BOOL isLocationUpdated = [Team isUpdatedLocationFromNotification:notification];
	BOOL isMascotUpdated = [Team isUpdatedMascotFromNotification:notification];
	BOOL annotationPresent = [self configureViewWithTeam:team
									usingTeamAnnotations:teamAnnotations
									andIsLocationUpdated:isLocationUpdated
									  andIsMascotUpdated:isMascotUpdated
											  andOptions:options];
	
	return annotationPresent;
}


/*
 Configure team annotation and its view, consistent with given team
 Returns whether annotation is present
 */
- (BOOL)configureViewWithTeam:(Team*)team
		 usingTeamAnnotations:(NSArray<TeamPointAnnotation*>*)teamAnnotations
		 andIsLocationUpdated:(BOOL)isLocationUpdated
		   andIsMascotUpdated:(BOOL)isMascotUpdated
				   andOptions:(ConfigureOptions)options {
	
	TeamPointAnnotation* teamPointAnnotation = [MainMapViewController getTeamPointAnnotationFromTeamPointAnnotations:teamAnnotations];
	BOOL wasTeamPointAnnotationInMapView = (teamPointAnnotation != nil);
	BOOL wasTeamPointAnnotationSelected = (wasTeamPointAnnotationInMapView && teamPointAnnotation == self.mainMapView.selectedAnnotations.firstObject);
	
	// Remove existing annotation if location or mascot updated
	BOOL didRemoveAnnotationFromMapView = NO;
	if (isLocationUpdated || isMascotUpdated) {
		
		if (wasTeamPointAnnotationInMapView) {
			
			[self.mainMapView removeAnnotation:teamPointAnnotation];
			
			didRemoveAnnotationFromMapView = YES;
		}
	}
	
	// If deleting, we are done
	if (options & Configure_Delete) return NO;

	// If no location, we are done
	NSNumber* locationLatitude = team.locationCurrentLatitude;
	NSNumber* locationLongitude = team.locationCurrentLongitude;
	if (!locationLatitude || !locationLongitude) return NO;
	
	// Update existing annotation or create new one
	teamPointAnnotation = [TeamPointAnnotation teamPointAnnotation:teamPointAnnotation withTeam:team andNeedsAnimatesDrop:NO];
	if (wasTeamPointAnnotationInMapView && !didRemoveAnnotationFromMapView) {

		MKAnnotationView* teamAnnotationView = [self.mainMapView viewForAnnotation:teamPointAnnotation];
		if (teamAnnotationView) {
			
			[self configureTeamAnnotationView:teamAnnotationView withTeamPointAnnotation:teamPointAnnotation];
		}
		
	} else {
	
		// NOTE: Automatically triggers new annotation view
		[self.mainMapView addAnnotation:teamPointAnnotation];
	}
	
	if (options & Configure_Center) {
		
		[self.mainMapView setCenterCoordinate:CLLocationCoordinate2DMake(locationLatitude.doubleValue, locationLongitude.doubleValue) animated:YES];
	}
	
	if ((options & Configure_Select) || wasTeamPointAnnotationSelected) {
		
		[self.mainMapView selectAnnotation:teamPointAnnotation animated:YES];
	}
	
	return YES;
}


- (NSArray<TeamPointAnnotation*>*)annotationsForTeam:(Team*)team {
	
	return (NSArray<TeamPointAnnotation*>*)[self.mainMapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id _Nonnull evaluatedObject, NSDictionary<NSString*,id>* _Nullable bindings) {
		
		return [evaluatedObject conformsToProtocol:@protocol(TeamModelSource)] && ((id<TeamModelSource>)evaluatedObject).team == team;
	}]];
}


+ (TeamPointAnnotation*)getTeamPointAnnotationFromTeamPointAnnotations:(NSArray<TeamPointAnnotation*>*)annotations {
	
	// Return first annotation found
	// NOTE: Should be max 1
	return annotations.firstObject;
}


- (BOOL)isSelectedAnnotationForTeam:(Team*)team {
	
	if (!team) return NO;
	
	id<MKAnnotation> selectedAnnotation = self.mainMapView.selectedAnnotations.firstObject;
	
	return [selectedAnnotation conformsToProtocol:@protocol(TeamModelSource)] && ((id<TeamModelSource>)selectedAnnotation).team == team;
}


#
# pragma mark Command Handlers
#


/*
 * Handle command string
 * Returns whether command string was handled
 */
- (BOOL)handleCommandString:(NSString*)commandString {
	
	commandString = [commandString lowercaseString];
	
	BOOL isCommandHandled = NO;
	
	if ([COMMAND_HELP isEqualToString:commandString]) {
		
		NSString* message =
		[NSString stringWithFormat:
		 @"%@\n%@\n%@\n%@\n%@\n%@\n%@",
		 COMMAND_HELP,
		 COMMAND_SHOW_ALL,
		 COMMAND_DELETE_ALL,
		 COMMAND_DEMO,
		 COMMAND_DEMO_RIDES,
		 COMMAND_DEMO_TEAMS,
		 COMMAND_DEMO_ASSIGN
		 ];
		[Util presentOKAlertWithViewController:self andTitle:@"ORN Commands" andMessage:message];
		
		isCommandHandled = YES;
		
	} else if ([COMMAND_SHOW_ALL isEqualToString:commandString]) {
		
		[self showAllAnnotations];
		
		isCommandHandled = YES;
		
	} else if ([COMMAND_DELETE_ALL isEqualToString:commandString]) {
		
		UIAlertAction* deleteAllAlertAction = [UIAlertAction actionWithTitle:@"Delete All" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* _Nonnull action) {
			
			[Util removePersistentStore];
			[Util postNotificationDataModelResetWithSender:self];
		}];
		[Util presentActionAlertWithViewController:self andTitle:@"!!! Deletion Warning !!!" andMessage:@"About to delete all data, which cannot be undone! Are you absolutely sure?!" andAction:deleteAllAlertAction andCancelHandler:nil];

		isCommandHandled = YES;
		
	} else if ([COMMAND_DEMO isEqualToString:commandString]) {
		
		// Load all demo content
		
		[self configureJurisdictionRegionView];
		
		[DemoUtil loadDemoRides];
		[Util saveManagedObjectContext];
		
		[DemoUtil loadDemoTeams];
		[Util saveManagedObjectContext];

		// Delay assignment so that drop animations are not cancelled
		NSDictionary<NSString*,NSArray<__kindof NSManagedObject*>*>* args =
		@{
		  @"teams" : self.teamsFetchedResultsController.fetchedObjects,
		  @"rides" : self.ridesFetchedResultsController.fetchedObjects,
		  };
		[[DemoUtil class] performSelector:@selector(loadDemoAssignTeamsSelector:) withObject:args afterDelay:2.0];
		[Util saveManagedObjectContext];
		
		isCommandHandled = YES;
		
	} else if ([COMMAND_DEMO_RIDES isEqualToString:commandString]) {
		
		// Load all demo rides
		[self configureJurisdictionRegionView];
		[DemoUtil loadDemoRides];
		[Util saveManagedObjectContext];
		
		isCommandHandled = YES;
		
	} else if ([COMMAND_DEMO_TEAMS isEqualToString:commandString]) {
		
		// Load all demo teams
		[self configureJurisdictionRegionView];
		[DemoUtil loadDemoTeams];
		[Util saveManagedObjectContext];
		
		isCommandHandled = YES;
		
	} else if ([COMMAND_DEMO_ASSIGN isEqualToString:commandString]) {
		
		// Assign teams to rides
		[self configureJurisdictionRegionView];
		[DemoUtil loadDemoAssignTeams:self.teamsFetchedResultsController.fetchedObjects toRides:self.rideFetchedResultsController.fetchedObjects];
		[Util saveManagedObjectContext];
		
		isCommandHandled = YES;
	}
	
	if (isCommandHandled) {
		NSLog(@"Handled Command: %@", commandString);
	}
	
	return isCommandHandled;
}


#
# pragma mark Helpers
#


- (void)addNotificationObservers {
	
	[Util addDataModelResetObserver:self withSelector:@selector(dataModelResetWithNotification:)];

	[TeamAnnotationView addDragEndedObserver:self withSelector:@selector(annotationViewDragEndedWithNotification:)];
	
	[Ride addCreatedObserver:self withSelector:@selector(rideCreatedWithNotification:)];
	[Ride addDeletedObserver:self withSelector:@selector(rideDeletedWithNotification:)];
	[Ride addUpdatedObserver:self withSelector:@selector(rideUpdatedWithNotification:)];

	[Team addCreatedObserver:self withSelector:@selector(teamCreatedWithNotification:)];
	[Team addDeletedObserver:self withSelector:@selector(teamDeletedWithNotification:)];
	[Team addUpdatedObserver:self withSelector:@selector(teamUpdatedWithNotification:)];
}


- (void)configureView {
	
	// Add jurisdiction inverse overlay to map view
	[self configureJurisdictionBoundaryOverlay];
	
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
	
	for (Team* team in self.teamsFetchedResultsController.fetchedObjects) {
		
		[team postNotificationUpdatedWithSender:self andUpdatedLocation:YES];
	}
}


- (void)configureJurisdictionRegionViewWithAnimated:(BOOL)animated {
	
	// Center map view on jurisdiction region
	
	CLLocationCoordinate2D centerCoordinate = [MainMapViewController getJurisdictionPolygon].coordinate;
	
	MKCoordinateRegion centerRegion = MKCoordinateRegionMake(centerCoordinate, MKCoordinateSpanMake(MAP_SPAN_LOCATION_DELTA_CITY, MAP_SPAN_LOCATION_DELTA_CITY));
	
	[self.mainMapView setRegion:centerRegion animated:animated];
}


- (void)configureJurisdictionRegionView {
	
	[self configureJurisdictionRegionViewWithAnimated:YES];
}


- (void)configureJurisdictionBoundaryOverlay {

	// Add juridisdiction inverse overlay to map view
	
	CLLocationCoordinate2D worldCoords[6] =
	{
		{90, 0},
		{90, 180},
		{-90, 180},
		{-90, 0},
		{-90, -180},
		{90, -180},
	};
	
	MKPolygon* worldOverlay = [MKPolygon polygonWithCoordinates:worldCoords count:6 interiorPolygons:@[ [MainMapViewController getJurisdictionPolygon] ]];
	
	[self.mainMapView addOverlay:worldOverlay];
}


+ (MKPolygon*)getJurisdictionPolygon {
	
	// Create jurisdiction polygon
	CLLocationCoordinate2D jurisdictionCoords[10] =
	{
		{49.296597, -123.068810}, // Burrard Inlet, N end Commercial St
		{49.204041, -123.065377}, // River, S end Victoria St, E of Mitchell Island
		{49.196602, -123.012611}, // River, S end Boundary
		{49.173741, -122.959224}, // Annacis Channel,
		{49.220405, -122.871162}, // Fraser River, E of New West
		{49.221022, -122.770749}, // Douglas Island, Fraser River, S end of PoCo
		{49.292304, -122.660694}, // Pitt River, E of Coquitlam
		{49.352612, -122.624344}, // Siwash Island, Fraser River, E of Coquitlam
		{49.332423, -122.924207}, // Indian Arm, W of Porty Moody
		{49.296053, -122.950128}, // Burrard Inlet, N of Barnet Hwy, Burnaby
	};
	
	return [MKPolygon polygonWithCoordinates:jurisdictionCoords count:10];
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
