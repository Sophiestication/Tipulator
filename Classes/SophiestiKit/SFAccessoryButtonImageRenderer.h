//
//  SFAccessoryButtonImageRenderer.h
//  SophiestiKit
//
//  Created by Sophia Teutschler on 06.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import "SFControlSize.h"
#import "SFAccessoryButton.h"

@interface SFAccessoryButtonImageRenderer : NSObject

@property(nonatomic) SFAccessoryButtonType buttonType;
@property(nonatomic) SFControlSize controlSize;
@property(nonatomic) UIControlState controlState;
@property(nonatomic, retain) UIColor* tintColor;

- (UIImage*)renderedImage;
- (void)renderInContext:(CGContextRef)context;

@end