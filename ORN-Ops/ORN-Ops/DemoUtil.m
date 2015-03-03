//
//  DemoUtil.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "DemoUtil.h"
#import "Ride+RideHelpers.h"


#
# pragma mark - Implementation
#


@implementation DemoUtil


#
# pragma mark Demo Rides
#


+ (void)loadDemoRideDataModel:(NSManagedObjectContext*)managedObjectContext {
	
	[DemoUtil loadVancouverDemoRidesIntoDataModel:managedObjectContext];
	[DemoUtil loadBurnabyDemoRidesIntoDataModel:managedObjectContext];
	[DemoUtil loadNewWestminsterDemoRidesIntoDataModel:managedObjectContext];
	[DemoUtil loadTriCitiesDemoRidesIntoDataModel:managedObjectContext];
}


+ (void)loadVancouverDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {

	Ride* ride;

	// NOTE: Ride missing passenger info and end location
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.287826, -123.123834)
			   andLocationStartAddress:@"580 Bute St, Vancouver"
				  andLocationStartCity:@"Vancouver"];
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.2818704, -123.1081611)
			   andLocationStartAddress:@"128 W Hastings St, Vancouver"
				  andLocationStartCity:@"Vancouver"];
	ride.passengerNameFirst = @"Rob";
	ride.passengerNameLast = @"Smith";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.271438];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.756615];
	ride.locationEndAddress = @"1523 Prairie Ave, Port Coquitlam";
	ride.locationEndCity = @"Port Coquitlam";
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.27665770574511, -123.0847680657702)
			   andLocationStartAddress:@"1 Venables St, Vancouver"
				  andLocationStartCity:@"Vancouver"];
	ride.passengerNameFirst = @"Joe";
	ride.passengerNameLast = @"Roberts";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.2688777];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-123.0769722];
	ride.locationEndAddress = @"1750 Clark Dr, Vancouver";
	ride.locationEndCity = @"Vancouver";
}


+ (void)loadBurnabyDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {
	
	Ride* ride;
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.24274, -123.014073)
			   andLocationStartAddress:@"4078 Moscrop St, Burnaby"
				  andLocationStartCity:@"Burnaby"];
	ride.passengerNameFirst = @"Janet";
	ride.passengerNameLast = @"Peterson";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.22162];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.979254];
	ride.locationEndAddress = @"5788 Kingsway, Burnaby";
	ride.locationEndCity = @"Burnaby";
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.2660725, -123.0024237)
			   andLocationStartAddress:@"4512 Lougheed Hwy, Burnaby"
				  andLocationStartCity:@"Burnaby"];
	ride.passengerNameFirst = @"Billy";
	ride.passengerNameLast = @"Jean";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.2407423];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.8527494];
	ride.locationEndAddress = @"1431 Brunette Ave, Coquitlam";
	ride.locationEndCity = @"Coquitlam";
}


+ (void)loadNewWestminsterDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {
	
	Ride* ride;
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.18302, -122.953496)
			   andLocationStartAddress:@"1242 Ewen Ave, New Westminster"
				  andLocationStartCity:@"New Westminster"];
	ride.passengerNameFirst = @"Dorothy";
	ride.passengerNameLast = @"Kansas";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.211765];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.924143];
	ride.locationEndAddress = @"615 8th St, New Westminster";
	ride.locationEndCity = @"New Westminster";
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.231407, -122.893559)
			   andLocationStartAddress:@"308 Braid St, New Westminster"
				  andLocationStartCity:@"New Westminster"];
	ride.passengerNameFirst = @"Jeff";
	ride.passengerNameLast = @"Donofrio";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.247717];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.941872];
	ride.locationEndAddress = @"4004 Lozells Ave, Burnaby";
	ride.locationEndCity = @"Burnaby";
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.202296, -122.9382)
			   andLocationStartAddress:@"1700 Stewardson Way, New Westminster"
				  andLocationStartCity:@"New Westminster"];
	ride.passengerNameFirst = @"Twinkle";
	ride.passengerNameLast = @"Star";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.304498];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.830639];
	ride.locationEndAddress = @"131 Forest Park Way, Port Moody";
	ride.locationEndCity = @"Port Moody";
}


+ (void)loadTriCitiesDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {
 
	[DemoUtil loadCoquitlamDemoRidesIntoDataModel:managedObjectContext];
	[DemoUtil loadPortCoquitlamDemoRidesIntoDataModel:managedObjectContext];
	[DemoUtil loadPortMoodyDemoRidesIntoDataModel:managedObjectContext];
}


+ (void)loadCoquitlamDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {
	
	Ride* ride;
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.26374147501311, -122.8691647300472)
			   andLocationStartAddress:@"949 Como Lake Ave, Coquitlam"
				  andLocationStartCity:@"Coquitlam"];
	ride.passengerNameFirst = @"Danny";
	ride.passengerNameLast = @"Tao";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.257502];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.733142];
	ride.locationEndAddress = @"590 Dominion Ave, Port Coquitlam";
	ride.locationEndCity = @"Port Coquitlam";
}


+ (void)loadPortCoquitlamDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {
	
	Ride* ride;
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.25625588056973, -122.7782533932433)
			   andLocationStartAddress:@"2211 Central Ave, Port Coquitlam"
				  andLocationStartCity:@"Port Coquitlam"];
	ride.passengerNameFirst = @"Last";
	ride.passengerNameLast = @"Chance";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.2931232];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.7907818];
	ride.locationEndAddress = @"1330 Pinetree Way, Coquitlam";
	ride.locationEndCity = @"Coquitlam";
}


+ (void)loadPortMoodyDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {
	
	Ride* ride;
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.30258801423837, -122.8759178752116)
			   andLocationStartAddress:@"1970 Ioco Rd, Port Moody"
				  andLocationStartCity:@"Port Moody"];
	ride.passengerNameFirst = @"Johnny";
	ride.passengerNameLast = @"5";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.27457909172165];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.8739446137635];
	ride.locationEndAddress = @"1000 Clarke Rd, Port Moody";
	ride.locationEndCity = @"Port Moody";
}


#
# pragma mark Demo Teams
#


@end
