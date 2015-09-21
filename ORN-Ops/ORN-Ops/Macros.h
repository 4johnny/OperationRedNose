//
//  Macros.h
//  ORN-Ops
//
//  Created by Johnny on 2015-09-20.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#ifndef ORN_Ops_Macros_h
#define ORN_Ops_Macros_h


#
# pragma mark - Constants
#

#define CG_SIZE_MAX		CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)

#define SECONDS_PER_MINUTE		60
#define METERS_PER_KILOMETER	1000

#
# pragma mark Color Macros
#

#define RGBA(r, g, b, a)	[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define RGB(r, g, b)		RGBA(r, g, b, 1.0)

#define HSBA(h, s, b, a)	[UIColor colorWithHue:(h)/360.0 saturation:(s) brightness:(b) alpha:(a)]
#define HSB(h, s, b)		HSBA(h, s, b, 1.0)


#endif
