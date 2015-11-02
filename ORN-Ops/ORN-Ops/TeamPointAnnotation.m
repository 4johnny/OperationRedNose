//
//  TeamPointAnnotation.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-03.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "TeamPointAnnotation.h"


#
# pragma mark - Implementation
#


@implementation TeamPointAnnotation


#
# pragma mark Initializers
#


- (instancetype)initWithTeam:(Team*)team
		andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop {

	self = [super init];
	if (self) {
		
		self.team = team;
		self.needsAnimatesDrop = needsAnimatesDrop;
		
		self.coordinate = [_team getLocationCurrentCoordinate];
		self.title = [_team getTitle];
		self.subtitle = _team.locationCurrentAddress.length > 0
		? _team.locationCurrentAddress
		: (_team.locationCurrentLatitude && _team.locationCurrentLongitude
		   ? [NSString stringWithFormat:@"(%.7f,%.7f)", _team.locationCurrentLatitude.doubleValue, _team.locationCurrentLongitude.doubleValue]
		   : nil);
	}
	
	return self;
}


- (instancetype)init {
	
	return [self initWithTeam:nil andNeedsAnimatesDrop:NO];
}


+ (instancetype)teamPointAnnotationWithTeam:(Team*)team
					   andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop {
	
	return [[TeamPointAnnotation alloc] initWithTeam:team andNeedsAnimatesDrop:needsAnimatesDrop];
}


+ (instancetype)teamPointAnnotation:(TeamPointAnnotation*)teamPointAnnotation
						   withTeam:(Team*)team
			   andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop {

	return teamPointAnnotation
	? [teamPointAnnotation initWithTeam:team
				   andNeedsAnimatesDrop:needsAnimatesDrop]
	: [TeamPointAnnotation teamPointAnnotationWithTeam:team
								  andNeedsAnimatesDrop:needsAnimatesDrop];
}


//- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
//
//	[super setCoordinate:coordinate];
//}


@end
