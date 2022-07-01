//
//  SFGradientView.m
//  GradientTest
//
//  Created by Sophia Teutschler on 03.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import "SFGradientView.h"

@implementation SFGradientView

@synthesize colors = colors_;

#pragma mark - Construction & Destruction

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
    }

    return self;
}

#pragma mark - SFGradientView

- (CAGradientLayer*)gradientLayer {
	return (CAGradientLayer*)[self layer];
}

- (void)setColors:(NSArray*)colors {
	if(colors == self.colors) { return; }
	
	colors_ = [colors copy];
	
	NSMutableArray* layerColors = [[NSMutableArray alloc] initWithCapacity:[colors count]];
	
	for(UIColor* color in colors) {
		[layerColors addObject:(id)[color CGColor]];
	}
	
	[[self gradientLayer] setColors:layerColors];
}

#pragma mark - UIView

+ (Class)layerClass {
	return [CAGradientLayer class];
}

#pragma mark - Private

@end

@implementation SFGradientView(SystemGradients)

+ (SFGradientView*)tableViewSelectionGradient {
	SFGradientView* gradient = [[SFGradientView alloc] initWithFrame:CGRectZero];
	
	gradient.colors = [NSArray arrayWithObjects:
		[UIColor colorWithRed:0.02 green:0.55 blue:0.96 alpha:1.00],
		[UIColor colorWithRed:0.04 green:0.37 blue:0.91 alpha:1.00],
		nil];
	
	return gradient;
}

@end