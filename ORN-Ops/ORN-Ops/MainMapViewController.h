//
//  MainMapViewController.h
//  ORN-Ops
//
//  Created by Johnny on 2015-02-24.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "RideDetailTableViewController.h"
#import "TeamDetailTableViewController.h"


#
# pragma mark - Interface
#

@interface MainMapViewController : UIViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, MKMapViewDelegate>

#
# pragma mark UI Outlets
#

@property (weak, nonatomic) IBOutlet UIBarButtonItem* avatarBarButtonItem;
@property (weak, nonatomic) IBOutlet UITextField* addressTextField;
@property (strong, nonatomic) IBOutlet MKMapView* mainMapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl* lineTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl* mapTypeSegmentedControl;

@end
