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


// NOTE: Caller is responsible for saving to persistent store


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
	
	// Vancouver to nowhere - also missing passenger info
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	[ride updateLocationWithLatitude:49.287826
						andLongitude:-123.123834
						   andStreet:@"580 Bute St"
							 andCity:@"Vancouver"
							 andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_Start];
	[ride postNotificationCreatedWithSender:self];
	
	// Vancouver to Port Coquitlam
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Rob";
	ride.passengerNameLast = @"Jankovic";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	[ride updateLocationWithLatitude:49.2818704
						andLongitude:-123.1081611
						   andStreet:@"128 W Hastings St"
							 andCity:@"Vancouver"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.271438
						andLongitude:-122.756615
						   andStreet:@"1523 Prairie Ave"
							 andCity:@"Port Coquitlam"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_End];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
	
	// Vancouver to Vancouver
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Joe";
	ride.passengerNameLast = @"Roberts";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	[ride updateLocationWithLatitude:49.27665770574511
						andLongitude:-123.0847680657702
						   andStreet:@"1 Venables St"
							 andCity:@"Vancouver"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.2688777
						andLongitude:-123.0769722
						   andStreet:@"1750 Clark Dr"
							 andCity:@"Vancouver"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_End];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
}


+ (void)loadBurnabyDemoRides {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Ride* ride;
	
	// Burnaby to Burnaby
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Janet";
	ride.passengerNameLast = @"Peterson";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	[ride updateLocationWithLatitude:49.24274
						andLongitude:-123.014073
						   andStreet:@"4078 Moscrop St"
							 andCity:@"Burnaby"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.22162
						andLongitude:-122.979254
						   andStreet:@"5788 Kingsway"
							 andCity:@"Burnaby"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_End];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
	
	// Burnaby to Coquitlam
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Morris";
	ride.passengerNameLast = @"Sander";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	[ride updateLocationWithLatitude:49.2660725
						andLongitude:-123.0024237
						   andStreet:@"4512 Lougheed Hwy"
							 andCity:@"Burnaby"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.2407423
						andLongitude:-122.8527494
						   andStreet:@"1431 Brunette Ave"
							 andCity:@"Coquitlam"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_End];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
}


+ (void)loadNewWestminsterDemoRides {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Ride* ride;
	
	// New Westminster to New Westminster
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Dorothy";
	ride.passengerNameLast = @"Kansas";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	[ride updateLocationWithLatitude:49.18302
						andLongitude:-122.953496
						   andStreet:@"1242 Ewen Ave"
							 andCity:@"New Westminster"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.211765
						andLongitude:-122.924143
						   andStreet:@"615 8th St"
							 andCity:@"New Westminster"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_End];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
	
	// New Westminster to Burnaby
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Jeff";
	ride.passengerNameLast = @"Donofrio";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	[ride updateLocationWithLatitude:49.231407
						andLongitude:-122.893559
						   andStreet:@"308 Braid St"
							 andCity:@"New Westminster"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.247717
						andLongitude:-122.941872
						   andStreet:@"4004 Lozells Ave"
							 andCity:@"Burnaby"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_End];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
	
	// New Westminster to Port Moody
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Adrianna";
	ride.passengerNameLast = @"Butler";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	[ride updateLocationWithLatitude:49.202296
						andLongitude:-122.9382
						  andStreet:@"1700 Stewardson Way"
							 andCity:@"New Westminster"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.304498
						andLongitude:-122.830639
						   andStreet:@"131 Forest Park Way"
							 andCity:@"Port Moody"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_End];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
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
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	[ride updateLocationWithLatitude:49.26374147501311
						andLongitude:-122.8691647300472
						   andStreet:@"949 Como Lake Ave"
							 andCity:@"Coquitlam"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.257502
						andLongitude:-122.733142
						   andStreet:@"590 Dominion Ave"
							 andCity:@"Port Coquitlam"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_End];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
}


+ (void)loadPortCoquitlamDemoRides {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Ride* ride;
	
	// Port Coquitlam to Coquitlam
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Tara";
	ride.passengerNameLast = @"Hughes";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	[ride updateLocationWithLatitude:49.25625588056973
						andLongitude:-122.7782533932433
						   andStreet:@"2211 Central Ave"
							 andCity:@"Port Coquitlam"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.2931232
						andLongitude:-122.7907818
						   andStreet:@"1330 Pinetree Way"
							 andCity:@"Coquitlam"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_End];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
}


+ (void)loadPortMoodyDemoRides {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Ride* ride;
	
	// Port Moody to Port Moody
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Farai";
	ride.passengerNameLast = @"Cole";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	[ride updateLocationWithLatitude:49.30258801423837
						andLongitude:-122.8759178752116
						   andStreet:@"1970 Ioco Rd"
							 andCity:@"Port Moody"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_Start];
	[ride updateLocationWithLatitude:49.27457909172165
						andLongitude:-122.8739446137635
						   andStreet:@"1000 Clarke Rd"
							 andCity:@"Port Moody"
							andState:BRITISH_COLUMBIA_STATE_CODE
						  andAddress:nil
				 andRideLocationType:RideLocationType_End];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
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
	team.isMascot = @NO;
	team.locationCurrentLatitude = @49.284440;
	team.locationCurrentLongitude = @-123.121104;
	team.locationCurrentAddress = @"1001 W Georgia St, Vancouver";
	team.locationCurrentCity = @"Vancouver";
	team.isActive = @YES;
	[team postNotificationCreatedWithSender:self];
	
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"2";
	team.members = @"Matthew, Bethanie, Kelila";
	team.isMascot = @NO;
	team.locationCurrentLatitude = @49.265067;
	team.locationCurrentLongitude = @-123.069709;
	team.locationCurrentAddress = @"2201 Commercial Dr, Vancouver";
	team.locationCurrentCity = @"Vancouver";
	team.isActive = @YES;
	[team postNotificationCreatedWithSender:self];
}


+ (void)loadBurnabyDemoTeams {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
	
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"3";
	team.members = @"Cornel, Lucas, Kaylynn";
	team.isMascot = @NO;
	team.locationCurrentLatitude = @49.236999;
	team.locationCurrentLongitude = @-123.022298;
	team.locationCurrentAddress = @"3730 Burke St, Burnaby";
	team.locationCurrentCity = @"Burnaby";
	team.isActive = @YES;
	[team postNotificationCreatedWithSender:self];
	
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"4";
	team.members = @"Serena, Hector, Maciej";
	team.isMascot = @NO;
	team.locationCurrentLatitude = @49.253935;
	team.locationCurrentLongitude = @-122.989567;
	team.locationCurrentAddress = @"4688 Canada Way, Burnaby";
	team.locationCurrentCity = @"Burnaby";
	team.isActive = @YES;
	[team postNotificationCreatedWithSender:self];
}


+ (void)loadNewWestminsterDemoTeams {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
	
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"5";
	team.members = @"Lea, Mark, Terese";
	team.isMascot = @NO;
	team.locationCurrentLatitude = @49.208673;
	team.locationCurrentLongitude = @-122.945530;
	team.locationCurrentAddress = @"934 17th St, New Westminster";
	team.locationCurrentCity = @"New Westminster";
	team.isActive = @YES;
	[team postNotificationCreatedWithSender:self];
	
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"6";
	team.members = @"Greg, Désiré, Romana";
	team.isMascot = @NO;
	team.locationCurrentLatitude = @49.222551;
	team.locationCurrentLongitude = @-122.892918;
	team.locationCurrentAddress = @"209 Columbia St E, New Westminster";
	team.locationCurrentCity = @"New Westminster";
	team.isActive = @YES;
	[team postNotificationCreatedWithSender:self];
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
	team.isMascot = @YES;
	team.locationCurrentLatitude = @49.249167;
	team.locationCurrentLongitude = @-122.892760;
	team.locationCurrentAddress = @"501 N Rd, Coquitlam";
	team.locationCurrentCity = @"Coquitlam";
	team.isActive = @YES;
	[team postNotificationCreatedWithSender:self];
	
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"8";
	team.members = @"Vera, Leonard, Ashley";
	team.isMascot = @NO;
	team.locationCurrentLatitude = @49.276118;
	team.locationCurrentLongitude = @-122.797337;
	team.locationCurrentAddress = @"2991 Lougheed Hwy, Coquitlam";
	team.locationCurrentCity = @"Coquitlam";
	team.isActive = @YES;
	[team postNotificationCreatedWithSender:self];
}


+ (void)loadPortCoquitlamDemoTeams {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
	
	// NOTE: Team missing members
	team = [Team teamWithManagedObjectContext:moc];
	team.name = @"9";
	team.isMascot = @NO;
	team.locationCurrentLatitude = @49.253409;
	team.locationCurrentLongitude = @-122.764039;
	team.locationCurrentAddress = @"13 McLean Ave, Port Coquitlam";
	team.locationCurrentCity = @"Port Coquitlam";
	team.isActive = @YES;
	[team postNotificationCreatedWithSender:self];
	
	// NOTE: Team missing name
	team = [Team teamWithManagedObjectContext:moc];
	team.members = @"Martin, Jolene, Anatoly";
	team.isMascot = @NO;
	team.locationCurrentLatitude = @49.284196;
	team.locationCurrentLongitude = @-122.734451;
	team.locationCurrentAddress = @"4016 Joseph Pl, Port Coquitlam";
	team.locationCurrentCity = @"Port Coquitlam";
	team.isActive = @YES;
	[team postNotificationCreatedWithSender:self];
}


+ (void)loadPortMoodyDemoTeams {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
	
	// NOTE: Team missing name and members
	team = [Team teamWithManagedObjectContext:moc];
	team.isMascot = @NO;
	team.locationCurrentLatitude = @49.298383;
	team.locationCurrentLongitude = @-122.843201;
	team.locationCurrentAddress = @"1300 David Ave, Port Moody";
	team.locationCurrentCity = @"Port Moody";
	team.isActive = @YES;
	[team postNotificationCreatedWithSender:self];
}


#
# pragma mark Demo Assign
#


+ (void)loadDemoAssignTeams:(NSArray*)teams toRides:(NSArray*)rides {
	
	// Assign specific teams to specific rides
	
	[rides[0] assignTeam:teams[2] withSender:self]; // Team with two rides
	[rides[1] assignTeam:teams[2] withSender:self]; // Team with two rides
	[rides[2] assignTeam:teams[3] withSender:self];
	[rides[3] assignTeam:teams[4] withSender:self];
	[rides[4] assignTeam:teams[5] withSender:self];
	[rides[5] assignTeam:teams[6] withSender:self]; // Team with two rides
	[rides[6] assignTeam:teams[6] withSender:self]; // Team with two rides
	[rides[7] assignTeam:teams[7] withSender:self];
	[rides[8] assignTeam:teams[0] withSender:self];
	[rides[9] assignTeam:teams[8] withSender:self];
	[rides[10] assignTeam:teams[10] withSender:self];
}


+ (void)loadDemoAssignTeamsSelector:(NSDictionary*)args {
	
	NSArray* teams = args[@"teams"];
	NSArray* rides = args[@"rides"];
	
	[DemoUtil loadDemoAssignTeams:teams toRides:rides];
}


@end
