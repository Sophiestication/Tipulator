//
//  NSArray+Additions.m
//  Groceries
//
//  Created by Sophia Teutschler on 11.03.08.
//  Copyright 2008 Sophiestication Software. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray(Additions)

@dynamic firstObject;

- (id)firstObject {
	if(self.count > 0) { return [self objectAtIndex:0]; }
	return nil;
}

@end