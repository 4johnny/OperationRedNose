//
//  TeamDetailTableViewController.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-27.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"

#
# pragma mark - Constants
#

#define TEAM_DETAIL_TABLE_VIEW_CONTROLLER_ID	@"teamDetailTableViewController"

#
# pragma mark - Interface
#

@interface TeamDetailTableViewController : UITableViewController

#
# pragma mark Properties
#

@property (nonatomic) Team* team;

@end
