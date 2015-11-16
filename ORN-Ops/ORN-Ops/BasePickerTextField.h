//
//  BasePickerTextField.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-21.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

#
# pragma mark - Interface
#

@interface BasePickerTextField : UITextField <UITextFieldDelegate, UIPickerViewDelegate>

@property (nullable, nonatomic, weak) id<UITextFieldDelegate, UIPickerViewDelegate> delegate;

@end
