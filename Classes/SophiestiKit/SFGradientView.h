//
//  SFGradientView.h
//  GradientTest
//
//  Created by Sophia Teutschler on 03.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SFGradientView : UIView

@property(nonatomic, readonly) CAGradientLayer* gradientLayer;
@property(nonatomic, copy) NSArray* colors;

@end

@interface SFGradientView(SystemGradients)

+ (SFGradientView*)tableViewSelectionGradient;

@end