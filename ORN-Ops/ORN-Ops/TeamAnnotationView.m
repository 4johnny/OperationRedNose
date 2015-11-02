//
//  TeamAnnotationView.m
//  ORN-Ops
//
//  Created by Johnny on 2015-11-01.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#import "TeamAnnotationView.h"


#
# pragma mark - Constants
#

#define FINGER_DIAMETER				20 // points


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
														  [[NSNotificationCenter defaultCenter] postNotificationName:@"annotationViewDragEnded" object:self userInfo:nil];
													  }];
								 }];
			} else {
				
				self.transform = transform;
				self.dragState = MKAnnotationViewDragStateNone;
				[[NSNotificationCenter defaultCenter] postNotificationName:@"annotationViewDragEnded" object:self userInfo:nil];
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
