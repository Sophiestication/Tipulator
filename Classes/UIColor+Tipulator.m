//
//  UIColor+Tipulator.m
//  Tipulator
//
//  Created by Sophia Teutschler on 16.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "UIColor+Tipulator.h"

@implementation UIColor(Tipulator)

+ (UIColor*)guestCheckTextColor {
	static dispatch_once_t once;
    static UIColor* guestCheckTextColor;
	
    dispatch_once(&once, ^{
		guestCheckTextColor = [UIColor colorWithRed:0.065 green:0.200 blue:0.066 alpha:1.000];
	});

    return guestCheckTextColor;
}

+ (UIColor*)guestCheckTextShadowColor {
	static dispatch_once_t once;
    static UIColor* guestCheckTextShadowColor;
	
    dispatch_once(&once, ^{
		guestCheckTextShadowColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0 / 3.0];
	});

    return guestCheckTextShadowColor;
}

@end