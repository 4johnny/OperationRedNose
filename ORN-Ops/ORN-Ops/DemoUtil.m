//
//  DemoUtil.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-26.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "DemoUtil.h"


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
	ride.donationAmount = [NSDecimalNumber decimalNumberWithString:@"3.50"];
	[ride updateLocationWithRideLocationType:RideLocationType_Start
								 andLatitude:49.287826
								andLongitude:-123.123834
								   andStreet:@"580 Bute St"
									 andCity:@"Vancouver"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride postNotificationCreatedWithSender:self];
	
	// Nowhere to Vancouver
//	ride = [Ride rideWithManagedObjectContext:moc];
//	ride.passengerNameFirst = @"Dina";
//	ride.passengerNameLast = @"Sable";
//	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
//	[ride updateLocationWithRideLocationType:RideLocationType_End
//								 andLatitude:49.2490447
//								andLongitude:-123.1001789
//								   andStreet:@"213 E King Edward Ave"
//									 andCity:@"Vancouver"
//									andState:BRITISH_COLUMBIA_STATE_CODE
//								  andAddress:nil];
//	[ride postNotificationCreatedWithSender:self];
	
	// Vancouver to Port Coquitlam
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Rob";
	ride.passengerNameLast = @"Jankovic";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	ride.donationAmount = [NSDecimalNumber decimalNumberWithString:@"20"];
	[ride updateLocationWithRideLocationType:RideLocationType_Start
								 andLatitude:49.2818704
								andLongitude:-123.1081611
								   andStreet:@"128 W Hastings St"
									 andCity:@"Vancouver"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride updateLocationWithRideLocationType:RideLocationType_End
								 andLatitude:49.271438
								andLongitude:-122.756615
								   andStreet:@"1523 Prairie Ave"
									 andCity:@"Port Coquitlam"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
	
	// Vancouver to Vancouver
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Joe";
	ride.passengerNameLast = @"Roberts";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	ride.donationAmount = [NSDecimalNumber decimalNumberWithString:@"15.00"];
	[ride updateLocationWithRideLocationType:RideLocationType_Start
								 andLatitude:49.27665770574511
								andLongitude:-123.0847680657702
								   andStreet:@"1 Venables St"
									 andCity:@"Vancouver"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride updateLocationWithRideLocationType:RideLocationType_End
								 andLatitude:49.2688777
								andLongitude:-123.0769722
								   andStreet:@"1750 Clark Dr"
									 andCity:@"Vancouver"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
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
	ride.donationAmount = [NSDecimalNumber zero];
	[ride updateLocationWithRideLocationType:RideLocationType_Start
								 andLatitude:49.24274
								andLongitude:-123.014073
								   andStreet:@"4078 Moscrop St"
									 andCity:@"Burnaby"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride updateLocationWithRideLocationType:RideLocationType_End
								 andLatitude:49.22162
								andLongitude:-122.979254
								   andStreet:@"5788 Kingsway"
									 andCity:@"Burnaby"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
	
	// Burnaby to Coquitlam
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Morris";
	ride.passengerNameLast = @"Sander";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	ride.donationAmount = [NSDecimalNumber one];
	[ride updateLocationWithRideLocationType:RideLocationType_Start
								 andLatitude:49.2660725
								andLongitude:-123.0024237
								   andStreet:@"4512 Lougheed Hwy"
									 andCity:@"Burnaby"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride updateLocationWithRideLocationType:RideLocationType_End
								 andLatitude:49.2407423
								andLongitude:-122.8527494
								   andStreet:@"1431 Brunette Ave"
									 andCity:@"Coquitlam"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
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
	ride.donationAmount = [NSDecimalNumber decimalNumberWithString:@"22"];
	[ride updateLocationWithRideLocationType:RideLocationType_Start
								 andLatitude:49.18302
								andLongitude:-122.953496
								   andStreet:@"1242 Ewen Ave"
									 andCity:@"New Westminster"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride updateLocationWithRideLocationType:RideLocationType_End
								 andLatitude:49.211765
								andLongitude:-122.924143
								   andStreet:@"615 8th St"
									 andCity:@"New Westminster"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
	
	// New Westminster to Burnaby
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Jeff";
	ride.passengerNameLast = @"Donofrio";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	ride.donationAmount = [NSDecimalNumber decimalNumberWithString:@"17"];
	[ride updateLocationWithRideLocationType:RideLocationType_Start
								 andLatitude:49.231407
								andLongitude:-122.893559
								   andStreet:@"308 Braid St"
									 andCity:@"New Westminster"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride updateLocationWithRideLocationType:RideLocationType_End
								 andLatitude:49.247717
								andLongitude:-122.941872
								   andStreet:@"4004 Lozells Ave"
									 andCity:@"Burnaby"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride tryUpdateMainRouteWithSender:self]; // async
	[ride postNotificationCreatedWithSender:self];
	
	// New Westminster to Port Moody
	ride = [Ride rideWithManagedObjectContext:moc];
	ride.passengerNameFirst = @"Adrianna";
	ride.passengerNameLast = @"Butler";
	ride.dateTimeStart = [NSDate dateRoundedToMinuteInterval:TIME_MINUTE_INTERVAL];
	ride.donationAmount = [NSDecimalNumber decimalNumberWithString:@"9"];
	[ride updateLocationWithRideLocationType:RideLocationType_Start
								 andLatitude:49.202296
								andLongitude:-122.9382
								   andStreet:@"1700 Stewardson Way"
									 andCity:@"New Westminster"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride updateLocationWithRideLocationType:RideLocationType_End
								 andLatitude:49.304498
								andLongitude:-122.830639
								   andStreet:@"131 Forest Park Way"
									 andCity:@"Port Moody"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
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
	ride.donationAmount = [NSDecimalNumber decimalNumberWithString:@"4.75"];
	[ride updateLocationWithRideLocationType:RideLocationType_Start
								 andLatitude:49.26374147501311
								andLongitude:-122.8691647300472
								   andStreet:@"949 Como Lake Ave"
									 andCity:@"Coquitlam"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride updateLocationWithRideLocationType:RideLocationType_End
								 andLatitude:49.257502
								andLongitude:-122.733142
								   andStreet:@"590 Dominion Ave"
									 andCity:@"Port Coquitlam"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
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
	ride.donationAmount = [NSDecimalNumber decimalNumberWithString:@"3.10"];
	[ride updateLocationWithRideLocationType:RideLocationType_Start
								 andLatitude:49.25625588056973
								andLongitude:-122.7782533932433
								   andStreet:@"2211 Central Ave"
									 andCity:@"Port Coquitlam"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride updateLocationWithRideLocationType:RideLocationType_End
								 andLatitude:49.2931232
								andLongitude:-122.7907818
								   andStreet:@"1330 Pinetree Way"
									 andCity:@"Coquitlam"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
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
	ride.donationAmount = [NSDecimalNumber decimalNumberWithString:@"8"];
	[ride updateLocationWithRideLocationType:RideLocationType_Start
								 andLatitude:49.30258801423837
								andLongitude:-122.8759178752116
								   andStreet:@"1970 Ioco Rd"
									 andCity:@"Port Moody"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
	[ride updateLocationWithRideLocationType:RideLocationType_End
								 andLatitude:49.27457909172165
								andLongitude:-122.8739446137635
								   andStreet:@"1000 Clarke Rd"
									 andCity:@"Port Moody"
									andState:BRITISH_COLUMBIA_STATE_CODE
								  andAddress:nil];
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
	team.teamID = @(1);
	team.members = @"Selma, Akbar, George";
	team.isMascot = @NO;
	team.isActive = @YES;
	[team updateCurrentLocationWithLatitude:49.284440
							   andLongitude:-123.121104
								  andStreet:@"1001 W Georgia St"
									andCity:@"Vancouver"
								   andState:BRITISH_COLUMBIA_STATE_CODE
								 andAddress:nil
									andTime:nil];

	[team postNotificationCreatedWithSender:self];
	
	team = [Team teamWithManagedObjectContext:moc];
	team.teamID = @(2);
	team.members = @"Matthew, Bethanie, Kelila";
	team.isMascot = @NO;
	team.isActive = @YES;
	[team updateCurrentLocationWithLatitude:49.265067
							   andLongitude:-123.069709
								  andStreet:@"2201 Commercial Dr"
									andCity:@"Vancouver"
								   andState:BRITISH_COLUMBIA_STATE_CODE
								 andAddress:nil
									andTime:nil];
	[team postNotificationCreatedWithSender:self];
}


+ (void)loadBurnabyDemoTeams {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
	
	team = [Team teamWithManagedObjectContext:moc];
	team.teamID = @(3);
	team.members = @"Cornel, Lucas, Kaylynn";
	team.isMascot = @NO;
	team.isActive = @YES;
	[team updateCurrentLocationWithLatitude:49.236999
							   andLongitude:-123.022298
								  andStreet:@"3730 Burke St"
									andCity:@"Burnaby"
								   andState:BRITISH_COLUMBIA_STATE_CODE
								 andAddress:nil
									andTime:nil];
	[team postNotificationCreatedWithSender:self];
	
	team = [Team teamWithManagedObjectContext:moc];
	team.teamID = @(4);
	team.members = @"Serena, Hector, Maciej";
	team.isMascot = @NO;
	team.isActive = @YES;
	[team updateCurrentLocationWithLatitude:49.253935
							   andLongitude:-122.989567
								  andStreet:@"4688 Canada Way"
									andCity:@"Burnaby"
								   andState:BRITISH_COLUMBIA_STATE_CODE
								 andAddress:nil
									andTime:nil];
	[team postNotificationCreatedWithSender:self];
}


+ (void)loadNewWestminsterDemoTeams {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
	
	team = [Team teamWithManagedObjectContext:moc];
	team.teamID = @(5);
	team.members = @"Lea, Mark, Terese";
	team.isMascot = @NO;
	team.isActive = @YES;
	[team updateCurrentLocationWithLatitude:49.208673
							   andLongitude:-122.945530
								  andStreet:@"934 17th St"
									andCity:@"New Westminster"
								   andState:BRITISH_COLUMBIA_STATE_CODE
								 andAddress:nil
									andTime:nil];
	[team postNotificationCreatedWithSender:self];
	
	team = [Team teamWithManagedObjectContext:moc];
	team.teamID = @(6);
	team.members = @"Greg, Désiré, Romana";
	team.isMascot = @NO;
	team.isActive = @YES;
	[team updateCurrentLocationWithLatitude:49.222551
							   andLongitude:-122.892918
								  andStreet:@"209 Columbia St E"
									andCity:@"New Westminster"
								   andState:BRITISH_COLUMBIA_STATE_CODE
								 andAddress:nil
									andTime:nil];
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
	team.teamID = @(7);
	team.members = @"Abe, Jarek, Larisa";
	team.isMascot = @YES;
	team.isActive = @YES;
	[team updateCurrentLocationWithLatitude:49.249167
							   andLongitude:-122.892760
								  andStreet:@"501 N Rd"
									andCity:@"Coquitlam"
								   andState:BRITISH_COLUMBIA_STATE_CODE
								 andAddress:nil
									andTime:nil];
	[team postNotificationCreatedWithSender:self];
	
	team = [Team teamWithManagedObjectContext:moc];
	team.teamID = @(8);
	team.members = @"Vera, Leonard, Ashley";
	team.isMascot = @NO;
	team.isActive = @YES;
	[team updateCurrentLocationWithLatitude:49.276118
							   andLongitude:-122.797337
								  andStreet:@"2991 Lougheed Hwy"
									andCity:@"Coquitlam"
								   andState:BRITISH_COLUMBIA_STATE_CODE
								 andAddress:nil
									andTime:nil];
	[team postNotificationCreatedWithSender:self];
}


+ (void)loadPortCoquitlamDemoTeams {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
	
	// NOTE: Team missing members
	team = [Team teamWithManagedObjectContext:moc];
	team.teamID = @(9);
	team.isMascot = @NO;
	team.isActive = @YES;
	[team updateCurrentLocationWithLatitude:49.253409
							   andLongitude:-122.764039
								  andStreet:@"13 McLean Ave"
									andCity:@"Port Coquitlam"
								   andState:BRITISH_COLUMBIA_STATE_CODE
								 andAddress:nil
									andTime:nil];
	[team postNotificationCreatedWithSender:self];
	
	team = [Team teamWithManagedObjectContext:moc];
	team.teamID = @(10);
	team.members = @"Martin, Jolene, Anatoly";
	team.isMascot = @NO;
	team.isActive = @YES;
	[team updateCurrentLocationWithLatitude:49.284196
							   andLongitude:-122.734451
								  andStreet:@"4016 Joseph Pl"
									andCity:@"Port Coquitlam"
								   andState:BRITISH_COLUMBIA_STATE_CODE
								 andAddress:nil
									andTime:nil];
	[team postNotificationCreatedWithSender:self];
}


+ (void)loadPortMoodyDemoTeams {
	
	NSManagedObjectContext* moc = [Util managedObjectContext];
	Team* team;
	
	// NOTE: Team missing members
	team = [Team teamWithManagedObjectContext:moc];
	team.teamID = @(11);
	team.isMascot = @NO;
	team.isActive = @YES;
	[team updateCurrentLocationWithLatitude:49.298383
							   andLongitude:-122.843201
								  andStreet:@"1300 David Ave"
									andCity:@"Port Moody"
								   andState:BRITISH_COLUMBIA_STATE_CODE
								 andAddress:nil
									andTime:nil];
	[team postNotificationCreatedWithSender:self];
}


#
# pragma mark Demo Assign
#


+ (void)loadDemoAssignTeams:(NSArray<Team*>*)teams toRides:(NSArray<Ride*>*)rides {
	
	// Assign specific teams to specific rides
	
	[rides[0] assignTeam:teams[0] withSender:self]; // Team with two rides
	[rides[1] assignTeam:teams[0] withSender:self]; // Team with two rides
	[rides[2] assignTeam:teams[1] withSender:self];
	[rides[3] assignTeam:teams[2] withSender:self];
	[rides[4] assignTeam:teams[3] withSender:self];
	[rides[5] assignTeam:teams[4] withSender:self]; // Team with two rides
	[rides[6] assignTeam:teams[4] withSender:self]; // Team with two rides
	[rides[7] assignTeam:teams[5] withSender:self];
	[rides[8] assignTeam:teams[10] withSender:self];
	[rides[9] assignTeam:teams[6] withSender:self];
	[rides[10] assignTeam:teams[8] withSender:self];
}


+ (void)loadDemoAssignTeamsSelector:(NSDictionary<NSString*,NSArray<__kindof NSManagedObject*>*>*)args {
	
	NSArray<Team*>* teams = args[@"teams"];
	NSArray<Ride*>* rides = args[@"rides"];
	
	[DemoUtil loadDemoAssignTeams:teams toRides:rides];
}


@end
