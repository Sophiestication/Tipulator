//
//  TIPNumericKeypadView.m
//  Tipulator
//
//  Created by Sophia Teutschler on 21.09.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "TIPNumericKeypadView.h"
#import "TIPNumericKeypadButton.h"

@interface TIPNumericKeypadView()

@property(nonatomic) TIPNumericKeypadType keypadType;

@property(nonatomic, strong) UIImageView* backgroundView;

@property(nonatomic, strong) UIButton* clearButton;
@property(nonatomic, strong) UIButton* decimalSeparatorButton;

@end

@implementation TIPNumericKeypadView

#pragma mark - Construction & Destruction

- (id)initWithKeypadType:(TIPNumericKeypadType)keypadType {
	if((self = [self initWithFrame:CGRectMake(0.0, 0.0, 320.0, 216.0)])) {
		self.keypadType = keypadType;

		[self initBackgroundView];
		[self initKeypadButtons];
	}
	
	return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect contentRect = self.bounds;
	self.backgroundView.frame = contentRect;
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

#pragma mark - Private

- (void)initBackgroundView {
	UIImage* backgroundImage = [[UIImage imageNamed:@"keypad-background"]
		resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
		
	UIImageView* backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
	
	self.backgroundView = backgroundView;
	[self addSubview:backgroundView];
}

- (void)initKeypadButtons {
	NSInteger numberOfButtons = 9;

	NSInteger buttonIndex = 0;
	if(self.keypadType == TIPNumericKeypadTypeDecimal) {  buttonIndex = 1; } // skip the zero if needed

	NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
	formatter.numberStyle = NSNumberFormatterDecimalStyle;
	formatter.maximumFractionDigits = 0;
	
	for(; buttonIndex <= numberOfButtons; ++buttonIndex) {
		UIButton* button = [self newKeypadButtonWithTag:buttonIndex];
		
		NSString* title = [formatter stringFromNumber:@(buttonIndex)];
		[button setTitle:title forState:UIControlStateNormal];
		
		[button addTarget:self action:@selector(buttonTappedDown:event:) forControlEvents:UIControlEventTouchDown];
		[button addTarget:self action:@selector(decimalButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
		
		[self insertSubview:button aboveSubview:[self backgroundView]];
	}
	
	// extra wide zero keypad button
	if(self.keypadType == TIPNumericKeypadTypeDecimal) {
		UIButton* zeroButton = [self newZeroKeypadButton];
	
		NSString* zero = [formatter stringFromNumber:@(0)];
		[zeroButton setTitle:zero forState:UIControlStateNormal];
	
		[zeroButton addTarget:self action:@selector(buttonTappedDown:event:) forControlEvents:UIControlEventTouchDown];
		[zeroButton addTarget:self action:@selector(decimalButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];

		[self insertSubview:zeroButton aboveSubview:[self backgroundView]];
	}

	// clear button
	UIButton* clearButton = [self newClearKeypadButton];
	
	[clearButton addTarget:self action:@selector(buttonTappedDown:event:) forControlEvents:UIControlEventTouchDown];
	[clearButton addTarget:self action:@selector(clearButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
	
	self.clearButton = clearButton;
	[self insertSubview:clearButton aboveSubview:[self backgroundView]];

	// decimal separator button
	if(self.keypadType == TIPNumericKeypadTypeFractional) {
		UIButton* decimalSeparatorButton = [self newDecimalSeparatorButton];

		[decimalSeparatorButton addTarget:self action:@selector(buttonTappedDown:event:) forControlEvents:UIControlEventTouchDown];
		[decimalSeparatorButton addTarget:self action:@selector(decimalSeparatorButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
	
		self.decimalSeparatorButton = decimalSeparatorButton;
		[self insertSubview:decimalSeparatorButton aboveSubview:[self backgroundView]];
	}
}

- (UIButton*)newKeypadButtonWithTag:(NSInteger)tag {
	CGRect rect = [self rectForKeypadButtonWithTag:tag];
	TIPNumericKeypadButton* button = [[TIPNumericKeypadButton alloc] initWithFrame:rect];
	
	button.tag = tag;
	button.translatesAutoresizingMaskIntoConstraints = NO;
	
	return button;
}

- (UIButton*)newZeroKeypadButton {
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	button.tag = 0;
	button.frame = [self zeroButtonRect];
	
	UIImage* backgroundImage = [UIImage imageNamed:@"keypad-button-background"];
	backgroundImage = [backgroundImage
		resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)
		resizingMode:UIImageResizingModeTile];
	[button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
	
	backgroundImage = [UIImage imageNamed:@"keypad-button-background-highlighted"];
	backgroundImage = [backgroundImage
		resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)
		resizingMode:UIImageResizingModeTile];
	[button setBackgroundImage:backgroundImage forState:UIControlStateHighlighted];
	
	button.titleLabel.font = [UIFont boldSystemFontOfSize:23.0];
	
	UIColor* textColor = [UIColor colorWithRed:(51.0 / 0xff) green:(55.0 / 0xff) blue:(72.0 / 0xff) alpha:1.0];
	[button setTitleColor:textColor forState:UIControlStateNormal];

	UIColor* highlightedTextColor = [UIColor whiteColor];
	[button setTitleColor:highlightedTextColor forState:UIControlStateHighlighted];
	
	[button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:textColor forState:UIControlStateHighlighted];

	button.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	button.reversesTitleShadowWhenHighlighted = YES;

	button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 39.0, 0.0, 0.0);

	button.titleLabel.textAlignment = NSTextAlignmentLeft;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	
	button.accessibilityTraits = UIAccessibilityTraitButton|UIAccessibilityTraitKeyboardKey;

	return button;
}

- (UIButton*)newClearKeypadButton {
	UIButton* button = [self newAlternateKeypadButton];

	[button setTitle:@"C" forState:UIControlStateNormal];
	button.frame = CGRectMake(215.0, 163.0, 91.0, 43.0);
	
	button.accessibilityLabel = NSLocalizedString(@"accessibility.label.clear", nil);

	return button;
}

- (UIButton*)newDecimalSeparatorButton {
	UIButton* button = [self newAlternateKeypadButton];

	NSString* title = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
	[button setTitle:title forState:UIControlStateNormal];

	button.frame = CGRectMake(14.0, 163.0, 91.0, 43.0);
	
	button.accessibilityLabel = NSLocalizedString(@"accessibility.label.decimalSeparator", nil);

	return button;
}

- (UIButton*)newAlternateKeypadButton {
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	UIImage* backgroundImage = [UIImage imageNamed:@"keypad-button-background-highlighted"];
	backgroundImage = [backgroundImage
		resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)
		resizingMode:UIImageResizingModeTile];
	[button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
	
	backgroundImage = [UIImage imageNamed:@"keypad-button-background"];
	backgroundImage = [backgroundImage
		resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)
		resizingMode:UIImageResizingModeTile];
	[button setBackgroundImage:backgroundImage forState:UIControlStateHighlighted];
	
/*	UIImage* image = [UIImage imageNamed:@"keypadBackspaceImage"];
	[button setImage:image forState:UIControlStateNormal];
	
	UIImage* highlightedImage = [UIImage imageNamed:@"keypadBackspaceImageHighlighted"];
	[button setImage:highlightedImage forState:UIControlStateHighlighted]; */
	
	button.titleLabel.font = [UIFont boldSystemFontOfSize:23.0];
	
	UIColor* textColor = [UIColor whiteColor];
	[button setTitleColor:textColor forState:UIControlStateNormal];

	UIColor* highlightedTextColor =[UIColor colorWithRed:(51.0 / 0xff) green:(55.0 / 0xff) blue:(72.0 / 0xff) alpha:1.0];
	[button setTitleColor:highlightedTextColor forState:UIControlStateHighlighted];
	
	[button setTitleShadowColor:highlightedTextColor forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

	button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	button.reversesTitleShadowWhenHighlighted = YES;
	
	button.titleLabel.textAlignment = NSTextAlignmentCenter;
	
	button.accessibilityTraits = UIAccessibilityTraitButton|UIAccessibilityTraitKeyboardKey;

	return button;
}

- (CGRect)rectForKeypadButtonWithTag:(NSInteger)tag {
	CGRect rect = CGRectMake(0.0, 0.0, 91.0, 43.0);

	if(tag == 0) { rect.origin = CGPointMake(114.0, 163.0); }

	if(tag == 1) { rect.origin = CGPointMake(14.0, 112.0); }
	if(tag == 2) { rect.origin = CGPointMake(114.0, 112.0); }
	if(tag == 3) { rect.origin = CGPointMake(215.0, 112.0); }
	
	if(tag == 4) { rect.origin = CGPointMake(14.0, 61.0); }
	if(tag == 5) { rect.origin = CGPointMake(114.0, 61.0); }
	if(tag == 6) { rect.origin = CGPointMake(215.0, 61.0); }
	
	if(tag == 7) { rect.origin = CGPointMake(14.0, 10.0); }
	if(tag == 8) { rect.origin = CGPointMake(114.0, 10.0); }
	if(tag == 9) { rect.origin = CGPointMake(215.0, 10.0); }
	
	return rect;
}

- (CGRect)zeroButtonRect {
	if(self.keypadType == TIPNumericKeypadTypeDecimal) {
		return CGRectMake(14.0, 163.0, 191.0, 43.0);
	}

	if(self.keypadType == TIPNumericKeypadTypeFractional) {
		[self rectForKeypadButtonWithTag:0];
	}

	return CGRectZero;
}

- (void)buttonTappedDown:(id)sender event:(UIEvent*)event {
	[[UIDevice currentDevice] playInputClick];
}

- (void)decimalButtonTapped:(id)sender event:(UIEvent*)event {
	id<TIPNumericKeypadViewDelegate> delegate = self.keypadViewController.delegate;

	if([delegate respondsToSelector:@selector(numericKeypadView:didInsertString:)]) {
		// NSString* string = [@([(UIButton*)sender tag]) stringValue];
		NSString* string = [(UIButton*)sender currentTitle];
		[delegate numericKeypadView:[self keypadViewController] didInsertString:string];
	}
}

- (void)clearButtonTapped:(id)sender event:(UIEvent*)event {
	id<TIPNumericKeypadViewDelegate> delegate = self.keypadViewController.delegate;

	if([delegate respondsToSelector:@selector(numericKeypadViewDidClear:)]) {
		[delegate numericKeypadViewDidClear:[self keypadViewController]];
	}
}

- (void)decimalSeparatorButtonTapped:(id)sender event:(UIEvent*)event {
	[self decimalButtonTapped:sender event:event];
}

@end