//
//  Util.m
//  ORN-Ops
//
//  Created by Johnny on 2015-02-28.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "Util.h"
#import "ORNDataModelSource.h"


#
# pragma mark - Implementation
#


@implementation Util


#
# pragma mark Strings
#


+ (BOOL)compareString:(NSString*)firstString toString:(NSString*)secondString {
	
	if (firstString.length == 0 && secondString.length == 0) return YES; // NOTE: Handles nil
	
	return (firstString && [firstString isEqualToString:secondString]);
}


#
# pragma mark Responder
#


/*
 Preload keyboard to avoid delay upon user first attempt
 */
+ (void)preloadKeyboardViaTextField:(UITextField*)textfield {
	
	// NOTE: Text field needs to be already in view hierarchy
	[textfield becomeFirstResponder];
	[textfield resignFirstResponder];
}


#
# pragma mark <ORNDataModelSource>
#


+ (NSManagedObjectContext*)managedObjectContext {
	
	id<ORNDataModelSource> dataModelSource = (id<ORNDataModelSource>)[UIApplication sharedApplication].delegate;
	return dataModelSource.managedObjectContext;
}


+ (void)saveManagedObjectContext {
	
	id<ORNDataModelSource> dataModelSource = (id<ORNDataModelSource>)[UIApplication sharedApplication].delegate;
	[dataModelSource saveManagedObjectContext];
}


@end
