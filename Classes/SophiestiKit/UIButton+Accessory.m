//
//  UIButton+CheckmarkAccessory.m
//  SophiestiKit
//
//  Created by Sophia Teutschler on 06.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import "UIButton+Accessory.h"

#import "SFAccessoryButton.h"

@implementation UIButton(Accessory)

+ (id)accessoryButtonWithType:(SFAccessoryButtonType)accessoryType {
	return [self accessoryButtonWithType:accessoryType controlSize:SFRegularControlSize];
}

+ (id)accessoryButtonWithType:(SFAccessoryButtonType)accessoryType controlSize:(SFControlSize)controlSize {
	SFAccessoryButton* accessoryButton = [SFAccessoryButton buttonWithType:UIButtonTypeCustom];
	
	accessoryButton.accessoryType = accessoryType;
	accessoryButton.controlSize = controlSize;
	
	return accessoryButton;
}

@end