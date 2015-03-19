//
//  PickerTextField.h
//  ORN-Ops
//
//  Created by Johnny on 2015-03-17.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

#
# pragma mark - Interface
#

@interface PickerTextField : UITextField <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

#
# pragma mark Properties
#

@property (nonatomic) NSArray* titles; // NSString
@property (nonatomic) NSInteger selectedRow;

@end
