//
//  SUIGroupedTableViewDeleteButton.m
//  Groceries
//
//  Created by Sophia Teutschler on 30.10.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "SUIGroupedTableViewDeleteButton.h"

@implementation SUIGroupedTableViewDeleteButton

CGFloat const SUIGroupedTableViewDeleteButtonContentHeight = 44.0;
CGFloat const SUIGroupedTableViewDeleteButtonContentInset = 10.0;

#pragma mark - Construction & Destruction

- (id)initWithFrame:(CGRect)frame {
	if((self = [super initWithFrame:frame])) {
		[self initGroupedTableViewDeleteButton];
	}

	return self;
}

#pragma mark - UIButton

- (CGRect)backgroundRectForBounds:(CGRect)bounds {
	CGRect backgroundRect = [super backgroundRectForBounds:bounds];

	backgroundRect.origin.y = SUIGroupedTableViewDeleteButtonContentInset;
	backgroundRect.size.height = SUIGroupedTableViewDeleteButtonContentHeight;

	backgroundRect = CGRectInset(backgroundRect, SUIGroupedTableViewDeleteButtonContentInset, 0.0);

	return backgroundRect;
}

- (CGRect)contentRectForBounds:(CGRect)bounds {
	CGRect contentRect = [super contentRectForBounds:bounds];

	contentRect.origin.y += SUIGroupedTableViewDeleteButtonContentInset;
	contentRect.size.height = MIN(contentRect.size.height, SUIGroupedTableViewDeleteButtonContentHeight);

	return contentRect;
}

#pragma mark - UIView

- (CGSize)sizeThatFits:(CGSize)size {
	CGSize contentSize = [super sizeThatFits:size];
	
	contentSize.height = SUIGroupedTableViewDeleteButtonContentHeight + SUIGroupedTableViewDeleteButtonContentInset;

	return contentSize;
}

#pragma mark - Private

- (void)initGroupedTableViewDeleteButton {
	UIEdgeInsets capInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0);

	UIImage* backgroundImage = [[UIImage imageNamed:@"deletebutton"]
		resizableImageWithCapInsets:capInsets];
	[self setBackgroundImage:backgroundImage forState:UIControlStateNormal];

	backgroundImage = [[UIImage imageNamed:@"deletebutton-highlighted"]
		resizableImageWithCapInsets:capInsets];
	[self setBackgroundImage:backgroundImage forState:UIControlStateHighlighted];

	self.titleLabel.font = [UIFont boldSystemFontOfSize:19.0];
	self.titleLabel.textColor = [UIColor whiteColor];
	self.titleLabel.textAlignment = NSTextAlignmentCenter;

	self.titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
	self.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);

	[self setTitle:NSLocalizedString(@"TRASH_BUTTONITEM", nil) forState:UIControlStateNormal];
}

@end