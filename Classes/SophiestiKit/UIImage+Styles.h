//
//  UIImage+Styles.h
//  Tipulator
//
//  Created by Sophia Teutschler on 03.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(Styles)

+ (UIImage*)imageNamed:(NSString*)imageName style:(NSString*)styleName;
- (UIImage*)imageByApplyingStyles:(NSDictionary*)imageStyles;

+ (void)registerImageStyle:(NSDictionary*)imageStyle forKey:(NSString*)styleKey;
+ (void)unregisterImageStyleForKey:(NSString*)styleKey;

@end

// standard styles
NSString* const SUIGroupedTableViewHeaderImageStyle;

NSString* const SUITableViewCellImageStyle;
NSString* const SUITableViewCellDarkImageStyle;
NSString* const SUITableViewCellSelectedImageStyle;
NSString* const SUITableViewCellGrayImageStyle;
NSString* const SUITableViewCellBlueImageStyle;

NSString* const SUIToolbarItemImageStyle;

// style attributes
NSString* const SUIImageStyleFillColor; // UIColor

NSString* const SUIImageStyleShadowColor; // UIColor
NSString* const SUIImageStyleShadowOffset; // CGPoint in NSValue

NSString* const SUIImageStyleFillStartColor; // UIColor
NSString* const SUIImageStyleFillEndColor; // UIColor