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


- (instancetype)initWithTeam:(Team*)team andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop {

	self = [super init];
	if (self) {
		
		_team = team;
		_needsAnimatesDrop = needsAnimatesDrop;

		self.coordinate = CLLocationCoordinate2DMake(_team.locationCurrentLatitude.doubleValue, _team.locationCurrentLongitude.doubleValue);
		
		NSString* teamTitle = [_team getTeamTitle];
		self.title = teamTitle && teamTitle.length > 0 ? teamTitle : TEAM_TITLE_DEFAULT;
		
		self.subtitle = _team.locationCurrentAddress;
	}
	
	return self;
}


- (instancetype)init {
	
	return [self initWithTeam:nil andNeedsAnimatesDrop:NO];
}


+ (instancetype)teamPointAnnotationWithTeam:(Team*)team andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop {
	
	return [[TeamPointAnnotation alloc] initWithTeam:team andNeedsAnimatesDrop:needsAnimatesDrop];
}


@end
