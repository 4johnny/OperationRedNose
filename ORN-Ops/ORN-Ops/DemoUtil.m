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


+ (void)loadDemoRides {
	
	[DemoUtil loadVancouverDemoRides];
	[DemoUtil loadBurnabyDemoRides];
	[DemoUtil loadNewWestminsterDemoRides];
	[DemoUtil loadTriCitiesDemoRides];
}


+ (void)loadVancouverDemoRides {

	NSManagedObjectContext* moc = [Util managedObjectContext];
	Ride* ride;

	// NOTE: Ride missing passenger info and end location
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.dateTimeStart = [NSDate date];
	[ride updateLocationWithLatitude:49.287826
						 andLogitude:-123.123834
						  andAddress:@"580 Bute St, Vancouver"
							 andCity:@"Vancouver"
				 andRideLocationType:RideLocationType_Start];

	// Vancouver to Port Coquitlam
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Rob";
	ride.passengerNameLast = @"Jankovic";
	ride.dateTimeStart = [NSDate date];
	[ride updateLocationWithLatitude:49.2818704
						 andLogitude:-123.1081611
						  andAddress:@"128 W Hastings St, Vancouver"
							 andCity:@"Vancouver"
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.271438
						 andLogitude:-122.756615
						  andAddress:@"1523 Prairie Ave, Port Coquitlam"
							 andCity:@"Port Coquitlam"
				 andRideLocationType:RideLocationType_End];
	[ride calculateDateTimeEnd];
	
	// Vancouver to Vancouver
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Joe";
	ride.passengerNameLast = @"Roberts";
	ride.dateTimeStart = [NSDate date];
	[ride updateLocationWithLatitude:49.27665770574511
						 andLogitude:-123.0847680657702
						  andAddress:@"1 Venables St, Vancouver"
							 andCity:@"Vancouver"
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.2688777
						 andLogitude:-123.0769722
						  andAddress:@"1750 Clark Dr, Vancouver"
							 andCity:@"Vancouver"
				 andRideLocationType:RideLocationType_End];
	[ride calculateDateTimeEnd];
}


+ (void)loadBurnabyDemoRides {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Ride* ride;
	
	// Burnaby to Burnaby
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Janet";
	ride.passengerNameLast = @"Peterson";
	ride.dateTimeStart = [NSDate date];
	[ride updateLocationWithLatitude:49.24274
						 andLogitude:-123.014073
						  andAddress:@"4078 Moscrop St, Burnaby"
							 andCity:@"Burnaby"
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.22162
						 andLogitude:-122.979254
						  andAddress:@"5788 Kingsway, Burnaby"
							 andCity:@"Burnaby"
				 andRideLocationType:RideLocationType_End];
	[ride calculateDateTimeEnd];
	
	// Burnaby to Coquitlam
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Morris";
	ride.passengerNameLast = @"Sander";
	ride.dateTimeStart = [NSDate date];
	[ride updateLocationWithLatitude:49.2660725
						 andLogitude:-123.0024237
						  andAddress:@"4512 Lougheed Hwy, Burnaby"
							 andCity:@"Burnaby"
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.2407423
						 andLogitude:-122.8527494
						  andAddress:@"1431 Brunette Ave, Coquitlam"
							 andCity:@"Coquitlam"
				 andRideLocationType:RideLocationType_End];
	[ride calculateDateTimeEnd];
}


+ (void)loadNewWestminsterDemoRides {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Ride* ride;
	
	// New Westminster to New Westminster
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Dorothy";
	ride.passengerNameLast = @"Kansas";
	ride.dateTimeStart = [NSDate date];
	[ride updateLocationWithLatitude:49.18302
						 andLogitude:-122.953496
						  andAddress:@"1242 Ewen Ave, New Westminster"
							 andCity:@"New Westminster"
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.211765
						 andLogitude:-122.924143
						  andAddress:@"615 8th St, New Westminster"
							 andCity:@"New Westminster"
				 andRideLocationType:RideLocationType_End];
	[ride calculateDateTimeEnd];
	
	// New Westminster to Burnaby
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Jeff";
	ride.passengerNameLast = @"Donofrio";
	ride.dateTimeStart = [NSDate date];
	[ride updateLocationWithLatitude:49.231407
						 andLogitude:-122.893559
						  andAddress:@"308 Braid St, New Westminster"
							 andCity:@"New Westminster"
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.247717
						 andLogitude:-122.941872
						  andAddress:@"4004 Lozells Ave, Burnaby"
							 andCity:@"Burnaby"
				 andRideLocationType:RideLocationType_End];
	[ride calculateDateTimeEnd];
	
	// New Westminster to Port Moody
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Adrianna";
	ride.passengerNameLast = @"Butler";
	ride.dateTimeStart = [NSDate date];
	[ride updateLocationWithLatitude:49.202296
						 andLogitude:-122.9382
						  andAddress:@"1700 Stewardson Way, New Westminster"
							 andCity:@"New Westminster"
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.304498
						 andLogitude:-122.830639
						  andAddress:@"131 Forest Park Way, Port Moody"
							 andCity:@"Port Moody"
				 andRideLocationType:RideLocationType_End];
	[ride calculateDateTimeEnd];
}


+ (void)loadTriCitiesDemoRides {
 
	[DemoUtil loadCoquitlamDemoRides];
	[DemoUtil loadPortCoquitlamDemoRides];
	[DemoUtil loadPortMoodyDemoRides];
}


+ (void)loadCoquitlamDemoRides {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Ride* ride;
	
	// Coquitlam to Port Coquitlam
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Danny";
	ride.passengerNameLast = @"Tao";
	ride.dateTimeStart = [NSDate date];
	[ride updateLocationWithLatitude:49.26374147501311
						 andLogitude:-122.8691647300472
						  andAddress:@"949 Como Lake Ave, Coquitlam"
							 andCity:@"Coquitlam"
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.257502
						 andLogitude:-122.733142
						  andAddress:@"590 Dominion Ave, Port Coquitlam"
							 andCity:@"Port Coquitlam"
				 andRideLocationType:RideLocationType_End];
	[ride calculateDateTimeEnd];
}


+ (void)loadPortCoquitlamDemoRides {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Ride* ride;
	
	// Port Coquitlam to Coquitlam
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Tara";
	ride.passengerNameLast = @"Hughes";
	ride.dateTimeStart = [NSDate date];
	[ride updateLocationWithLatitude:49.25625588056973
						 andLogitude:-122.7782533932433
						  andAddress:@"2211 Central Ave, Port Coquitlam"
							 andCity:@"Port Coquitlam"
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.2931232
						 andLogitude:-122.7907818
						  andAddress:@"1330 Pinetree Way, Coquitlam"
							 andCity:@"Coquitlam"
				 andRideLocationType:RideLocationType_End];
	[ride calculateDateTimeEnd];
}


+ (void)loadPortMoodyDemoRides {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Ride* ride;

	// Port Moody to Port Moody
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Farai";
	ride.passengerNameLast = @"Cole";
	ride.dateTimeStart = [NSDate date];
	[ride updateLocationWithLatitude:49.30258801423837
						 andLogitude:-122.8759178752116
						  andAddress:@"1970 Ioco Rd, Port Moody"
							 andCity:@"Port Moody"
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.27457909172165
						 andLogitude:-122.8739446137635
						  andAddress:@"1000 Clarke Rd, Port Moody"
							 andCity:@"Port Moody"
				 andRideLocationType:RideLocationType_End];
	[ride calculateDateTimeEnd];
}


#
# pragma mark Demo Teams
#


+ (void)loadDemoTeams {
	
	[DemoUtil loadVancouverDemoTeams];
	[DemoUtil loadBurnabyDemoTeams];
	[DemoUtil loadNewWestminsterDemoTeams];
	[DemoUtil loadTriCitiesDemoTeams];
}


+ (void)loadVancouverDemoTeams {

	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;

	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"1";
	team.members = @"Selma, Akbar, George";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.284440];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-123.121104];
	team.locationCurrentAddress = @"1001 W Georgia St, Vancouver";
	team.isActive = [NSNumber numberWithBool:YES];
	
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"2";
	team.members = @"Matthew, Bethanie, Kelila";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.265067];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-123.069709];
	team.locationCurrentAddress = @"2201 Commercial Dr, Vancouver";
	team.isActive = [NSNumber numberWithBool:YES];
}


+ (void)loadBurnabyDemoTeams {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
	
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"3";
	team.members = @"Cornel, Lucas, Kaylynn";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.236999];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-123.022298];
	team.locationCurrentAddress = @"3730 Burke St, Burnaby";
	team.isActive = [NSNumber numberWithBool:YES];
	
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"4";
	team.members = @"Serena, Hector, Maciej";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.253935];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.989567];
	team.locationCurrentAddress = @"4688 Canada Way, Burnaby";
	team.isActive = [NSNumber numberWithBool:YES];
}


+ (void)loadNewWestminsterDemoTeams {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
	
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"5";
	team.members = @"Lea, Mark, Terese";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.208673];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.945530];
	team.locationCurrentAddress = @"934 17th St, New Westminster";
	team.isActive = [NSNumber numberWithBool:YES];
	
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"6";
	team.members = @"Greg, Désiré, Romana";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.222551];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.892918];
	team.locationCurrentAddress = @"209 Columbia St E";
	team.isActive = [NSNumber numberWithBool:YES];
}


+ (void)loadTriCitiesDemoTeams {
	
	[DemoUtil loadCoquitlamDemoTeams];
	[DemoUtil loadPortCoquitlamDemoTeams];
	[DemoUtil loadPortMoodyDemoTeams];
}


+ (void)loadCoquitlamDemoTeams {

	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
 
	// NOTE: Team is mascot
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"7";
	team.members = @"Abe, Jarek, Larisa";
	team.isMascot = [NSNumber numberWithBool:YES];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.249167];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.892760];
	team.locationCurrentAddress = @"501 N Rd, Coquitlam";
	team.isActive = [NSNumber numberWithBool:YES];

	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"8";
	team.members = @"Vera, Leonard, Ashley";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.276118];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.797337];
	team.locationCurrentAddress = @"2991 Lougheed Hwy, Coquitlam";
	team.isActive = [NSNumber numberWithBool:YES];
}


+ (void)loadPortCoquitlamDemoTeams {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
	
	// NOTE: Team missing members
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"9";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.253409];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.764039];
	team.locationCurrentAddress = @"13 McLean Ave, Port Coquitlam";
	team.isActive = [NSNumber numberWithBool:YES];

	// NOTE: Team missing name
	team = [Team teamWithManagedObjectContext:moc];
	team.members = @"Martin, Jolene, Anatoly";
	team.isMascot = [NSNumber numberWithBool:NO];
	team.locationCurrentLatitude = [NSNumber numberWithDouble:49.284196];
	team.locationCurrentLongitude = [NSNumber numberWithDouble:-122.734451];
	team.locationCurrentAddress = @"4016 Joseph Pl, Port Coquitlam";
	team.isActive = [NSNumber numberWithBool:YES];
}


+ (void)loadPortMoodyDemoTeams {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
	
	// NOTE: Team missing name and members
	team = [Team teamWithManagedObjectContext:moc];
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
