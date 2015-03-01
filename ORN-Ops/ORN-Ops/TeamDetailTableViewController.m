//
//  TeamDetailTableViewController.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "TeamDetailTableViewController.h"
#import "AppDelegate.h"


#
# pragma mark - Interface
#


@interface TeamDetailTableViewController ()

@end


#
# pragma mark - Implementation
#


@implementation TeamDetailTableViewController


#
# pragma mark UIViewController
#


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
# pragma mark Action Handlers
#


- (IBAction)savePressed:(UIBarButtonItem *)sender {
	
	[self.view endEditing:YES];

	
	//	[TeamDetailTableViewController saveManagedObjectContext];
	[self.navigationController popViewControllerAnimated:YES];
}


#
# pragma mark Helpers
#


+ (void)saveManagedObjectContext {
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate saveManagedObjectContext];
}


@end
