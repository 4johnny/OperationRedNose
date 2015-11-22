//
//  UIFont+FontHelpers.h
//  ORN-Ops
//
//  Created by Johnny on 2015-11-21.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

#
# pragma mark - Interface
#

@interface UIFont (FontHelpers)

#
# pragma mark Methods
#

- (UIFont*)fontBolded;
- (UIFont*)fontUnbolded;

- (UIFont*)fontItalicized;
- (UIFont*)fontUnitalicized;

- (UIFont*)fontWithName:(NSString*)fontName;

#
# pragma mark Logging
#

#ifdef SMART_LOG_FONT

+ (void)logAllFonts;

#endif

@end
