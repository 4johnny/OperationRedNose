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


#
# pragma mark - Constants
#

#define VANCOUVER_LATITUDE		49.25
#define VANCOUVER_LONGITUDE		-123.1
#define VANCOUVER_COORDINATE	CLLocationCoordinate2DMake(VANCOUVER_LATITUDE, VANCOUVER_LONGITUDE)
#define VANCOUVER_RADIUS		10000 // metres

#define MAP_SPAN_LOCATION_DELTA_NEIGHBOURHOOD	0.02 // degrees
#define MAP_SPAN_LOCATION_DELTA_CITY			0.2 // degrees
#define MAP_SPAN_LOCATION_DELTA_LOCALE			2.0 // degrees

#define COMMAND_HELP		@"ornhelp"
#define COMMAND_SHOW_ALL	@"ornshowall"
#define COMMAND_DEMO_MODE	@"orndemomode"


#
# pragma mark - Interface
#


@interface MainMapViewController ()

#
# pragma mark Properties
#

@property (strong, nonatomic) NSFetchedResultsController* rideFetchedResultsController;

@property (strong, nonatomic) CLGeocoder* geocoder;

@property (strong, nonatomic) UIAlertController* okAlertController;

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
	
	// Create fetch request for reviews
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Ride"];
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateTimeStart" ascending:NO]];
	//fetchRequest.predicate = [NSPredicate predicateWithFormat:@"movie.id == %@", self.movie.id];
	//fetchRequest.fetchBatchSize = PAGE_LIMIT;
	//fetchRequest.fetchLimit = PAGE_LIMIT;
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
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


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	
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

	// If command present, handle it and we are done
	if ([self handleCommandString:self.addressTextField.text]) {
		self.addressTextField.text = @"";
		return NO;
	}

	// Configure view with address string
	[self configureViewWithAddressString:self.addressTextField.text];
	
	return NO; // Do not perform default text-field behaviour
}


#
# pragma mark <MKMapViewDelegate>
#


//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//	
//	// NOTE: Called many times during scrolling, so keep code lightweight
//}
//
//
//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
//	
//}
//
//
//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//	
//	return nil;
//}
//
//
//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
//	
//	return nil;
//}


#
# pragma mark <ORNDataModelSource>
#


+ (void)saveManagedObjectContext {
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate saveManagedObjectContext];
}


#
# pragma mark Helpers
#


- (void)configureView {

	// Configure annotations and callouts for all existing rides
	
	for (Ride* ride in self.rideFetchedResultsController.fetchedObjects) {

		if (!(ride.locationStartLatitude.doubleValue < 0)) {
			
			[self.mainMapView addAnnotation:[RidePointAnnotation ridePointAnnotationWithRide:ride andRideLocationType:RideLocationType_Start]];
		}
		
		if (!(ride.locationEndLatitude.doubleValue < 0)) {
			
			[self.mainMapView addAnnotation:[RidePointAnnotation ridePointAnnotationWithRide:ride andRideLocationType:RideLocationType_End]];
		}
	}

	[self showAllAnnotations];
}


- (void)configureViewWithAddressString:(NSString*)addressString {

	// Geocode provided address string
	CLCircularRegion* vancouverRegion = [[CLCircularRegion alloc] initWithCenter:VANCOUVER_COORDINATE radius:VANCOUVER_RADIUS identifier:@"Vancouver Region"];
	[self.geocoder geocodeAddressString:addressString inRegion:vancouverRegion completionHandler:^(NSArray* placemarks, NSError* error) {
		
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
		[self.mainMapView showAnnotations:@[rideStartPointAnnotation] animated:YES];
		[self.mainMapView selectAnnotation:rideStartPointAnnotation animated:YES];
	}];
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


#
# pragma mark Demo
#


// Handle command string
// Returns whether command string was handled
- (BOOL)handleCommandString:(NSString*)commandString {

	BOOL handled = NO;
	
	if ([commandString isEqualToString:COMMAND_HELP]) {
		
		[self presentAlertWithTitle:@"ORN Commands"
						 andMessage:[NSString stringWithFormat:@"%@\n%@\n%@",
									 COMMAND_HELP,
									 COMMAND_SHOW_ALL,
									 COMMAND_DEMO_MODE
									 ]];
		handled = YES;
	}

	if ([commandString isEqualToString:COMMAND_DEMO_MODE]) {
		
		[self configureDemoRides];
		handled = YES;
	}
	
	if ([commandString isEqualToString:COMMAND_SHOW_ALL]) {
	
		[self clearAllAnnotationSelections];
		[self showAllAnnotations];
		handled = YES;
	}
	
	if (handled) {
		NSLog(@"Handled Command: %@", commandString);
	}
	
	return handled;
}


- (void)configureDemoRides {

	// Load demo rides into data model
	
	[Ride rideWithManagedObjectContext:self.managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.2818704, -123.1081611)
			   andLocationStartAddress:@"128 W Hastings St, Vancouver"
				  andLocationStartCity:@"Vancouver"];

	[Ride rideWithManagedObjectContext:self.managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.287826, -123.123834)
			   andLocationStartAddress:@"580 Bute St, Vancouver"
				  andLocationStartCity:@"Vancouver"];
	
	[Ride rideWithManagedObjectContext:self.managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.27665770574511, -123.0847680657702)
			   andLocationStartAddress:@"1 Venables St, Vancouver"
				  andLocationStartCity:@"Vancouver"];
	
	[Ride rideWithManagedObjectContext:self.managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.2688777, -123.0769722)
			   andLocationStartAddress:@"1750 Clark Dr, Vancouver"
				  andLocationStartCity:@"Vancouver"];
	
	// Mark refetch data model
	self.rideFetchedResultsController = nil;
	
	// Annotate demo rides on map view
	[self configureView];
}


@end