//
//  SFShadowView.m
//  Articles
//
//  Created by Sophia Teutschler on 15.05.10.
//  Copyright 2010 Sophia Teutschler. All rights reserved.
//

#import "SFShadowView.h"

@implementation SFShadowView

@synthesize offset = _offset;
@synthesize blur = _blur;
@synthesize shadowColor = _shadowColor;
@dynamic shadowEdge;

#pragma mark -
#pragma mark Construction & Destruction

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		self.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.userInteractionEnabled = NO;

		self.blur = 10.0;
		self.offset = CGSizeZero;
	}

    return self;
}

- (void)dealloc {
	self.shadowColor = nil;
}

#pragma mark -
#pragma mark SFShadowView

- (SFShadowViewEdge)shadowEdge {
	return _shadowEdge;
}

- (void)setShadowEdge:(SFShadowViewEdge)shadowEdge {
	if(shadowEdge != self.shadowEdge) {
		_shadowEdge = shadowEdge;
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark UIView

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(16.0, 16.0);
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGContextSetShadowWithColor(
		UIGraphicsGetCurrentContext(),
		[self offset],
		[self blur],
		[[self shadowColor] CGColor]);
	
	CGRect bounds = self.bounds;
	
	CGSize contentSize = [self sizeThatFits:bounds.size];
	CGRect contentRect;
	
	switch(self.shadowEdge) {
		case SFShadowViewEdgeTop: {
			contentRect = CGRectMake(
				CGRectGetMinX(bounds),
				CGRectGetMinY(bounds) + contentSize.height,
				CGRectGetWidth(bounds),
				contentSize.height);
		} break;
		
		case SFShadowViewEdgeRight: {
			contentRect = CGRectMake(
				CGRectGetMinX(bounds) - contentSize.width,
				CGRectGetMinY(bounds),
				contentSize.width,
				CGRectGetHeight(bounds));
		} break;
		
		case SFShadowViewEdgeBottom: {
			contentRect = CGRectMake(
				CGRectGetMinX(bounds),
				CGRectGetMinY(bounds) - contentSize.height,
				CGRectGetWidth(bounds),
				contentSize.height);
		} break;
		
		case SFShadowViewEdgeLeft: {
			contentRect = CGRectMake(
				contentSize.width,
				CGRectGetMinY(bounds),
				contentSize.width,
				CGRectGetHeight(bounds));
		} break;
	}
	
	[[UIColor whiteColor] set];
	UIRectFill(contentRect);
}

@end