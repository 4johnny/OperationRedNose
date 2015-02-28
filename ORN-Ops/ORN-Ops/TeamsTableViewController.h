//
//  TeamsTableViewController.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORNDataModelSource.h"

#
# pragma mark - Interface
#

@interface TeamsTableViewController : UITableViewController <ORNDataModelSource>

#
# pragma mark <ORNDataModelSource>
#

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
