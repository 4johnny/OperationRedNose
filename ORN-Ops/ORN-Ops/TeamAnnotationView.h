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
# pragma mark Initializers
#

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString*)reuseIdentifier andMapView:(MKMapView*)mapView;
	
#
# pragma mark Properties
#

@property (weak, nonatomic) MKMapView* mapView;

@property (weak, nonatomic) UILabel* teamIDLabel;

#
# pragma mark Notifications
#

+ (void)addDragEndedObserver:(id)observer withSelector:(SEL)selector;

- (void)postNotificationDragEndedWithSender:(id)sender;

@end
