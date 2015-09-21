//
//  BaseNavigationController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-03-15.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "BaseNavigationController.h"


#
# pragma mark - Interface
#

@interface BaseNavigationController ()

@end


#
# pragma mark - Implementation
#


@implementation BaseNavigationController


#
# pragma mark UIViewController
#


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	
	NSLog(@"Warning: Memory Low");
}


/*
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#
# pragma mark <UIGestureRecognizerDelegate>
#


- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
	
	return YES;
}


#
# pragma Action Handlers
#


- (IBAction)navigationBarTapped:(UITapGestureRecognizer*)sender {
	
	[self.view endEditing:YES];
}


@end
