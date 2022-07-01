//
//  TIPGuestCheckViewController.h
//  Tipulator
//
//  Created by Sophia Teutschler on 14.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TIPGuestCheckViewController : UIViewController

- (void)presentInputViewController:(UIViewController*)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissInputViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;

@end