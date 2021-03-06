//
//  TeamPointAnnotation.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-03.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Team+TeamHelpers.h"


#
# pragma mark - Constants
#

#define TEAM_NORMAL_ANNOTATION_ID	@"teamNormalAnnotation"
#define TEAM_MASCOT_ANNOTATION_ID	@"teamMascotAnnotation"

#
# pragma mark - Interface
#

@interface TeamPointAnnotation : MKPointAnnotation <TeamModelSource>

#
# pragma mark Properties
#

@property (weak, nonatomic) Team* team;
@property (nonatomic) BOOL needsAnimatesDrop;

#
# pragma mark Initializers
#

- (instancetype)initWithTeam:(Team*)team
		andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop;

- (instancetype)init;

+ (instancetype)teamPointAnnotationWithTeam:(Team*)team
					   andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop;

+ (instancetype)teamPointAnnotation:(TeamPointAnnotation*)teamPointAnnotation
						   withTeam:(Team*)team
			   andNeedsAnimatesDrop:(BOOL)needsAnimatesDrop;

@end
