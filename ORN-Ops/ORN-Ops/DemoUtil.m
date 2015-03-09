//
//  DemoUtil.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "DemoUtil.h"
#import "Ride+RideHelpers.h"
#import "Team+TeamHelpers.h"


#
# pragma mark - Implementation
#


@implementation DemoUtil


#
# pragma mark Demo Rides
#


+ (void)loadDemoRidesIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	[DemoUtil loadVancouverDemoRidesIntoManagedObjectContext:managedObjectContext];
	[DemoUtil loadBurnabyDemoRidesIntoManagedObjectContext:managedObjectContext];
	[DemoUtil loadNewWestminsterDemoRidesIntoManagedObjectContext:managedObjectContext];
	[DemoUtil loadTriCitiesDemoRidesIntoManagedObjectContext:managedObjectContext];
}


+ (void)loadVancouverDemoRidesIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {

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
	ride.passengerNameLast = @"Jankovic";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.271438];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.756615];
	ride.locationEndAddress = @"1523 Prairie Ave, Port Coquitlam";
	ride.locationEndCity = @"Port Coquitlam";
	[ride calculateDateTimeEnd];
	
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
	[ride calculateDateTimeEnd];
}


+ (void)loadBurnabyDemoRidesIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
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
	[ride calculateDateTimeEnd];
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.2660725, -123.0024237)
			   andLocationStartAddress:@"4512 Lougheed Hwy, Burnaby"
				  andLocationStartCity:@"Burnaby"];
	ride.passengerNameFirst = @"Morris";
	ride.passengerNameLast = @"Sander";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.2407423];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.8527494];
	ride.locationEndAddress = @"1431 Brunette Ave, Coquitlam";
	ride.locationEndCity = @"Coquitlam";
	[ride calculateDateTimeEnd];
}


+ (void)loadNewWestminsterDemoRidesIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
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
	[ride calculateDateTimeEnd];
	
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
	[ride calculateDateTimeEnd];
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.202296, -122.9382)
			   andLocationStartAddress:@"1700 Stewardson Way, New Westminster"
				  andLocationStartCity:@"New Westminster"];
	ride.passengerNameFirst = @"Adrianna";
	ride.passengerNameLast = @"Butler";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.304498];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.830639];
	ride.locationEndAddress = @"131 Forest Park Way, Port Moody";
	ride.locationEndCity = @"Port Moody";
	[ride calculateDateTimeEnd];
}


+ (void)loadTriCitiesDemoRidesIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
 
	[DemoUtil loadCoquitlamDemoRidesIntoManagedObjectContext:managedObjectContext];
	[DemoUtil loadPortCoquitlamDemoRidesIntoManagedObjectContext:managedObjectContext];
	[DemoUtil loadPortMoodyDemoRidesIntoManagedObjectContext:managedObjectContext];
}


+ (void)loadCoquitlamDemoRidesIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
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
	[ride calculateDateTimeEnd];
}


+ (void)loadPortCoquitlamDemoRidesIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	Ride* ride;
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.25625588056973, -122.7782533932433)
			   andLocationStartAddress:@"2211 Central Ave, Port Coquitlam"
				  andLocationStartCity:@"Port Coquitlam"];
	ride.passengerNameFirst = @"Tara";
	ride.passengerNameLast = @"Hughes";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.2931232];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.7907818];
	ride.locationEndAddress = @"1330 Pinetree Way, Coquitlam";
	ride.locationEndCity = @"Coquitlam";
	[ride calculateDateTimeEnd];
}


+ (void)loadPortMoodyDemoRidesIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	Ride* ride;
	
	ride =
	[Ride rideWithManagedObjectContext:managedObjectContext
			andLocationStartCoordinate:CLLocationCoordinate2DMake(49.30258801423837, -122.8759178752116)
			   andLocationStartAddress:@"1970 Ioco Rd, Port Moody"
				  andLocationStartCity:@"Port Moody"];
	ride.passengerNameFirst = @"Farai";
	ride.passengerNameLast = @"Cole";
	ride.locationEndLatitude = [NSNumber numberWithDouble:49.27457909172165];
	ride.locationEndLongitude = [NSNumber numberWithDouble:-122.8739446137635];
	ride.locationEndAddress = @"1000 Clarke Rd, Port Moody";
	ride.locationEndCity = @"Port Moody";
	[ride calculateDateTimeEnd];
}


#
# pragma mark Demo Teams
#


+ (void)loadDemoTeamsIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	[DemoUtil loadVancouverDemoTeamsIntoManagedObjectContext:managedObjectContext];
	[DemoUtil loadBurnabyDemoTeamsIntoManagedObjectContext:managedObjectContext];
	[DemoUtil loadNewWestminsterDemoTeamsIntoManagedObjectContext:managedObjectContext];
	[DemoUtil loadTriCitiesDemoTeamsIntoManagedObjectContext:managedObjectContext];
}


+ (void)loadVancouverDemoTeamsIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {

	Team* team;

	team = [Team teamWithManagedObjectContext:managedObjectContext];
	team.name = @"1";
	team.members = @"Selma, Akbar, George";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.284440];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-123.121104];
	team.locationCurrentAddress = @"1001 W Georgia St, Vancouver";
	team.isActive = [NSNumber numberWithBool:YES];
	
	team = [Team teamWithManagedObjectContext:managedObjectContext];
	team.name = @"2";
	team.members = @"Matthew, Bethanie, Kelila";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.265067];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-123.069709];
	team.locationCurrentAddress = @"2201 Commercial Dr, Vancouver";
	team.isActive = [NSNumber numberWithBool:YES];
}


+ (void)loadBurnabyDemoTeamsIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	Team* team;
	
	team = [Team teamWithManagedObjectContext:managedObjectContext];
	team.name = @"3";
	team.members = @"Cornel, Lucas, Kaylynn";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.236999];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-123.022298];
	team.locationCurrentAddress = @"3730 Burke St, Burnaby";
	team.isActive = [NSNumber numberWithBool:YES];
	
	team = [Team teamWithManagedObjectContext:managedObjectContext];
	team.name = @"4";
	team.members = @"Serena, Hector, Maciej";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.253935];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.989567];
	team.locationCurrentAddress = @"4688 Canada Way, Burnaby";
	team.isActive = [NSNumber numberWithBool:YES];
}


+ (void)loadNewWestminsterDemoTeamsIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	Team* team;
	
	team = [Team teamWithManagedObjectContext:managedObjectContext];
	team.name = @"5";
	team.members = @"Lea, Mark, Terese";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.208673];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.945530];
	team.locationCurrentAddress = @"934 17th St, New Westminster";
	team.isActive = [NSNumber numberWithBool:YES];
	
	team = [Team teamWithManagedObjectContext:managedObjectContext];
	team.name = @"6";
	team.members = @"Greg, Désiré, Romana";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.222551];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.892918];
	team.locationCurrentAddress = @"209 Columbia St E";
	team.isActive = [NSNumber numberWithBool:YES];
}


+ (void)loadTriCitiesDemoTeamsIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	[DemoUtil loadCoquitlamDemoTeamsIntoManagedObjectContext:managedObjectContext];
	[DemoUtil loadPortCoquitlamDemoTeamsIntoManagedObjectContext:managedObjectContext];
	[DemoUtil loadPortMoodyDemoTeamsIntoManagedObjectContext:managedObjectContext];
}


+ (void)loadCoquitlamDemoTeamsIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {

	Team* team;
 
	// NOTE: Team is mascot
	team = [Team teamWithManagedObjectContext:managedObjectContext];
	team.name = @"7";
	team.members = @"Abe, Jarek, Larisa";
	team.isMascot = [NSNumber numberWithBool:YES];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.249167];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.892760];
	team.locationCurrentAddress = @"501 N Rd, Coquitlam";
	team.isActive = [NSNumber numberWithBool:YES];

	team = [Team teamWithManagedObjectContext:managedObjectContext];
	team.name = @"8";
	team.members = @"Vera, Leonard, Ashley";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.276118];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.797337];
	team.locationCurrentAddress = @"2991 Lougheed Hwy, Coquitlam";
	team.isActive = [NSNumber numberWithBool:YES];
}


+ (void)loadPortCoquitlamDemoTeamsIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	Team* team;
	
	// NOTE: Team missing members
	team = [Team teamWithManagedObjectContext:managedObjectContext];
	team.name = @"9";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.253409];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.764039];
	team.locationCurrentAddress = @"13 McLean Ave, Port Coquitlam";
	team.isActive = [NSNumber numberWithBool:YES];

	// NOTE: Team missing name
	team = [Team teamWithManagedObjectContext:managedObjectContext];
	team.members = @"Martin, Jolene, Anatoly";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.284196];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.734451];
	team.locationCurrentAddress = @"4016 Joseph Pl, Port Coquitlam";
	team.isActive = [NSNumber numberWithBool:YES];
}


+ (void)loadPortMoodyDemoTeamsIntoManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	
	Team* team;
	
	// NOTE: Team missing name and members
	team = [Team teamWithManagedObjectContext:managedObjectContext];
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.298383];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.843201];
	team.locationCurrentAddress = @"1300 David Ave, Port Moody";
	team.isActive = [NSNumber numberWithBool:YES];
}


#
# pragma mark Demo Assign
#


+ (void)loadDemoAssignTeams:(NSArray*)teams toRides:(NSArray*)rides {

	// Assign specific teams to specific rides
	
	[DemoUtil assignTeam:teams[2] toRide:rides[0]];
	[DemoUtil assignTeam:teams[2] toRide:rides[1]];
	[DemoUtil assignTeam:teams[3] toRide:rides[2]];
	[DemoUtil assignTeam:teams[4] toRide:rides[3]];
	[DemoUtil assignTeam:teams[5] toRide:rides[4]];
	[DemoUtil assignTeam:teams[6] toRide:rides[5]];
	[DemoUtil assignTeam:teams[7] toRide:rides[6]];
	[DemoUtil assignTeam:teams[6] toRide:rides[7]];
	[DemoUtil assignTeam:teams[8] toRide:rides[8]];
	[DemoUtil assignTeam:teams[10] toRide:rides[9]];
	[DemoUtil assignTeam:teams[0] toRide:rides[10]];
}


#
# pragma mark Helpers
#


+ (void)assignTeam:(Team*)team toRide:(Ride*)ride {

	ride.teamAssigned = team;
	[team addRidesAssignedObject:ride];
}


@end
