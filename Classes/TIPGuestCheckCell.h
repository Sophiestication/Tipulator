//
//  TIPGuestCheckCell.h
//  Tipulator
//
//  Created by Sophia Teutschler on 16.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TIPGuestCheckCellIndicatorType) {
	TIPGuestCheckCellDisclosureIndicatorType,
	TIPGuestCheckCellClearIndicatorType
};

@interface TIPGuestCheckCell : UICollectionViewCell

@property(nonatomic, readonly, strong) UILabel* titleLabel;
@property(nonatomic, readonly, strong) UILabel* textLabel;

@property(nonatomic) BOOL shouldUseBoldStyle;

@property(nonatomic) TIPGuestCheckCellIndicatorType indicatorType;
@property(nonatomic, readonly, strong) UIButton* clearIndicator;

@end