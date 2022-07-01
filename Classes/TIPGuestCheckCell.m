//
//  TIPGuestCheckCell.m
//  Tipulator
//
//  Created by Sophia Teutschler on 16.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "TIPGuestCheckCell.h"

#import "UIColor+Tipulator.h"
#import "UILabel+Tipulator.h"
#import "UIImage+Styles.h"

@interface TIPGuestCheckCell()

@property(nonatomic, readwrite, strong) UILabel* titleLabel;
@property(nonatomic, readwrite, strong) UILabel* textLabel;

@property(nonatomic, strong) UIImageView* disclosureIndicator;
@property(nonatomic, strong) UIImageView* selectedDisclosureIndicator;

@property(nonatomic, readwrite, strong) UIButton* clearIndicator;

@end

@implementation TIPGuestCheckCell

NSString* const TIPGuestCheckCellIndicatorImageStyle = @"TIPGuestCheckCellIndicatorImageStyle";

#pragma mark - Construction & Destruction

+ (void)initialize {
	if(self != [TIPGuestCheckCell class]) { return; }

	NSDictionary* style = @{
		SUIImageStyleFillColor: [UIColor guestCheckTextColor],
		SUIImageStyleShadowColor: [UIColor guestCheckTextShadowColor],
		SUIImageStyleShadowOffset: [NSValue valueWithCGSize:CGSizeMake(0.0, -1.0)] };
	[UIImage registerImageStyle:style forKey:TIPGuestCheckCellIndicatorImageStyle];
}

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
		[self initTitleLabel];
		[self initTextLabel];
		[self initDisclosureIndicator];
		[self initClearIndicatorIfNeeded];
		
		self.shouldUseBoldStyle = NO;
    }

    return self;
}

#pragma mark - TIPGuestCheckCell

- (void)setShouldUseBoldStyle:(BOOL)shouldUseBoldStyle {
	// if(self.shouldUseBoldStyle == shouldUseBoldStyle) { return; }
	
	UIFont* font = shouldUseBoldStyle ?
		[UIFont boldSystemFontOfSize:17.0] :
		[UIFont systemFontOfSize:17.0];
	
	self.titleLabel.font = self.textLabel.font = font;
}

- (void)setIndicatorType:(TIPGuestCheckCellIndicatorType)indicatorType {
	if(self.indicatorType == indicatorType) { return; }

	_indicatorType = indicatorType;
	[self setNeedsLayout];
}

#pragma mark - UICollectionViewCell

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	[self updateForHighlightState];
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	[self updateForHighlightState];
}

#pragma mark - UIView

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
	if(self.indicatorType == TIPGuestCheckCellClearIndicatorType && self.clearIndicator.alpha > 0.0) {
		CGFloat clearIndicatorTargetWidth = 35.0;

		CGRect clearIndicatorTargetRect = self.contentView.bounds;
		clearIndicatorTargetRect.origin.x = CGRectGetMaxX(clearIndicatorTargetRect) - clearIndicatorTargetWidth;
		clearIndicatorTargetRect.size.width = clearIndicatorTargetWidth;

		if(CGRectContainsPoint(clearIndicatorTargetRect, point)) {
			return self.clearIndicator;
		}
	}


	return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGRect contentRect = self.contentView.bounds;
	contentRect = CGRectInset(contentRect, 10.0, 0.0);
	
	CGFloat const contentPadding = 10.0;
	CGFloat const maxTitleLabelSize = 125.0;
	
	// title label
	CGSize titleLabelSize = [[self titleLabel]
		sizeThatFits:contentRect.size];
	titleLabelSize.width = MIN(titleLabelSize.width, maxTitleLabelSize);
	
	CGRect titleLabelRect = CGRectMake(
		(CGRectGetMinX(contentRect) + contentPadding + maxTitleLabelSize) - titleLabelSize.width,
		round(CGRectGetMidY(contentRect) - titleLabelSize.height * 0.5),
		titleLabelSize.width,
		titleLabelSize.height);

	// disclosure indicator
	CGSize disclosureIndicatorSize = [[self disclosureIndicator]
		sizeThatFits:contentRect.size];
	
	CGRect disclosureIndicatorRect = CGRectMake(
		CGRectGetMaxX(contentRect) - contentPadding * 0.5 - disclosureIndicatorSize.width,
		round(CGRectGetMidY(contentRect) - disclosureIndicatorSize.height * 0.5),
		disclosureIndicatorSize.width,
		disclosureIndicatorSize.height);
	
	// text label
	CGFloat textLabelMinX = CGRectGetMaxX(titleLabelRect) + contentPadding * 0.5;
	CGFloat textLabelMaxX = CGRectGetMinX(disclosureIndicatorRect) - contentPadding;
	
	CGSize textLabelSize = [[self textLabel]
		sizeThatFits:contentRect.size];
	textLabelSize.width = MIN(
		textLabelSize.width,
		textLabelMaxX - textLabelMinX);
	
	CGRect textLabelRect = CGRectMake(
		textLabelMaxX - textLabelSize.width,
		round(CGRectGetMidY(contentRect) - textLabelSize.height * 0.5),
		textLabelSize.width,
		textLabelSize.height);
	
	// center title label if needed
	BOOL shouldCenterTitle = self.textLabel.text.length == 0;
	
	if(shouldCenterTitle) {
		titleLabelRect.origin.x = CGRectGetMinX(contentRect);
		titleLabelRect.size.width = CGRectGetWidth(contentRect);
		
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
	} else {
		self.titleLabel.textAlignment = NSTextAlignmentRight;
	}

	// clear indicator
	CGSize clearIndicatorSize = [[self clearIndicator] sizeThatFits:contentRect.size];
	CGRect clearIndicatorRect = CGRectMake(
		round(CGRectGetMidX(disclosureIndicatorRect) - clearIndicatorSize.width * 0.5),
		round(CGRectGetMidY(disclosureIndicatorRect) - clearIndicatorSize.height * 0.5),
		clearIndicatorSize.width,
		clearIndicatorSize.height);
	
	self.titleLabel.frame = titleLabelRect;
	self.disclosureIndicator.frame = self.selectedDisclosureIndicator.frame = disclosureIndicatorRect;
	self.clearIndicator.frame = clearIndicatorRect;
	self.textLabel.frame = textLabelRect;

	[self updateForHighlightState];
}

#pragma mark - Private

- (void)initTitleLabel {
	UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	
	[titleLabel setGuestCheckStyle];
	
	titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

	self.titleLabel = titleLabel;
	[[self contentView] addSubview:titleLabel];
}

- (void)initTextLabel {
	UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	
	[textLabel setGuestCheckStyle];
	
	textLabel.translatesAutoresizingMaskIntoConstraints	= NO;

	self.textLabel = textLabel;
	[[self contentView] addSubview:textLabel];
}

- (void)initDisclosureIndicator {
	UIImage* image = [UIImage imageNamed:@"disclosure-indicator" style:TIPGuestCheckCellIndicatorImageStyle];
	UIImage* highlightedImage = [UIImage imageNamed:@"disclosure-indicator" style:SUITableViewCellSelectedImageStyle];
	
	UIImageView* disclosureIndicator = [[UIImageView alloc] initWithImage:image highlightedImage:highlightedImage];
	self.disclosureIndicator = disclosureIndicator;
	[[self contentView] insertSubview:disclosureIndicator belowSubview:[self textLabel]];
	
	UIImageView* selectedDisclosureIndicator = [[UIImageView alloc] initWithImage:highlightedImage];
	self.selectedDisclosureIndicator = selectedDisclosureIndicator;
	[[self contentView] insertSubview:selectedDisclosureIndicator belowSubview:disclosureIndicator];
}

- (void)initClearIndicatorIfNeeded {
	UIButton* clearIndicator = [UIButton buttonWithType:UIButtonTypeCustom];

	UIImage* image = [UIImage imageNamed:@"clear-indicator" style:SUITableViewCellSelectedImageStyle];
	[clearIndicator setImage:image forState:UIControlStateNormal];

	clearIndicator.showsTouchWhenHighlighted = YES;
	clearIndicator.adjustsImageWhenHighlighted = NO;

	self.clearIndicator = clearIndicator;
	[[self contentView] insertSubview:clearIndicator belowSubview:[self textLabel]];
}

- (void)updateForHighlightState {
	BOOL highlighted = self.highlighted || self.selected;

	UIColor* shadowColor = highlighted ?
		[UIColor clearColor] :
		[UIColor guestCheckTextShadowColor];
	self.titleLabel.shadowColor = self.textLabel.shadowColor = shadowColor;

	BOOL shouldShowClearIndicator =
		self.indicatorType == TIPGuestCheckCellClearIndicatorType &&
		self.selected;

	if(shouldShowClearIndicator) {
		self.disclosureIndicator.alpha = self.selectedDisclosureIndicator.alpha = 0.0;
		self.clearIndicator.alpha = 1.0;
	} else {
		self.disclosureIndicator.alpha = highlighted ? 0.0 : 1.0;
		self.selectedDisclosureIndicator.alpha = highlighted ? 1.0 : 0.0;
		self.clearIndicator.alpha = 0.0;
	}
}

@end