//
//  TeamAnnotationView.m
//  ORN-Ops
//
//  Created by Johnny on 2015-11-01.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#import "TeamAnnotationView.h"
#import "TeamPointAnnotation.h"


#
# pragma mark - Constants
#

#define FINGER_DIAMETER		20 // points

#define ANNOTATION_SCALE	0.66

#define ANNOTATION_DRAGGED_NOTIFICATION_NAME	@"annotationViewDragEnded"


#
# pragma mark - Interface
#


@interface TeamAnnotationView ()

@property (nonatomic) CGPoint hitPoint;

@end


#
# pragma mark - Implementation
#


@implementation TeamAnnotationView


#
# pragma mark Initializers
#


- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString*)reuseIdentifier andMapView:(MKMapView*)mapView {
	
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	
	if (self) {
		
		self.mapView = mapView;

		if ([reuseIdentifier isEqualToString:TEAM_MASCOT_ANNOTATION_ID]) {
			
			self.image = [UIImage imageNamed:@"ORN-Team-Mascot-Map-Annotation"];
			
		} else {
			
			self.image = [UIImage imageNamed:@"ORN-Team-Map-Annotation"];
			self.bounds = CGRectMake(0, 0,
									 (self.bounds.size.width * ANNOTATION_SCALE),
									 (self.bounds.size.height * ANNOTATION_SCALE));
		}

		UILabel* teamIDLabel = [[UILabel alloc] initWithFrame:self.bounds];
		teamIDLabel.textAlignment = NSTextAlignmentCenter;
		teamIDLabel.textColor = [UIColor whiteColor];
		teamIDLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightHeavy];
		[self addSubview:teamIDLabel];
		self.teamIDLabel = teamIDLabel;
		
		self.draggable = YES;
	}
	
	return self;
}


- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString*)reuseIdentifier {

	return [self initWithAnnotation:annotation reuseIdentifier:reuseIdentifier andMapView:nil];
}


#
# pragma mark <UIView>
#


- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
	
	// NOTE: See http://stackoverflow.com/questions/25324200/mkannotationview-drag-state-ending-animation
	
	UIView* hitView = [super hitTest:point withEvent:event];
	
	if (hitView) {
		
		if (self.dragState == MKAnnotationViewDragStateNone) {
			
			self.hitPoint = point;
			NSLog(@"Team annotation view hit point: (%.2f,%.2f)", point.x, point.y);
		}
	}
	
	return hitView;
}


#
# pragma mark Notifications
#


+ (void)addDragEndedObserver:(id)observer withSelector:(SEL)selector {
	
	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:ANNOTATION_DRAGGED_NOTIFICATION_NAME object:nil];
}


- (void)postNotificationDragEndedWithSender:(id)sender {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ANNOTATION_DRAGGED_NOTIFICATION_NAME object:sender userInfo:nil];
}


#
# pragma mark Methods
#


- (void)setDragState:(MKAnnotationViewDragState)newDragState animated:(BOOL)animated {
	
	// NOTE: See http://stackoverflow.com/questions/25324200/mkannotationview-drag-state-ending-animation
	
	// Notify current state change
	// NOTE: Container should probably use KVO, but delegate is easy solution (for now)
	id<MKMapViewDelegate> mapDelegate = (id<MKMapViewDelegate>)self.mapView.delegate;
	if ([mapDelegate respondsToSelector:@selector(mapView:annotationView:didChangeDragState:fromOldState:)]) {
		
		[mapDelegate mapView:self.mapView annotationView:self didChangeDragState:newDragState fromOldState:self.dragState];
	}

	CGFloat liftHeight = self.frame.size.height + FINGER_DIAMETER - self.hitPoint.y;
	
	switch (newDragState) {
	
		case MKAnnotationViewDragStateStarting: {
			
			// Lift annotation view
			
			CGPoint endCenterPoint = CGPointMake(self.center.x, self.center.y - liftHeight);
			if (animated) {
				[UIView animateWithDuration:0.2
								 animations:^{
									 self.center = endCenterPoint;
								 }
								 completion:^(BOOL finished) {
									 self.dragState = MKAnnotationViewDragStateDragging;
								 }
				 ];
			} else {
				
				self.center = endCenterPoint;
				self.dragState = MKAnnotationViewDragStateDragging;
			}
			break;
		}
		
		case MKAnnotationViewDragStateDragging:
			// Do nothing
			break;
			
		case MKAnnotationViewDragStateEnding: {
			
			// Drop annotation view
			
			CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -liftHeight);
			if (animated) {
				[UIView animateWithDuration:0.2
								 animations:^{
									 self.transform = transform;
								 }
								 completion:^(BOOL finished){
									 
									 [UIView animateWithDuration:0.2
													  animations:^{
														  self.transform = CGAffineTransformIdentity;
													  }
													  completion:^(BOOL finished) {
														  
														  self.dragState = MKAnnotationViewDragStateNone;
														  [self postNotificationDragEndedWithSender:self];
													  }];
								 }];
			} else {
				
				self.transform = transform;
				self.dragState = MKAnnotationViewDragStateNone;
				[self postNotificationDragEndedWithSender:self];
			}
			break;
		}
			
		case MKAnnotationViewDragStateCanceling: {
			
			// Drop annotation view
			
			CGPoint endCenterPoint = CGPointMake(self.center.x, self.center.y + liftHeight);
			if (animated) {
				[UIView animateWithDuration:0.2
								 animations:^{
									 self.center = endCenterPoint;
								 }
								 completion:^(BOOL finished) {
									 self.dragState = MKAnnotationViewDragStateNone;
								 }
				 ];
			} else {
				
				self.center = endCenterPoint;
				self.dragState = MKAnnotationViewDragStateNone;
			}
			break;
		}
		
		case MKAnnotationViewDragStateNone:
			// Do nothing
			break;
			
		default:
			NSAssert(NO, @"Should never get here");
			break;

	} // switch
}


@end
