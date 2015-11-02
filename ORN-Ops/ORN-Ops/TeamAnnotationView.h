//
//  TeamAnnotationView.h
//  ORN-Ops
//
//  Created by Johnny on 2015-11-01.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>

#
# pragma mark - Interface
#

@interface TeamAnnotationView : MKAnnotationView

#
# pragma mark Properties
#

@property (weak, nonatomic) MKMapView* mapView;

#
# pragma mark Notifications
#

+ (void)addDragEndedObserver:(id)observer withSelector:(SEL)selector;

- (void)postNotificationDragEndedWithSender:(id)sender;

@end
