//
//  SFAccessoryButton.h
//  SophiestiKit
//
//  Created by Sophia Teutschler on 07.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+Accessory.h"

@interface SFAccessoryButton : UIButton

@property(nonatomic) SFControlSize controlSize;
@property(nonatomic) SFAccessoryButtonType accessoryType;

@end