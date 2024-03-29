//
//  TIPNumericKeypadButton.m
//  Tipulator
//
//  Created by Sophia Teutschler on 05.02.09.
//  Copyright 2009 Sophiestication Software. All rights reserved.
//

#import "TIPNumericKeypadButton.h"

@interface TIPNumericKeypadButton()

@property(nonatomic) BOOL keepHighlighted;
@property(nonatomic) CGRect originalFrame;

@property(nonatomic) UIFont* fontForControlStateNormal;
@property(nonatomic) UIFont* fontForControlStateHighlighted;

@end

@implementation TIPNumericKeypadButton

#pragma mark - Construction & Destruction

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
		[self initIvars];
	}

    return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	if((self = [super initWithCoder:coder])) {
		[self initIvars];
	}

    return self;
}

#pragma mark - UIButton

- (UIImage*)backgroundImageForState:(UIControlState)state {
	return [super backgroundImageForState:state];
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
	CGRect titleRect = [super titleRectForContentRect:contentRect];
	
	if(self.highlighted || _keepHighlighted) {
		CGSize titleSize = titleRect.size;

		titleRect = CGRectMake(
			ceil(CGRectGetMidX(contentRect) - titleSize.width * 0.5),
			CGRectGetMinY(contentRect) + 2.0,
			titleSize.width, 
			titleSize.height);
	}
	
	return titleRect;
}

#pragma mark - UIControl

- (UIControlState)state {
	UIControlState state = [super state];
	
	if(_keepHighlighted) {
		state |= UIControlStateHighlighted;
	}
	
	return state;
}

- (void)setHighlighted:(BOOL)highlighted {
	if(highlighted != self.highlighted) {
		// Keep the button highlighted for a certain delay
		if(highlighted) {
			[[self class] cancelPreviousPerformRequestsWithTarget:self
				selector:@selector(unsetKeepHighlighted)
				object:nil];
			_keepHighlighted = YES;
		} else {
			[self performSelector:@selector(unsetKeepHighlighted)
				withObject:nil
				afterDelay:0.05];
		}
		
		[super setHighlighted:highlighted];
		
		// Set our new layout
		if(highlighted || _keepHighlighted) {
			[self setHighlightedLayout];
		} else {
			[self setNormalLayout];
		}
		
		// Mark for layouting
		[self setNeedsLayout];
		
		// Set it selected after a certain delay
		if(highlighted) {
//			[self performSelector:@selector(setSelected)
//				withObject:nil
//				afterDelay:1.0];
		} else {
			[[self class] cancelPreviousPerformRequestsWithTarget:self
				selector:@selector(setSelected)
				object:nil];
		}
	}
}

- (void)setSelected:(BOOL)selected {
	if(selected != self.selected) {
		[super setSelected:selected];
		
		// Set our new layout
		if(selected) {
			[self setSelectedLayout];
		} else {
			[self setNormalLayout];
		}
		
		// Mark for layouting
		[self setNeedsLayout];
	}
}

#pragma mark - Accessibility

- (UIAccessibilityTraits)accessibilityTraits {
   UIAccessibilityTraits traits = [super accessibilityTraits] | UIAccessibilityTraitKeyboardKey;
 
   if(self.selected) {
      traits |= UIAccessibilityTraitSelected;
   }

   return traits;
}

#pragma mark - Private

- (void)initIvars {
	_keepHighlighted = NO;
	_originalFrame = self.frame;

	self.clipsToBounds = NO;
	
	UIImage* backgroundImage = [UIImage imageNamed:@"keypad-button-background"];
	backgroundImage = [backgroundImage
		resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)
		resizingMode:UIImageResizingModeTile];
	[self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
	
	backgroundImage = [UIImage imageNamed:@"keypad-button-background-maximized"];
	[self setBackgroundImage:backgroundImage forState:UIControlStateHighlighted];

	self.fontForControlStateNormal = [UIFont boldSystemFontOfSize:23.0];
	self.fontForControlStateHighlighted = [UIFont boldSystemFontOfSize:48.0];
	
	self.titleLabel.font = self.fontForControlStateNormal;

	UIColor* textColor = [UIColor colorWithRed:(51.0 / 0xff) green:(55.0 / 0xff) blue:(72.0 / 0xff) alpha:1.0];
	
	[self setTitleColor:textColor forState:UIControlStateNormal];
	[self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	[self setTitleColor:textColor forState:UIControlStateHighlighted];
	[self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

	self.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setNormalLayout {
	self.frame = _originalFrame;
	self.titleLabel.font = self.fontForControlStateNormal;
}

- (void)setHighlightedLayout {
	CGSize imageSize = [[self currentBackgroundImage] size];
	
	CGRect highlightedFrame = CGRectMake(
		ceil(CGRectGetMidX(_originalFrame) - imageSize.width * 0.5),
		CGRectGetMaxY(_originalFrame) - imageSize.height,
		imageSize.width,
		imageSize.height);
	
	self.frame = highlightedFrame;
	
	self.titleLabel.font = self.fontForControlStateHighlighted;
}

- (void)setSelectedLayout {
	UIImage* backgroundImage = [self backgroundImageForState:UIControlStateSelected];
	CGSize imageSize = [backgroundImage size];
	
	CGRect highlightedFrame = CGRectMake(
		CGRectGetMinX(_originalFrame),
		CGRectGetMaxY(_originalFrame),
		imageSize.width,
		imageSize.height);
	
	self.frame = highlightedFrame;
}

- (void)setSelected {
	self.selected = YES;
}

- (void)unsetKeepHighlighted {
	_keepHighlighted = NO;
	
	if(self.highlighted) {
		[self setHighlightedLayout];
	} else {
		[self setNormalLayout];
	}
	
	[self setNeedsLayout];
}

@end