//
//  TIPRoundingOptionsViewController.h
//  Tipulator
//
//  Created by Sophia Teutschler on 17.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TIPCalculator.h"

@protocol TIPRoundingOptionsViewDelegate;

@interface TIPRoundingOptionsViewController : UIViewController

+ (id)viewController;

@property(nonatomic, weak) id<TIPRoundingOptionsViewDelegate> delegate;
@property(nonatomic) TIPRoundingOption selectedRoundingOption;

@end

@protocol TIPRoundingOptionsViewDelegate<NSObject>

@required
- (void)roundingOptionsView:(TIPRoundingOptionsViewController*)viewController didSelectOption:(TIPRoundingOption)roundingOption;

@end