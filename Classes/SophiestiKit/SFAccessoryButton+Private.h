//
//  SFAccessoryButton+Private.h
//  SophiestiKit
//
//  Created by Sophia Teutschler on 07.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import "SFAccessoryButton.h"

@interface SFAccessoryButton()

@property(nonatomic) BOOL accessoryButtonImagesNeedsUpdate;
- (void)updateAccessoryButtonImagesIfNeeded;

- (UIImage*)accessoryButtonImageForState:(UIControlState)state;

@property(nonatomic) BOOL titleLabelNeedsUpdate;
- (void)updateTitleLabelIfNeeded;

@end