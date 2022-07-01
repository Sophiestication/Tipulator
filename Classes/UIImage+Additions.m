//
//  UIImage+Additions.m
//  Tipulator
//
//  Created by Sophia Teutschler on 26.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage(Additions)

+ (UIImage*)transparentImage {
	UIImage* image;
	
	CGSize imageSize = CGSizeMake(2.0, 2.0);
	CGFloat scale = 1.0;

	UIGraphicsBeginImageContextWithOptions(imageSize, NO, scale); {
		//CGContextRef context = UIGraphicsGetCurrentContext();
	
		image = UIGraphicsGetImageFromCurrentImageContext();
	} UIGraphicsEndImageContext();
	
	return image;
}

@end