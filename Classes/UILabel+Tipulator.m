//
//  UILabel+Tipulator.m
//  Tipulator
//
//  Created by Sophia Teutschler on 16.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "UILabel+Tipulator.h"
#import "UIColor+Tipulator.h"

@implementation UILabel(Tipulator)

- (void)setGuestCheckStyle {
	self.textColor = [UIColor guestCheckTextColor];
	self.highlightedTextColor = [UIColor whiteColor];
	
	self.shadowOffset = CGSizeMake(0.0, 1.0);
	self.shadowColor = [UIColor guestCheckTextShadowColor];
	
	self.backgroundColor = [UIColor clearColor];
}

@end