//
//  UIButton+ButtonHelpers.m
//  ORN-Ops
//
//  Created by Johnny on 2015-11-01.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#import "UIButton+ButtonHelpers.h"


#
# pragma mark - Constants
#

#define DOWN_ARROW_STRING	@"▼"


#
# pragma mark - Implementation
#


@implementation UIButton (ButtonHelpers)


#
# pragma mark Initializers
#


+ (instancetype)downArrowSystemButton {
	
	UIButton* downArrowButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[downArrowButton setTitle:DOWN_ARROW_STRING forState:UIControlStateNormal];
	
	return downArrowButton;
}


@end
