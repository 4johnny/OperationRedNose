//
//  MainTabBarController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-24.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "MainTabBarController.h"


#
# pragma mark - Interface
#

@interface MainTabBarController ()

@end


#
# pragma mark - Implementation
#


@implementation MainTabBarController


#
# pragma mark UIResponder
#


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	
	[self.view endEditing:YES];
	
	[super touchesBegan:touches withEvent:event];
}


#
# pragma mark UIViewController
#


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	// Wire up delegate
	self.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	
	NSLog(@"Warning: Memory Low");
}


/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#
# pragma mark <UITabBarControllerDelegate>
#

/*
- (BOOL)tabBarController:(UITabBarController*)tabBarController shouldSelectViewController:(UIViewController*)viewController {
	
	return YES;
}


- (void)tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController {

	// Do nothing
}
*/


@end
