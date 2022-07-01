//
//  UIButton+Accessory.h
//  SophiestiKit
//
//  Created by Sophia Teutschler on 06.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFControlSize.h"

enum {
	SFCustomAccessoryButtonType = 0,
	SFCheckmarkAccessoryButtonType,
	SFAddAccessoryButtonType,
	SFDisconnectAccessoryButtonType,
	SFDetailDisclosureAccessoryButtonType
};
typedef NSUInteger SFAccessoryButtonType;

@interface UIButton(Accessory)

+ (id)accessoryButtonWithType:(SFAccessoryButtonType)accessoryType;
+ (id)accessoryButtonWithType:(SFAccessoryButtonType)accessoryType controlSize:(SFControlSize)controlSize;

@end