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
	
	Ride* ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.2818704, -123.1081611)
			   andLocationStartAddress:@"128 W Hastings St, Vancouver"
				  andLocationStartCity:@"Vancouver"];
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.287826];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-123.123834];
	ride.locationEndAddress = @"580 Bute St, Vancouver";
	ride.locationEndCity = @"Vancouver";
	
//	[Ride rideWithManagedObjectContext:managedObjectContext
//			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.287826, -123.123834)
//			   andLocationStartAddress:@"580 Bute St, Vancouver"
//				  andLocationStartCity:@"Vancouver"];
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.27665770574511, -123.0847680657702)
			   andLocationStartAddress:@"1 Venables St, Vancouver"
				  andLocationStartCity:@"Vancouver"];
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.2688777, -123.0769722)
			   andLocationStartAddress:@"1750 Clark Dr, Vancouver"
				  andLocationStartCity:@"Vancouver"];
}


+ (void)loadBurnabyDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.2660725, -123.0024237)
			   andLocationStartAddress:@"4512 Lougheed Hwy, Burnaby"
				  andLocationStartCity:@"Burnaby"];
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.24274, -123.014073)
			   andLocationStartAddress:@"4078 Moscrop St, Burnaby"
				  andLocationStartCity:@"Burnaby"];
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.247717, -122.941872)
			   andLocationStartAddress:@"4004 Lozells Ave, Burnaby"
				  andLocationStartCity:@"Burnaby"];
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.22162, -122.979254)
			   andLocationStartAddress:@"5788 Kingsway, Burnaby"
				  andLocationStartCity:@"Burnaby"];
}


+ (void)loadNewWestminsterDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.18302, -122.953496)
			   andLocationStartAddress:@"1242 Ewen Ave, New Westminster"
				  andLocationStartCity:@"New Westminster"];
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.231407, -122.893559)
			   andLocationStartAddress:@"308 Braid St, New Westminster"
				  andLocationStartCity:@"New Westminster"];
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.211765, -122.924143)
			   andLocationStartAddress:@"615 8th St, New Westminster"
				  andLocationStartCity:@"New Westminster"];
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.202296, -122.9382)
			   andLocationStartAddress:@"1700 Stewardson Way, New Westminster"
				  andLocationStartCity:@"New Westminster"];
}


+ (void)loadTriCitiesDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {
 
	[DemoUtil loadCoquitlamDemoRidesIntoDataModel:managedObjectContext];
	[DemoUtil loadPortCoquitlamDemoRidesIntoDataModel:managedObjectContext];
	[DemoUtil loadPortMoodyDemoRidesIntoDataModel:managedObjectContext];
}


+ (void)loadCoquitlamDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {

	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.26374147501311, -122.8691647300472)
			   andLocationStartAddress:@"949 Como Lake Ave, Coquitlam"
				  andLocationStartCity:@"Coquitlam"];
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.2931232, -122.7907818)
			   andLocationStartAddress:@"1330 Pinetree Way, Coquitlam"
				  andLocationStartCity:@"Coquitlam"];
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.2407423, -122.8527494)
			   andLocationStartAddress:@"1431 Brunette Ave, Coquitlam"
				  andLocationStartCity:@"Coquitlam"];
}
	

+ (void)loadPortCoquitlamDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {

	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.25625588056973, -122.7782533932433)
			   andLocationStartAddress:@"2211 Central Ave, Port Coquitlam"
				  andLocationStartCity:@"Port Coquitlam"];
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.271438, -122.756615)
			   andLocationStartAddress:@"1523 Prairie Ave, Port Coquitlam"
				  andLocationStartCity:@"Port Coquitlam"];

	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.257502, -122.733142)
			   andLocationStartAddress:@"590 Dominion Ave, Port Coquitlam"
				  andLocationStartCity:@"Port Coquitlam"];
}


+ (void)loadPortMoodyDemoRidesIntoDataModel:(NSManagedObjectContext*)managedObjectContext {

	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.30258801423837, -122.8759178752116)
			   andLocationStartAddress:@"1970 Ioco Rd, Port Moody"
				  andLocationStartCity:@"Port Moody"];

	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.27457909172165, -122.8739446137635)
			   andLocationStartAddress:@"1000 Clarke Rd, Port Moody"
				  andLocationStartCity:@"Port Moody"];
	
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.304498, -122.830639)
			   andLocationStartAddress:@"131 Forest Park Way, Port Moody"
				  andLocationStartCity:@"Port Moody"];
}


#
# pragma mark Demo Teams
#


@end
