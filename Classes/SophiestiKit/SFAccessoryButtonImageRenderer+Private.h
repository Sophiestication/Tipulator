//
//  SFAccessoryButtonImageRenderer+Private.h
//  SophiestiKit
//
//  Created by Sophia Teutschler on 06.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import "SFAccessoryButtonImageRenderer.h"

@interface SFAccessoryButtonImageRenderer()

- (NSString*)imageIdentifierForCaching;

- (UIImage*)buttonImage;
- (UIImage*)buttonMaskImage;
- (UIImage*)buttonSymbolImage;

- (UIColor*)adjustColor:(UIColor*)color forControlState:(UIControlState)controlState;

@end