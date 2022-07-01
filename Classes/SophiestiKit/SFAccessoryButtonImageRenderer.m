//
//  SFAccessoryButtonImageRenderer.m
//  SophiestiKit
//
//  Created by Sophia Teutschler on 06.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import "SFAccessoryButtonImageRenderer.h"
#import "SFAccessoryButtonImageRenderer+Private.h"

#import "SFImageCache.h"

#import "UIColor+Components.h"
#import "UIColor+HEX.h"
#import "UIColor+Interface.h"
#import "UIImage+Styles.h"

@implementation SFAccessoryButtonImageRenderer

@synthesize buttonType = buttonType_;
@synthesize controlSize = controlSize_;
@synthesize controlState = controltate_;
@synthesize tintColor = tintColor_;

#pragma mark - Construction & Destruction

- (id)init {
	if((self = [super init])) {
		self.buttonType = SFCustomAccessoryButtonType;
		self.controlSize = SFRegularControlSize;
		self.controlState = UIControlStateNormal;
	}
	
	return self;
}

#pragma mark - SFAccessoryButtonImageRenderer

- (UIImage*)renderedImage {
	UIImage* buttonImage = [self buttonImage];
	UIImage* image = nil;
	
	UIGraphicsBeginImageContextWithOptions([buttonImage size], NO, [buttonImage scale]); {
		CGContextRef context = UIGraphicsGetCurrentContext();
	
		[self renderInContext:context];
	
		image = UIGraphicsGetImageFromCurrentImageContext();
	} UIGraphicsEndImageContext();
	
	return image;
}

- (void)renderInContext:(CGContextRef)context {
	BOOL isSelected = self.controlState & UIControlStateSelected;
	BOOL isHiglighted = self.controlState & UIControlStateHighlighted;
	
	if(isSelected) {
		UIImage* buttonImage = [self buttonImage];
		UIImage* buttonImageMask = [self buttonMaskImage];
		
		CGRect contentRect = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
		
		// content rect based on button image
		CGContextSaveGState(context); {

			// mask the content before filling with the tint color
			CGImageRef maskImage = [buttonImageMask CGImage];
			CGContextClipToMask(context, contentRect, maskImage);
			
			// fill with the tint color
			UIColor* tintColor = self.tintColor;
			tintColor = [self adjustColor:tintColor forControlState:[self controlState]];

			[tintColor set];
			UIRectFill(contentRect);
			
		} CGContextRestoreGState(context);
			
		// draw our button image
		[buttonImage drawInRect:contentRect blendMode:kCGBlendModeNormal alpha:1.0];
			
		// now draw the icon image if needed
		UIImage* symbolImage = [self buttonSymbolImage];
			
		if(symbolImage) {
			[symbolImage drawInRect:contentRect blendMode:kCGBlendModeNormal alpha:1.0];
		}
	}
	
	if(!isSelected) {
		UIImage* buttonImageMask = [self buttonImage];
		
		CGRect contentRect = CGRectMake(0.0, 0.0, buttonImageMask.size.width, buttonImageMask.size.height);
		
		UIColor* tintColor = isHiglighted ?
			[UIColor selectedTableViewCellSeparatorColor] :
			[UIColor tableViewCellSeparatorColor];
		
		// content rect based on button image
		CGContextSaveGState(context); {

			// mask the content before filling with the tint color
			CGImageRef maskImage = [buttonImageMask CGImage];
			CGContextClipToMask(context, contentRect, maskImage);
			
			[tintColor set];
			UIRectFill(contentRect);
			
		} CGContextRestoreGState(context);
	}
}

#pragma mark - Private

- (NSString*)imageIdentifierForCaching {
	NSString* identifier = [NSString stringWithFormat:
		@"accessorybutton-%lu-%lu-%lu-%@",
		(unsigned long)[self buttonType],
		(unsigned long)[self controlSize],
		(unsigned long)[self controlState],
		[[self tintColor] hexadecimalString]];
	
	return identifier;
}

- (UIImage*)buttonImage {
	NSString* imageName = @"accessorybutton";
	
	if(!(self.controlState & UIControlStateSelected)) {
		imageName = [imageName stringByAppendingString:@"-deselected"];
	}
	
	if(self.controlSize == SFMiniControlSize) {
		imageName = [imageName stringByAppendingString:@"-mini"];
	}
	
	return [UIImage imageNamed:imageName];
}

- (UIImage*)buttonMaskImage {
	NSString* imageName = @"accessorybutton-mask";

	if(self.controlSize == SFMiniControlSize) {
		imageName = [imageName stringByAppendingString:@"-mini"];
	}
	
	return [UIImage imageNamed:imageName];
}

- (UIImage*)buttonSymbolImage {
	NSString* buttonTypeIdentifier = nil;
	
	if(self.buttonType == SFCheckmarkAccessoryButtonType) { buttonTypeIdentifier = @"-checkmark"; }
	if(self.buttonType == SFDetailDisclosureAccessoryButtonType) { buttonTypeIdentifier = @"-detaildisclosure"; }
	if(self.buttonType == SFAddAccessoryButtonType) { buttonTypeIdentifier = @"-add"; }
	if(self.buttonType == SFDisconnectAccessoryButtonType) { buttonTypeIdentifier = @"-disconnect"; }
	
	if(!buttonTypeIdentifier) {
		return nil;
	}
	
	NSString* imageName = [@"accessorybutton" stringByAppendingString:buttonTypeIdentifier];
	
	if(self.controlSize == SFMiniControlSize) {
		buttonTypeIdentifier = [buttonTypeIdentifier stringByAppendingString:@"-mini"];
	}

	return [UIImage imageNamed:imageName];
}

- (UIColor*)adjustColor:(UIColor*)color forControlState:(UIControlState)controlState {
	BOOL isHiglighted = controlState & UIControlStateHighlighted;
	
	// for HSB color models
	CGFloat h, s, b, a;
	
	if([color getHue:&h saturation:&s brightness:&b alpha:&a]) {
		// draw a bit more saturated and slightly darker
		CGFloat saturation = 0.1;
		CGFloat brightness = isHiglighted ? -0.3 : -0.075;
		
		return [color colorByAddingHue:0.0 saturation:saturation brightness:brightness];
	}
	
	// for monochrome color models
	CGFloat w;
	
	if(isHiglighted && [color getWhite:&w alpha:&a]) {
		// just darker
		CGFloat white = w - 0.2;
		return [UIColor colorWithWhite:white alpha:a];
	}
	
	return color;
}

@end