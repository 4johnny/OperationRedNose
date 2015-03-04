//
//  MainTabBarController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-24.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "MainTabBarController.h"
#import "AppDelegate.h"


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
# pragma mark UIViewController
#


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	// Wire up delegate
	self.delegate = self;
	
	// Inject data model for all loaded tabs
	// NOTE: All tabs in ORN tab bar are nav controllers
	for (UINavigationController* navigationViewController in self.viewControllers) {
		
		[self injectDataModelIntoNavigationController:navigationViewController];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#
# pragma mark - UIResponder
#


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	
	[self.view endEditing:YES];
	
	[super touchesBegan:touches withEvent:event];
}


#
# pragma mark <UITabBarControllerDelegate>
#


- (void)tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController {
	
	// Inject data model into selected view controller, in case created just in time
	// NOTE: All tabs in ORN tab bar are nav controllers
	[self injectDataModelIntoNavigationController:(UINavigationController*)viewController];
}


#
# pragma mark <ORNDataModelSource>
#


+ (void)saveManagedObjectContext {
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate saveManagedObjectContext];
}


#
# pragma mark Helpers
#

- (void)injectDataModelIntoNavigationController:(UINavigationController*)navigationController {
	
	// Inject data model into top view controller
	// NOTE: All tabs in ORN tab bar are nav controllers pointing to view controllers that implement ORN Data Model Source protocol
	// NOTE: If user previously drilled deeper into controller stack on this tab, we do not need to inject data model
	if ([navigationController.topViewController conformsToProtocol:@protocol(ORNDataModelSource)]) {
		
		((id<ORNDataModelSource>)navigationController.topViewController).managedObjectContext = self.managedObjectContext;
	}
}


@end
