//
//  MainTabBarController.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-24.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORNDataModelSource.h"

#
# pragma mark - Interface
#

@interface MainTabBarController : UITabBarController <ORNDataModelSource, UITabBarControllerDelegate>

#
# pragma mark <ORNDataModelSource>
#

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end