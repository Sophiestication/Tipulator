//
//  TIPNumericKeypadView.h
//  Tipulator
//
//  Created by Sophia Teutschler on 21.09.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIPNumericKeypadViewController.h"

@interface TIPNumericKeypadView : UIView<UIInputViewAudioFeedback>

- (id)initWithKeypadType:(TIPNumericKeypadType)keypadType;
@property(nonatomic, weak) TIPNumericKeypadViewController* keypadViewController;

@end