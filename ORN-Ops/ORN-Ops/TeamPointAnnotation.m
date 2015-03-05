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


- (instancetype)initWithTeam:(Team*)team andNeedsAnimation:(BOOL)needsAnimation {

	self = [super init];
	if (self) {
		
		_team = team;
		_needsAnimation = needsAnimation;

		self.coordinate = CLLocationCoordinate2DMake(_team.locationCurrentLatitude.doubleValue, _team.locationCurrentLongitude.doubleValue);
		NSString* titlePrefix = @"Team";
		
		titlePrefix = (_team.name && _team.name.length > 0) ? [NSString stringWithFormat:@"%@: %@", titlePrefix, _team.name] : titlePrefix;
		
		self.title = (_team.members && _team.members.length > 0) ? [NSString stringWithFormat:@"%@: %@", titlePrefix, _team.members] : titlePrefix;
		
		self.subtitle = _team.locationCurrentAddress;
	}
	
	return self;
}


- (instancetype)init {
	
	return [self initWithTeam:nil andNeedsAnimation:NO];
}


+ (instancetype)teamPointAnnotationWithTeam:(Team*)team andNeedsAnimation:(BOOL)needsAnimation {
	
	return [[TeamPointAnnotation alloc] initWithTeam:team andNeedsAnimation:needsAnimation];
}


@end
