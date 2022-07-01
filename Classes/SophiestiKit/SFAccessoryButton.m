//
//  SFAccessoryButton.m
//  SophiestiKit
//
//  Created by Sophia Teutschler on 07.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import "SFAccessoryButton.h"
#import "SFAccessoryButton+Private.h"

#import "SFAccessoryButtonImageRenderer.h"

#import "UIColor+Tint.h"

#import "SFImageCache.h"
#import "SFAccessoryButtonImageRenderer+Private.h"

@implementation SFAccessoryButton

@synthesize controlSize = controlSize_;
@synthesize accessoryType = accessoryType_;
@synthesize tintColor = tintColor_;

@synthesize accessoryButtonImagesNeedsUpdate = accessoryButtonImagesNeedsUpdate_;
@synthesize titleLabelNeedsUpdate = titleLabelNeedsUpdate_;

#pragma mark - Construction & Destruction

- (id)initWithFrame:(CGRect)frame {
	if((self = [super initWithFrame:frame])) {
		self.titleLabelNeedsUpdate = YES;
		self.controlSize = SFRegularControlSize;
		self.accessoryType = SFCustomAccessoryButtonType;
	}
	
	return self;
}

#pragma mark - SFAccessoryButton

- (void)setControlSize:(SFControlSize)controlSize {
	if(self.controlSize == controlSize) { return; }
	
	controlSize_ = controlSize;
	
	self.accessoryButtonImagesNeedsUpdate = YES;
	[self setNeedsLayout];
}

- (void)setAccessoryType:(SFAccessoryButtonType)accessoryType {
	if(self.accessoryType == accessoryType) { return; }
	
	accessoryType_ = accessoryType;
	
	self.accessoryButtonImagesNeedsUpdate = YES;
	[self setNeedsLayout];
}

#pragma mark - UIButton

- (UIControlState)state {
	UIControlState state = [super state];
	
	if(self.tracking) {
		state |= UIControlStateSelected;
	}
	
	return state;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
	[super setTitle:title forState:state];
	[self updateTitleLabelIfNeeded];
}

- (void)setTintColor:(UIColor*)tintColor {
	if(tintColor == self.tintColor) { return; }

	tintColor_ = tintColor;
	
	self.accessoryButtonImagesNeedsUpdate = YES;
	[self setNeedsLayout];
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
	if(self.state & UIControlStateSelected) {
		return CGRectOffset([self imageRectForContentRect:contentRect], 0.0, -1.0);
	}

	return CGRectZero;
}

#pragma mark - UIView

- (CGSize)sizeThatFits:(CGSize)size {
	[self updateAccessoryButtonImagesIfNeeded];

	UIImage* image = self.currentImage;
	UIEdgeInsets contentInsets = self.contentEdgeInsets;
	
	CGSize contentSize = CGSizeMake(
		image.size.width + contentInsets.left + contentInsets.right,
		image.size.height + contentInsets.top + contentInsets.bottom);
		
	return contentSize;
}

- (void)layoutSubviews {
	[self updateAccessoryButtonImagesIfNeeded];
	[super layoutSubviews];
}

#pragma mark - Private

- (void)updateAccessoryButtonImagesIfNeeded {
	if(!self.accessoryButtonImagesNeedsUpdate) { return; }
	
	self.accessoryButtonImagesNeedsUpdate = NO;
	
	[self setImage:[self accessoryButtonImageForState:UIControlStateNormal] forState:UIControlStateNormal];
	[self setImage:[self accessoryButtonImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
	[self setImage:[self accessoryButtonImageForState:UIControlStateSelected] forState:UIControlStateSelected];
	[self setImage:[self accessoryButtonImageForState:UIControlStateSelected|UIControlStateHighlighted] forState:UIControlStateSelected|UIControlStateHighlighted];
}

- (UIImage*)accessoryButtonImageForState:(UIControlState)state {
	// setup a new image renderer
	SFAccessoryButtonImageRenderer* renderer = [[SFAccessoryButtonImageRenderer alloc] init];
	
	renderer.buttonType = self.accessoryType;
	renderer.controlState = state;
	renderer.controlSize = self.controlSize;
	
	if(!self.tintColor) {
		renderer.tintColor = [UIColor blueTintColor];
	} else {
		renderer.tintColor = self.tintColor;
	}
	
	// first see if we have a cached bitmap
	NSString* cacheKey = [renderer imageIdentifierForCaching];
	NSCache* cache = SFGetImageCache();
	
	UIImage* image = [cache objectForKey:cacheKey];
	
	if(!image) {
		// render a new bitmap and add it to our cache
		image = [renderer renderedImage];
		
		NSUInteger imageCost = image.size.width * image.size.height * image.scale * 4.0;
		[cache setObject:image forKey:cacheKey cost:imageCost];
	}
	
	return image;
}

- (void)updateTitleLabelIfNeeded {
	if(!self.titleLabelNeedsUpdate) { return; }
	self.titleLabelNeedsUpdate = NO;
	
	UILabel* titleLabel = self.titleLabel;
	
	titleLabel.font = [UIFont boldSystemFontOfSize:15.5];
	
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	
	[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.25] forState:UIControlStateNormal];
}

@end