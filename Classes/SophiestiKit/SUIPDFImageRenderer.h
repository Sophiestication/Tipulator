//
//  SUIPDFImageRenderer.h
//  Tipulator
//
//  Created by Sophia Teutschler on 06.03.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SUIPDFImageRenderer : NSObject

@property(nonatomic, retain) NSURL* URL;

@property(nonatomic) CGSize size;
@property(nonatomic) CGFloat scale;

- (id)initWithContentsOfURL:(NSURL*)URL;

- (UIImage*)renderedImage;
- (void)renderInContext:(CGContextRef)context;

@end