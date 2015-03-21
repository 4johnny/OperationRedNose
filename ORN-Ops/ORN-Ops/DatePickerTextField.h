//
//  DatePickerTextField.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-20.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePickerTextField.h"

#
# pragma mark - Interface
#

@interface DatePickerTextField : BasePickerTextField

@property (nonatomic) NSDate* date;

@property (nonatomic) NSInteger minuteInterval;
@property (nonatomic) NSDate* minimumDate;
@property (nonatomic) NSDate* maximumDate;
@property (nonatomic) NSLocale* locale;

@property (nonatomic) NSString* dateFormat;

@end
