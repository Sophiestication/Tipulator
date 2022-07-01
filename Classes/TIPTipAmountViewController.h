//
//  TIPTipAmountViewController.h
//  Tipulator
//
//  Created by Sophia Teutschler on 17.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TIPTipAmountViewDelegate;

@interface TIPTipAmountViewController : UIViewController

+ (id)viewController;

@property(nonatomic, weak) id<TIPTipAmountViewDelegate> delegate;
@property(nonatomic, copy) NSNumber* tipAmount;

@end

@protocol TIPTipAmountViewDelegate<NSObject>

@required
- (void)tipAmountViewController:(TIPTipAmountViewController*)viewController didSelectValue:(NSNumber*)tipAmount;

@end