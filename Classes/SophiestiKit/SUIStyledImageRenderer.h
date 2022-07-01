//
//  SUIStyledImageRenderer.h
//  Tipulator
//
//  Created by Sophia Teutschler on 08.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import "UIImage+Styles.h"

@interface SUIStyledImageRenderer : NSObject

@property(nonatomic, retain) UIImage* maskImage;
@property(nonatomic, retain) NSDictionary* imageStyles;

- (UIImage*)renderedImage;
- (void)renderInContext:(CGContextRef)context;

@end