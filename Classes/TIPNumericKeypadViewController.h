//
//  TIPNumericKeypadViewController.h
//  Tipulator
//
//  Created by Sophia Teutschler on 17.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TIPNumericKeypadViewDelegate;

typedef NS_ENUM(NSUInteger, TIPNumericKeypadType) {
	TIPNumericKeypadTypeDecimal = 0,
	TIPNumericKeypadTypeFractional
};

@interface TIPNumericKeypadViewController : UIViewController

+ (id)viewController;

@property(nonatomic) TIPNumericKeypadType keypadType;
@property(nonatomic, weak) id<TIPNumericKeypadViewDelegate> delegate;

@end

@protocol TIPNumericKeypadViewDelegate<NSObject>

@optional
- (void)numericKeypadView:(TIPNumericKeypadViewController*)viewController didInsertString:(NSString*)string;
- (void)numericKeypadViewDidClear:(TIPNumericKeypadViewController*)viewController;

@end