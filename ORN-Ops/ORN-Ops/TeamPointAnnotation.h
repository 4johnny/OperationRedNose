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
# pragma mark - Interface
#

@interface TeamPointAnnotation : MKPointAnnotation

#
# pragma mark Properties
#

// TODO: Consider whether team property should be weak
@property (nonatomic) Team* team;
@property (nonatomic) BOOL needsAnimation;

#
# pragma mark Initializers
#

- (instancetype)initWithTeam:(Team*)team andNeedsAnimation:(BOOL)needsAnimation;
- (instancetype)init;

+ (instancetype)teamPointAnnotationWithTeam:(Team*)team andNeedsAnimation:(BOOL)needsAnimation;

@end
