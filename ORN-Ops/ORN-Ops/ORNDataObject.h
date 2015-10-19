//
//  ORNDataObject.h
//  ORN-Ops
//
//  Created by Johnny on 2015-10-19.
//  Copyright © 2015 Empath Solutions. All rights reserved.
//

#ifndef ORNDataObject_h
#define ORNDataObject_h


#
# pragma mark - Protocol
#

@protocol ORNDataObject <NSObject>

#
# pragma mark Methods
#

@required

- (NSString*)getTitle;
- (void)delete;

@end


#endif /* ORNDataObject_h */
