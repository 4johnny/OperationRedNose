//
//  PickerTextField.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-17.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePickerTextField.h"

#
# pragma mark - Interface
#

@interface PickerTextField : BasePickerTextField <UIPickerViewDataSource, UIPickerViewDelegate>

#
# pragma mark Properties
#

@property (readonly, nonatomic) UIPickerView* pickerView; // decorated picker view

@property (nonatomic) NSArray<NSString*>* titles;
@property (nonatomic) NSArray<NSNumber*>* pickableStatuses;
@property (nonatomic) NSInteger selectedRow;
@property (nonatomic) NSInteger initialSelectedRow;

@end
