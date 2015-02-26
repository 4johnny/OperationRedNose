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
#import "Ride.h"


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


- (NSFetchedResultsController*)reviewsFetchedResultsController {
	
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


- (BOOL)textFieldShouldReturn:(UITextField*)textField {

	// User has hit keyboard return key
	// NOTE: Address is *not* empty due to "auto-enable" of return key
	
	[textField resignFirstResponder];

	[self configureViewWithAddressString:self.addressTextField.text];
	
	return NO; // NOTE: Do not perform default text-field behaviour
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

	// Configure pins and annotations for all existing rides
	
	
}


- (void)configureViewWithAddressString:(NSString*)addressString {

	// Geocode provided address string
	[self.geocoder geocodeAddressString:addressString completionHandler:^(NSArray* placemarks, NSError* error) {
		
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
		// Use first placemark to create annotation
		CLPlacemark* placemark = placemarks[0];
		NSLog(@"Geocode Location: %@", placemark.location);
		NSLog(@"Geocode Address: %@", placemark.addressDictionary);
		
		
		
		// Alert the user
		[self presentAlertWithTitle:@"Success" andMessage:@"Found placemark for address."];
	}];
}


- (void)presentAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
	
	self.okAlertController.title = title;
	self.okAlertController.message = message;
	
	[self presentViewController:self.okAlertController animated:YES completion:nil];
}


@end
