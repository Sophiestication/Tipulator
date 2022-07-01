//
//  TIPSplitCheckViewController.h
//  Tipulator
//
//  Created by Sophia Teutschler on 17.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TIPSplitCheckViewDelegate;

@interface TIPSplitCheckViewController : UIViewController

+ (id)viewController;

@property(nonatomic, weak) id<TIPSplitCheckViewDelegate> delegate;
@property(nonatomic, copy) NSNumber* selectedValue;

@end

@protocol TIPSplitCheckViewDelegate<NSObject>

@required
- (void)splitCheckView:(TIPSplitCheckViewController*)viewController didSelectValue:(NSNumber*)value;

@end