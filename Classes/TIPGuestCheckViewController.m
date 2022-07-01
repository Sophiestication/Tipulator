//
//  TIPGuestCheckViewController.m
//  Tipulator
//
//  Created by Sophia Teutschler on 14.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "TIPGuestCheckViewController.h"

#import "TIPGuestCheckCell.h"

#import "TIPNumericKeypadViewController.h"
#import "TIPTipAmountViewController.h"
#import "TIPTaxAmountViewController.h"
#import "TIPRoundingOptionsViewController.h"
#import "TIPSplitCheckViewController.h"

#import "TIPCalculator.h"

#import "NSArray+Additions.h"
#import "NSBundle+Localization.h"

#import "UIImage+Additions.h"
#import "UIColor+Tipulator.h"
#import "UILabel+Tipulator.h"

#import <AVFoundation/AVFoundation.h>

@interface TIPGuestCheckViewController()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TIPNumericKeypadViewDelegate, TIPTipAmountViewDelegate, TIPRoundingOptionsViewDelegate, TIPSplitCheckViewDelegate>

@property(nonatomic, strong) UIImageView* backgroundView;

@property(nonatomic, strong) UIToolbar* toolbar;

@property(nonatomic, strong) UIButton* titleView;
@property(nonatomic, strong) UIImageView* candyView;
@property(nonatomic, strong) UIView* candyHitTargetView;

@property(nonatomic, strong) UIView* maskingContainerView;
@property(nonatomic, strong) UICollectionView* contentView;

@property(nonatomic, strong) UILabel* checkNumber;
@property(nonatomic, strong) UILabel* checkNumberLabel;

@property(nonatomic, strong) UILabel* checkDate;
@property(nonatomic, strong) UILabel* checkDateLabel;

@property(nonatomic, strong) UIButton* logoButton;

@property(nonatomic, strong) UIBarButtonItem* doneButtonItem;

@property(nonatomic, strong) NSNumberFormatter* currencyFormatter;
@property(nonatomic, strong) NSNumberFormatter* percentFormatter;
@property(nonatomic, strong) NSNumberFormatter* decimalNumberFormatter;
@property(nonatomic, strong) NSDateFormatter* dateFormatter;

@property(nonatomic, strong) UIViewController* inputViewController;

@property(nonatomic, strong) TIPNumericKeypadViewController* checkAmountViewController;
@property(nonatomic, strong) TIPTipAmountViewController* tipAmountViewController;
@property(nonatomic, strong) TIPNumericKeypadViewController* taxAmountViewController;
@property(nonatomic, strong) TIPRoundingOptionsViewController* roundingOptionsViewController;
@property(nonatomic, strong) TIPSplitCheckViewController* splitCheckViewController;

@property(nonatomic) NSTimeInterval preferredAnimationDuration;
@property(nonatomic) UIViewAnimationCurve preferredAnimationCurve;

@property(nonatomic) AVAudioPlayer* deliciousSound;
@property(nonatomic) BOOL candyEaten;

@property(nonatomic) BOOL contentViewsVisible;
@property(nonatomic) BOOL shouldPreventKeyboardAnimation;

@property(nonatomic) BOOL shouldPreferVisibleKeyboard;

@property(nonatomic, strong) NSDictionary* decodedApplicationState;

@property(nonatomic, strong) TIPCalculator* calculator;

@end

@implementation TIPGuestCheckViewController

#pragma mark - Construction & Destruction

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];

		self.preferredAnimationDuration = 0.25;
		self.preferredAnimationCurve = UIViewAnimationCurveEaseInOut;
    }

    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSCurrentLocaleDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationSignificantTimeChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - TIPGuestCheckViewController

- (void)presentInputViewController:(UIViewController*)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
	if(!viewController) { return; }
	if(viewController == self.inputViewController) { return; }

	self.inputViewController = viewController;

	[self updateDoneButtonItem];

	[self reloadInputViews];
	
	self.shouldPreventKeyboardAnimation = !animated;
	[self becomeFirstResponder];
}

- (void)dismissInputViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
	if(!self.inputViewController) { return; }

	self.inputViewController = nil;
	[self reloadInputViews];

	self.shouldPreventKeyboardAnimation = !animated;
	// [self resignFirstResponder];

	NSIndexPath* indexPath = [[[self contentView] indexPathsForSelectedItems] lastObject];
	[[self contentView] deselectItemAtIndexPath:indexPath animated:animated];
}

- (void)clear:(id)sender {
	if(![[self calculator] hasValidCheckAmount]) { return; }

	[self advanceCheckNumber];

	self.calculator.checkAmount = nil;
	[self updateContentView];

	// was clear triggered by a motion event?
	if([sender isKindOfClass:[UIEvent class]]) {
		// vibrate
		UIEvent* event = sender;

		if(event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		}

		// select check amount
		[self selectItemAtIndexPath:[self checkAmountIndexPath]];
	}
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (UIView*)inputView {
	return self.inputViewController.view;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent*)event {
	[super motionBegan:motion withEvent:event];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent*)event {
	[super motionEnded:motion withEvent:event];

	if(motion == UIEventSubtypeMotionShake) {
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"TIPShakeToClearEnabled"]) {
			[self clear:event];
		}
	}
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent*)event {
	[super motionCancelled:motion withEvent:event];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.shouldPreferVisibleKeyboard = [self shouldUseLongPhoneLayout];

	// formatters
	[self loadFormatters];
	
	// tip calculator
	[self loadCalculator];
	
	// subview hierarchy
	[self loadBackgroundView];
	[self loadToolbar];
	[self loadHeaderViews];
	[self loadContentView];
	[self loadFooterViews];

	[self loadNumbericKeypadViewController];
	[self loadTipAmountViewController];
	[self loadTaxAmountViewController];
	[self loadRoundingOptionsViewController];
	[self loadSplitCheckViewController];

	// notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocaleDidChange:) name:NSCurrentLocaleDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(significantTimeChange:) name:UIApplicationSignificantTimeChangeNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

	// delicious sound
	[self loadEasterEgg];
	
	// restore from defaults
	[self restoreFromUserDefaults];

	[[self view] updateConstraintsIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self updateContentView];
	[self updateCheckDate];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	// transition content views in if needed
	UIView* candyView = self.candyView;

	NSIndexPath* selectedIndexPath = [[self decodedApplicationState] objectForKey:@"selectedIndexPath"];
	if(selectedIndexPath) { self.candyEaten = YES; candyView.hidden = YES; }

	[self setContentViewsVisible:YES animated:YES completion:^(BOOL finished) {
		candyView.hidden = NO;
	}];

	if(!selectedIndexPath) { return; }

	[self presentInputViewControllerForItemAtIndexPath:selectedIndexPath animated:YES];
	[[self contentView] selectItemAtIndexPath:selectedIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];

	CGPoint contentOffset = [[[self decodedApplicationState] objectForKey:@"contentOffset"] CGPointValue];
	[[self contentView] setContentOffset:contentOffset animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	if(editing == self.editing) { return; }

	[[self view] setNeedsLayout];

	void (^animations)(void) = ^() {
		[super setEditing:editing animated:animated];
		[[self view] layoutIfNeeded];
	};

	if(animated) {
		[UIView setAnimationCurve:[self preferredAnimationCurve]];
		NSTimeInterval duration = self.preferredAnimationDuration;

		[UIView animateWithDuration:duration delay:0.0 options:0 animations:animations completion:nil];
	} else {
		animations();
	}
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	CGRect bounds = self.view.bounds;
	
	// self.backgroundView.frame = bounds;

	// header
	CGRect titleViewRect = self.titleView.frame;
	titleViewRect.origin = CGPointMake(20.0, 17.0);
	self.titleView.frame = titleViewRect;

	CGRect candyViewRect = self.candyView.frame;
	candyViewRect.origin = CGPointMake(CGRectGetMaxX(bounds) - 108.0, 3.0);

	if(self.editing && !self.shouldPreferVisibleKeyboard) {
		candyViewRect.origin.x = CGRectGetMaxX(bounds); // move offscreen
	}

	if(!self.candyEaten && !self.editing) {
		self.candyView.alpha = 1.0;
	}

	self.candyView.frame = candyViewRect;
	
	self.candyHitTargetView.frame = CGRectMake(CGRectGetMaxX(bounds) - 108.0, 0.0, 108.0, 72.0);
	self.candyHitTargetView.hidden = self.editing;
	
	self.toolbar.frame = CGRectMake(6.0, 16.0, CGRectGetWidth(bounds) - 16.0, 44.0);
	self.toolbar.alpha = self.editing ? 1.0 : 0.0;

	// content
	CGRect contentViewRect = CGRectMake(
		0.0, 64.0,
		CGRectGetWidth(bounds), CGRectGetHeight(bounds) - 126.0);
		
	if(!CGSizeEqualToSize(self.contentView.frame.size, contentViewRect.size)) {
		self.maskingContainerView.frame = contentViewRect;
		self.contentView.frame = self.maskingContainerView.bounds;
		self.maskingContainerView.layer.mask.frame = CGRectOffset(CGRectInset(self.maskingContainerView.bounds, 0.0, -10.0), 0.0, -15.0);
	}
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	CGFloat alpha = self.contentViewsVisible ? 1.0 : 0.0;
		
	self.contentView.alpha =
		self.candyView.alpha =
		self.titleView.alpha =
		self.checkNumber.alpha =
		self.checkNumberLabel.alpha =
		self.checkDate.alpha =
		self.checkDateLabel.alpha =
		self.logoButton.alpha = alpha;
}

#pragma mark - User Defaults

- (void)storeUserDefaults {
	NSMutableDictionary* defaults = [NSMutableDictionary dictionaryWithCapacity:4];
	
	// calculator
	NSNumber* checkAmount = self.calculator.checkAmount;
	[defaults setValue:checkAmount forKey:@"checkAmount"];
	
	NSNumber* tip = self.calculator.tipPercentage;
	[defaults setValue:tip forKey:@"tip"];
	
	NSNumber* tax = self.calculator.salesTax;
	[defaults setValue:tax forKey:@"tax"];
	
	NSNumber* split = self.calculator.split;
	[defaults setValue:split forKey:@"split"];
	
	TIPRoundingOption roundingOption = self.calculator.roundingOption;
	[defaults setValue:@(roundingOption) forKey:@"roundingOption"];
	
	[[NSUserDefaults standardUserDefaults] setObject:defaults forKey:@"TIPGuestCheck"];
}

- (void)restoreFromUserDefaults {
	NSDictionary* defaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"TIPGuestCheck"];

	// calculator
	NSNumber* checkAmount = [defaults objectForKey:@"checkAmount"];
	self.calculator.checkAmount = checkAmount;
	
	NSNumber* tip = [defaults objectForKey:@"tip"];
	self.calculator.tipPercentage = self.tipAmountViewController.tipAmount = tip;
	
	NSNumber* tax = [defaults objectForKey:@"tax"];
	self.calculator.salesTax = tax;
	
	NSNumber* split = [defaults objectForKey:@"split"];
	self.calculator.split = self.splitCheckViewController.selectedValue = split;
	
	TIPRoundingOption roundingOption = [[defaults objectForKey:@"roundingOption"] integerValue];
	self.calculator.roundingOption = self.roundingOptionsViewController.selectedRoundingOption = roundingOption;

	self.calculator.excludeTaxFromTipCalculation = [[NSUserDefaults standardUserDefaults] boolForKey:@"TIPExcludeTaxFromTipCalculation"];
}

#pragma mark - State Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	// selection
	NSIndexPath* selectedIndexPath = [[[self contentView] indexPathsForSelectedItems] lastObject];
	
	NSString* selection;
	if([selectedIndexPath isEqual:[self checkAmountIndexPath]]) { selection = @"checkAmount"; }
	if([selectedIndexPath isEqual:[self tipAmountIndexPath]]) { selection = @"tipAmount"; }
	if([selectedIndexPath isEqual:[self taxAmountIndexPath]]) { selection = @"taxAmount"; }
	if([selectedIndexPath isEqual:[self totalAmountIndexPath]]) { selection = @"totalAmount"; }
	if([selectedIndexPath isEqual:[self splitCheckIndexPath]]) { selection = @"splitCheck"; }
	
	[coder encodeObject:selection forKey:@"selection"];
	
	CGPoint contentOffset = self.contentView.contentOffset;
	[coder encodeCGPoint:contentOffset forKey:@"contentOffset"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
	BOOL preiOS61 = [systemVersion compare:@"6.1"] == NSOrderedAscending;

	// selection
	NSString* selection = [coder decodeObjectOfClass:[NSString class] forKey:@"selection"];
	NSIndexPath* selectedIndexPath;
	
	if([selection isEqualToString:@"checkAmount"]) { selectedIndexPath = [self checkAmountIndexPath]; }
	if([selection isEqualToString:@"tipAmount"]) { selectedIndexPath = [self tipAmountIndexPath]; }
	if([selection isEqualToString:@"taxAmount"]) { selectedIndexPath = [self taxAmountIndexPath]; }
	if([selection isEqualToString:@"totalAmount"]) { selectedIndexPath = [self totalAmountIndexPath]; }
	if([selection isEqualToString:@"splitCheck"]) { selectedIndexPath = [self splitCheckIndexPath]; }

	if(!preiOS61) {
		NSMutableDictionary* decodedApplicationState = [NSMutableDictionary dictionaryWithCapacity:2];
		[decodedApplicationState setValue:selectedIndexPath forKey:@"selectedIndexPath"];

		CGPoint contentOffset = [coder decodeCGPointForKey:@"contentOffset"];
		[decodedApplicationState setValue:[NSValue valueWithCGPoint:contentOffset] forKey:@"contentOffset"];

		self.decodedApplicationState = decodedApplicationState;

		return; // animate in after viewDidAppear: for iOS 6.1 and later
	}

	[self setContentViewsVisible:YES animated:NO completion:nil];

	if(selectedIndexPath) {
		[self presentInputViewControllerForItemAtIndexPath:selectedIndexPath animated:NO];
		[[self contentView] selectItemAtIndexPath:selectedIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
		self.contentView.contentOffset = [coder decodeCGPointForKey:@"contentOffset"];
	}

	[self updateDoneButtonItem];

	[[self view] setNeedsLayout];
	[[self view] layoutIfNeeded];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
	if(self.shouldPreferVisibleKeyboard) {
		[self dismissInputViewControllerAfterScrolling:scrollView];
	}
}

- (void)dismissInputViewControllerAfterScrolling:(id)sender {
	[self dismissInputViewController:sender event:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionViewCell*)collectionView {
	return 2;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
	if(section == 0) { return 4; }
	if(section == 1) { return 1; }
	return 0;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
	TIPGuestCheckCell* cell = [collectionView
		dequeueReusableCellWithReuseIdentifier:[[self class] regularCellReuseIdentifier]
		forIndexPath:indexPath];
	
	[self configureCell:cell forItemAtIndexPath:indexPath];
	
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView*)collectionView shouldSelectItemAtIndexPath:(NSIndexPath*)indexPath {
	return YES;
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath {
	[self reloadCellForItemAtIndexPath:indexPath];
	
	[self presentInputViewControllerForItemAtIndexPath:indexPath animated:YES];
	[collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath*)indexPath {
	return YES;
}

- (void)collectionView:(UICollectionView*)collectionView didDeselectItemAtIndexPath:(NSIndexPath*)indexPath {
	[self reloadCellForItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
	if(section + 1 == [collectionView numberOfSections]) { return CGSizeMake(0.0, 10.0); }
	return CGSizeZero;
}

#pragma mark - TIPNumericKeypadViewDelegate

- (void)numericKeypadView:(TIPNumericKeypadViewController*)viewController didInsertString:(NSString*)string {
	if(viewController == self.checkAmountViewController) {
		[[self calculator] appendCheckAmountString:string];
		[self updateContentView];
	}

	if(viewController == self.taxAmountViewController) {
		[[self calculator] appendTaxString:string];
		[self updateContentView];
	}
}

- (void)numericKeypadViewDidClear:(TIPNumericKeypadViewController*)viewController {
	if(viewController == self.checkAmountViewController) {
		[self clear:viewController];
	}

	if(viewController == self.taxAmountViewController) {
		self.calculator.salesTax = nil;
		[self updateContentView];
	}
}

#pragma mark - TIPTipAmountViewDelegate

- (void)tipAmountViewController:(TIPTipAmountViewController*)viewController didSelectValue:(NSNumber*)tipAmount {
	self.calculator.tipPercentage = tipAmount;
	[self updateContentView];
}

#pragma mark - TIPRoundingOptionsViewController

- (void)roundingOptionsView:(TIPRoundingOptionsViewController*)viewController didSelectOption:(TIPRoundingOption)roundingOption {
	self.calculator.roundingOption = roundingOption;
	[self updateContentView];
}

#pragma mark - TIPSplitCheckViewDelegate

- (void)splitCheckView:(TIPSplitCheckViewController*)viewController didSelectValue:(NSNumber*)value {
	self.calculator.split = value;
	[self updateContentView];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillChangeFrame:(NSNotification*)notification {
	if(self.shouldPreventKeyboardAnimation) {
		[UIView setAnimationsEnabled:NO];
	}

	NSDictionary* userInfo = [notification userInfo];

	NSTimeInterval preferredAnimationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	self.preferredAnimationDuration = preferredAnimationDuration;

	UIViewAnimationCurve preferredAnimationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	self.preferredAnimationCurve = preferredAnimationCurve;

	BOOL editing = self.inputViewController != nil;
	[self setEditing:editing animated:YES];
	
	CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	[self updateContentInsetsForKeyboardRect:keyboardRect];
}

- (void)keyboardDidChangeFrame:(NSNotification*)notification {
	if(self.shouldPreventKeyboardAnimation) {
		[UIView setAnimationsEnabled:YES];
		self.shouldPreventKeyboardAnimation = NO;
	}
}

- (void)updateContentInsetsForKeyboardRect:(CGRect)keyboardRect {
	if(self.shouldPreferVisibleKeyboard) { return; }

	CGRect contentViewRect = self.contentView.bounds;
	contentViewRect = [[self contentView] convertRect:contentViewRect toView:nil];

	CGFloat bottomInset = CGRectGetMaxY(contentViewRect) - CGRectGetMinY(keyboardRect);

	UIEdgeInsets contentInset = self.contentView.contentInset;
	contentInset.bottom = bottomInset;
	
	UIEdgeInsets indicatorInsets = self.contentView.scrollIndicatorInsets;
	indicatorInsets.bottom = bottomInset;
	
	[UIView animateWithDuration:[self preferredAnimationDuration] animations:^() {
		self.contentView.contentInset = contentInset;
		self.contentView.scrollIndicatorInsets = indicatorInsets;
	}];
}

#pragma mark - NSCurrentLocaleDidChangeNotification

- (void)currentLocaleDidChange:(NSNotification*)notification {
	[self loadFormatters];
	[self reloadAllCellsForVisibleItems];
}

#pragma mark - NSUserDefaultsDidChangeNotification

- (void)userDefaultsDidChange:(NSNotification*)notification {
	BOOL excludeTaxFromTipCalculation = [[NSUserDefaults standardUserDefaults] boolForKey:@"TIPExcludeTaxFromTipCalculation"];

	if(excludeTaxFromTipCalculation != self.calculator.excludeTaxFromTipCalculation) {
		self.calculator.excludeTaxFromTipCalculation = excludeTaxFromTipCalculation;
		[self updateContentView];
	}
}

#pragma mark - UIApplicationSignificantTimeChangeNotification

- (void)significantTimeChange:(NSNotification*)notification {
	[self updateCheckDate];
}

#pragma mark - UIApplicationWillResignActiveNotification

- (void)applicationWillResignActive:(NSNotification*)notification {
	[self storeUserDefaults];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Private

+ (NSString*)regularCellReuseIdentifier { return @"regular"; }

- (NSIndexPath*)checkAmountIndexPath { return [NSIndexPath indexPathForItem:0 inSection:0]; }
- (NSIndexPath*)taxAmountIndexPath { return [NSIndexPath indexPathForItem:1 inSection:0]; }
- (NSIndexPath*)tipAmountIndexPath { return [NSIndexPath indexPathForItem:2 inSection:0]; }
- (NSIndexPath*)totalAmountIndexPath { return [NSIndexPath indexPathForItem:3 inSection:0]; }

- (NSIndexPath*)splitCheckIndexPath { return [NSIndexPath indexPathForItem:0 inSection:1]; }

#pragma mark - Loading

- (void)loadFormatters {
	// currency formatter
	NSNumberFormatter* currencyFormatter = [[NSNumberFormatter alloc] init];

	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyFormatter setMinimumFractionDigits:2];
	[currencyFormatter setMaximumFractionDigits:2];

	if([[currencyFormatter currencySymbol] length] >= 3) {
		[currencyFormatter setCurrencySymbol:@""];
	}

	self.currencyFormatter = currencyFormatter;
	
	// percentage formatter
	NSNumberFormatter* percentFormatter = [[NSNumberFormatter alloc] init];

	[percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
	[percentFormatter setMaximumFractionDigits:4];
	[percentFormatter setAlwaysShowsDecimalSeparator:NO];
	
	self.percentFormatter = percentFormatter;

	// date formatter
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];

	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	
	self.dateFormatter = dateFormatter;

	// decimal number formatter
	NSNumberFormatter* decimalNumberFormatter = [[NSNumberFormatter alloc] init];

	[decimalNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[decimalNumberFormatter setMaximumFractionDigits:1];
	[decimalNumberFormatter setAlwaysShowsDecimalSeparator:NO];
	
	self.decimalNumberFormatter = decimalNumberFormatter;
}

- (void)loadCalculator {
	TIPCalculator* calculator = [[TIPCalculator alloc] init];
	
	self.calculator = calculator;
}

- (void)loadEasterEgg {
	[[AVAudioSession sharedInstance]
		setCategory:AVAudioSessionCategoryAmbient
		error:nil];
	[[AVAudioSession sharedInstance] setActive:YES error:nil];

	NSURL* URL = [[NSBundle mainBundle] URLForResource:@"delicious" withExtension:@"aif"];
	AVAudioPlayer* deliciousSound = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:nil];
	[deliciousSound prepareToPlay];
	self.deliciousSound = deliciousSound;
}

- (void)loadBackgroundView {
	NSString* backgroundImageName = [self shouldUseLongPhoneLayout] ?
		@"background-568h" :
		@"background";
//	NSString* backgroundImageName = [self shouldUseLongPhoneLayout] ?
//		@"Default-568h" :
//		@"Default";
	UIImage* backgroundImage = [UIImage imageNamed:backgroundImageName];
	
	UIImageView* backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
	
	backgroundView.contentMode = UIViewContentModeTop;
	
	self.backgroundView = backgroundView;
	[[self view] addSubview:backgroundView];
}

- (void)loadToolbar {
	UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
	
	UIImage* transparentImage = [UIImage transparentImage];
	[toolbar setBackgroundImage:transparentImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];

	self.toolbar = toolbar;
	[[self view] insertSubview:toolbar aboveSubview:[self backgroundView]];
	
	[self loadButtonItems];
}

- (void)loadButtonItems {
	if(self.shouldPreferVisibleKeyboard) { return; }

	UIBarButtonItem* doneButtonItem = [[UIBarButtonItem alloc]
		initWithTitle:SUILocalizedString(@"DONE_BUTTONITEM", nil)
		style:UIBarButtonItemStyleBordered
		target:self
		action:@selector(done:event:)];

	UIImage* backgroundImage = [[UIImage imageNamed:@"buttonitem-background"]
		resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)
		resizingMode:UIImageResizingModeTile];
	[doneButtonItem setBackgroundImage:backgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	backgroundImage = [[UIImage imageNamed:@"buttonitem-background-highlighted"]
		resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)
		resizingMode:UIImageResizingModeTile];
	[doneButtonItem setBackgroundImage:backgroundImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

	NSDictionary* titleAttributes = @{
		// UITextAttributeFont: [UIFont boldSystemFontOfSize:13.0],
		UITextAttributeTextColor: [UIColor guestCheckTextColor],
		UITextAttributeTextShadowColor: [[UIColor whiteColor] colorWithAlphaComponent:0.5],
		UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)] };
	[doneButtonItem setTitleTextAttributes:titleAttributes forState:UIControlStateNormal];
	[doneButtonItem setTitleTextAttributes:titleAttributes forState:UIControlStateHighlighted];
	
	[doneButtonItem
		setTitlePositionAdjustment:UIOffsetMake(0.0, 1.0)
		forBarMetrics:UIBarMetricsDefault];
	
	doneButtonItem.possibleTitles = [NSSet setWithObjects:
		SUILocalizedString(@"DONE_BUTTONITEM", nil),
		SUILocalizedString(@"NEXT_BUTTONITEM", nil),
		nil];
		
	self.toolbar.items = @[
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
		doneButtonItem ];
	self.doneButtonItem = doneButtonItem;
}

- (void)loadHeaderViews {
	// title label
	UIButton* titleView = [UIButton buttonWithType:UIButtonTypeCustom];
	
	UIImage* titleImage = [UIImage imageNamed:@"tipulator"];
	[titleView setImage:titleImage forState:UIControlStateNormal];
	
	titleView.adjustsImageWhenHighlighted = NO;
	
	[titleView
		addTarget:self
		action:@selector(dismissInputViewController:event:)
		forControlEvents:UIControlEventTouchUpInside];
		
	titleView.accessibilityTraits = UIAccessibilityTraitHeader;
	
	[titleView sizeToFit];
	
	self.titleView = titleView;
	[[self view] insertSubview:titleView aboveSubview:[self toolbar]];

	// candy
	UIImage* candyImage = [UIImage imageNamed:@"candy"];
	UIImageView* candyView = [[UIImageView alloc] initWithImage:candyImage];
	
	self.candyView = candyView;
	[[self view] insertSubview:candyView aboveSubview:titleView];

	// hit target
	UIButton* candyHitTargetView = [UIButton buttonWithType:UIButtonTypeCustom];

	[candyHitTargetView addTarget:self action:@selector(targetButtonTouchUpInside:event:) forControlEvents:UIControlEventTouchUpInside];
	candyHitTargetView.accessibilityElementsHidden = YES;

	self.candyHitTargetView = candyHitTargetView;
	[[self view] insertSubview:candyHitTargetView aboveSubview:candyView];
}

- (void)loadContentView {
	// masking container view
	UIView* maskingContainerView = [[UIView alloc] initWithFrame:CGRectZero];

	UIImage* maskImage = [[UIImage imageNamed:@"content-mask"]
		resizableImageWithCapInsets:UIEdgeInsetsMake(43.0, 0.0, 43.0, 0.0)
		resizingMode:UIImageResizingModeStretch];
	UIImageView* maskImageView = [[UIImageView alloc] initWithImage:maskImage];

	maskingContainerView.layer.mask = maskImageView.layer;

	self.maskingContainerView = maskingContainerView;
	[[self view] insertSubview:maskingContainerView aboveSubview:[self backgroundView]];

	// content view
	UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
	
	layout.itemSize = CGSizeMake(286.0, 44.0);
	layout.minimumInteritemSpacing = 0.0;
	layout.minimumLineSpacing = 0.0;
	
	layout.sectionInset = UIEdgeInsetsMake(10.0, 0.0, 0.0, 0.0);
	
	UICollectionView* contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
	
	[contentView
		registerClass:[TIPGuestCheckCell class]
		forCellWithReuseIdentifier:[[self class] regularCellReuseIdentifier]];
	
	contentView.dataSource = self;
	contentView.delegate = self;
	
	contentView.alwaysBounceVertical = YES;
	
	// contentView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
	contentView.backgroundColor = [UIColor clearColor];
	
	contentView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 7.0);

	self.contentView = contentView;
	[maskingContainerView addSubview:contentView];
}

- (void)loadFooterViews {
	CGFloat const valueFontSize = 16.0;
	CGFloat const labelFontSize = 10.0;

	// check number
	UILabel* checkNumber = [[UILabel alloc] initWithFrame:CGRectZero];
	
	// checkNumber.text = @"220380-07";
	
	checkNumber.font = [UIFont systemFontOfSize:valueFontSize];
	[checkNumber setGuestCheckStyle];
	
	checkNumber.translatesAutoresizingMaskIntoConstraints = NO;
	
	self.checkNumber = checkNumber;
	[[self view] insertSubview:checkNumber aboveSubview:[self contentView]];
	
	UILabel* checkNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	
	checkNumberLabel.text = SUILocalizedString(@"CHECKNUMBER_LABEL", nil);
	
	checkNumberLabel.font = [UIFont boldSystemFontOfSize:labelFontSize];
	[checkNumberLabel setGuestCheckStyle];
	
	checkNumberLabel.translatesAutoresizingMaskIntoConstraints = NO;
	
	self.checkNumberLabel = checkNumberLabel;
	[[self view] insertSubview:checkNumberLabel belowSubview:checkNumber];
	
	// check date
	UILabel* checkDate = [[UILabel alloc] initWithFrame:CGRectZero];
	
	// checkDate.text = [[self dateFormatter] stringFromDate:[NSDate date]];
	
	checkDate.font = [UIFont systemFontOfSize:valueFontSize];
	[checkDate setGuestCheckStyle];
	
	checkDate.translatesAutoresizingMaskIntoConstraints = NO;
	
	self.checkDate = checkDate;
	[[self view] insertSubview:checkDate aboveSubview:[self contentView]];
	
	UILabel* checkDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	
	checkDateLabel.text = SUILocalizedString(@"CHECKDATE_LABEL", nil);
	
	checkDateLabel.font = [UIFont boldSystemFontOfSize:labelFontSize];
	[checkDateLabel setGuestCheckStyle];
	
	checkDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
	
	self.checkDateLabel = checkDateLabel;
	[[self view] insertSubview:checkDateLabel belowSubview:checkDate];

	[self updateCheckDate];

	// sophiestication logo
	UIImage* logoImage = [UIImage imageNamed:@"sophiestication"];

	UIButton* logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[logoButton setImage:logoImage forState:UIControlStateNormal];

	logoButton.adjustsImageWhenHighlighted = NO;
	logoButton.showsTouchWhenHighlighted = YES;

	logoButton.translatesAutoresizingMaskIntoConstraints = NO;

	logoButton.contentEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
	// logoButton.backgroundColor = [UIColor orangeColor];

	[logoButton addTarget:self action:@selector(presentAboutPage:event:) forControlEvents:UIControlEventTouchUpInside];

	self.logoButton = logoButton;
	[[self view] insertSubview:logoButton aboveSubview:[self backgroundView]];
	
	// layout constraints
	UIView* superview = self.view;
	UIView* backgroundView = self.backgroundView;

	[superview addConstraint:[NSLayoutConstraint
		constraintWithItem:checkNumber
		attribute:NSLayoutAttributeLeading
		relatedBy:NSLayoutRelationEqual
		toItem:backgroundView
		attribute:NSLayoutAttributeLeft
		multiplier:1.0
		constant:25.0]];
	[superview addConstraint:[NSLayoutConstraint
		constraintWithItem:checkNumber
		attribute:NSLayoutAttributeBaseline
		relatedBy:NSLayoutRelationEqual
		toItem:backgroundView
		attribute:NSLayoutAttributeBottom
		multiplier:1.0
		constant:-36.0]];
		
	[superview addConstraint:[NSLayoutConstraint
		constraintWithItem:checkNumberLabel
		attribute:NSLayoutAttributeLeading
		relatedBy:NSLayoutRelationEqual
		toItem:checkNumber
		attribute:NSLayoutAttributeLeft
		multiplier:1.0
		constant:0.0]];
	[superview addConstraint:[NSLayoutConstraint
		constraintWithItem:checkNumberLabel
		attribute:NSLayoutAttributeTop
		relatedBy:NSLayoutRelationEqual
		toItem:checkNumber
		attribute:NSLayoutAttributeBottom
		multiplier:1.0
		constant:-2.0]];
		
	[superview addConstraint:[NSLayoutConstraint
		constraintWithItem:checkDate
		attribute:NSLayoutAttributeLeading
		relatedBy:NSLayoutRelationEqual
		toItem:superview
		attribute:NSLayoutAttributeLeft
		multiplier:1.0
		constant:140.0]];
	[superview addConstraint:[NSLayoutConstraint
		constraintWithItem:checkDate
		attribute:NSLayoutAttributeBaseline
		relatedBy:NSLayoutRelationEqual
		toItem:checkNumber
		attribute:NSLayoutAttributeBaseline
		multiplier:1.0
		constant:0.0]];
		
	[superview addConstraint:[NSLayoutConstraint
		constraintWithItem:checkDateLabel
		attribute:NSLayoutAttributeLeading
		relatedBy:NSLayoutRelationEqual
		toItem:checkDate
		attribute:NSLayoutAttributeLeft
		multiplier:1.0
		constant:0.0]];
	[superview addConstraint:[NSLayoutConstraint
		constraintWithItem:checkDateLabel
		attribute:NSLayoutAttributeBaseline
		relatedBy:NSLayoutRelationEqual
		toItem:checkNumberLabel
		attribute:NSLayoutAttributeBaseline
		multiplier:1.0
		constant:0.0]];

	[superview addConstraint:[NSLayoutConstraint
		constraintWithItem:logoButton
		attribute:NSLayoutAttributeRight
		relatedBy:NSLayoutRelationEqual
		toItem:backgroundView
		attribute:NSLayoutAttributeRight
		multiplier:1.0
		constant:-10.0]];
	[superview addConstraint:[NSLayoutConstraint
		constraintWithItem:logoButton
		attribute:NSLayoutAttributeBottom
		relatedBy:NSLayoutRelationEqual
		toItem:backgroundView
		attribute:NSLayoutAttributeBottom
		multiplier:1.0
		constant:-9.0]];

	[self updateCheckNumber];
}

- (void)loadNumbericKeypadViewController {
	TIPNumericKeypadViewController* viewController = [TIPNumericKeypadViewController viewController];

	viewController.delegate = self;
	viewController.keypadType = TIPNumericKeypadTypeDecimal;

	self.checkAmountViewController = viewController;
}

- (void)loadTipAmountViewController {
	TIPTipAmountViewController* viewController = [TIPTipAmountViewController viewController];

	viewController.delegate = self;
	viewController.tipAmount = self.calculator.tipPercentage;

	self.tipAmountViewController = viewController;
}

- (void)loadTaxAmountViewController {
	TIPNumericKeypadViewController* viewController = [TIPNumericKeypadViewController viewController];

	viewController.delegate = self;
	viewController.keypadType = TIPNumericKeypadTypeFractional;

	self.taxAmountViewController = viewController;
}

- (void)loadRoundingOptionsViewController {
	TIPRoundingOptionsViewController* viewController = [TIPRoundingOptionsViewController viewController];

	viewController.delegate = self;
	viewController.selectedRoundingOption = self.calculator.roundingOption;

	self.roundingOptionsViewController = viewController;
}

- (void)loadSplitCheckViewController {
	TIPSplitCheckViewController* viewController = [TIPSplitCheckViewController viewController];

	viewController.delegate = self;
	viewController.selectedValue = self.calculator.split;

	self.splitCheckViewController = viewController;
}

#pragma mark - UICollectionView Cell Configuration

- (void)configureCell:(TIPGuestCheckCell*)cell forItemAtIndexPath:(NSIndexPath*)indexPath {
	// background views
	[self configureCellBackgroundViews:cell forItemAtIndexPath:indexPath];
	
	// check amount
	if([indexPath isEqual:[self checkAmountIndexPath]]) {
		[self configureCheckAmountCell:cell forItemAtIndexPath:indexPath];
	}
	
	// tip amount
	if([indexPath isEqual:[self tipAmountIndexPath]]) {
		[self configureTipAmountCell:cell forItemAtIndexPath:indexPath];
	}
	
	// tax amount
	if([indexPath isEqual:[self taxAmountIndexPath]]) {
		[self configureTaxAmountCell:cell forItemAtIndexPath:indexPath];
	}
	
	// total amount
	if([indexPath isEqual:[self totalAmountIndexPath]]) {
		[self configureTotalAmountCell:cell forItemAtIndexPath:indexPath];
	}
	
	// split check
	if([indexPath isEqual:[self splitCheckIndexPath]]) {
		[self configureSplitCheckCell:cell forItemAtIndexPath:indexPath];
	}
	
	[cell setNeedsLayout];
}

- (void)configureCheckAmountCell:(TIPGuestCheckCell*)cell forItemAtIndexPath:(NSIndexPath*)indexPath {
	cell.titleLabel.text = SUILocalizedString(@"CHECKAMOUNT_LABEL", nil);
	
	NSNumber* value = self.calculator.checkAmount;
	cell.textLabel.text = [[self currencyFormatter] stringFromNumber:value];
	
	cell.shouldUseBoldStyle = NO;

	cell.indicatorType = TIPGuestCheckCellClearIndicatorType;
	[[cell clearIndicator] removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[[cell clearIndicator] addTarget:self action:@selector(checkShouldClear:event:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureTipAmountCell:(TIPGuestCheckCell*)cell forItemAtIndexPath:(NSIndexPath*)indexPath {
	NSNumber* tipPercent = self.calculator.tipPercentage;
	NSString* tipPercentString = [[self percentFormatter] stringFromNumber:tipPercent];
	
	NSString* titleString;

	if(tipPercentString && [tipPercent floatValue] > 0.0) {
		titleString = [NSString stringWithFormat:SUILocalizedString(@"TIPAMOUNT_LABEL", nil), tipPercentString];
	} else {
		titleString = SUILocalizedString(@"TIP_PERCENTAGE_ZERO", nil);
	}

	TIPRoundingOption roundingOption = self.calculator.roundingOption;
	if(roundingOption == TIPRoundingOptionTipUp) { titleString = [titleString stringByAppendingString:@" ↑"]; }
	if(roundingOption == TIPRoundingOptionTipDown) { titleString = [titleString stringByAppendingString:@" ↓"]; }
	
	cell.titleLabel.text = titleString;
	
	NSNumber* value = self.calculator.tipAmount;
	cell.textLabel.text = [[self currencyFormatter] stringFromNumber:value];
	
	cell.shouldUseBoldStyle = NO;
	cell.indicatorType = TIPGuestCheckCellDisclosureIndicatorType;
	[[cell clearIndicator] removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureTaxAmountCell:(TIPGuestCheckCell*)cell forItemAtIndexPath:(NSIndexPath*)indexPath {
	NSIndexPath* selectedIndexPath = [[[self contentView] indexPathsForSelectedItems] lastObject];
	BOOL isSelected = [selectedIndexPath isEqual:indexPath];

	NSString* editingTaxString = self.calculator.taxEditingString;

	NSString* titleString;

	if(isSelected && editingTaxString.length > 0) {
		NSString* string = [NSString stringWithFormat:@"%@%@",
			editingTaxString,
			[[self percentFormatter] positiveSuffix]];
		titleString = [NSString stringWithFormat:SUILocalizedString(@"TAXAMOUNT_LABEL", nil), string];
	} else {
		NSNumber* tax = self.calculator.salesTax;
		NSString* taxString = [[self percentFormatter] stringFromNumber:tax];

		if(taxString && [tax floatValue] > 0.0) {
			titleString = [NSString stringWithFormat:SUILocalizedString(@"TAXAMOUNT_LABEL", nil), taxString];
		} else {
			titleString = SUILocalizedString(@"TAX_ZERO_TITLE", nil);
		}
	}

	cell.titleLabel.text = titleString;
	
	NSNumber* value = self.self.calculator.taxAmount;
	cell.textLabel.text = [[self currencyFormatter] stringFromNumber:value];
	
	cell.shouldUseBoldStyle = NO;
	
	cell.indicatorType = TIPGuestCheckCellClearIndicatorType;
	[[cell clearIndicator] removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[[cell clearIndicator] addTarget:self action:@selector(taxShouldClear:event:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureTotalAmountCell:(TIPGuestCheckCell*)cell forItemAtIndexPath:(NSIndexPath*)indexPath {
	NSString* titleString = SUILocalizedString(@"TOTALAMOUNT_LABEL", nil);

	TIPRoundingOption roundingOption = self.calculator.roundingOption;

	if([[[self calculator] split] integerValue] <= 1) {
		if(roundingOption == TIPRoundingOptionTotalUp) { titleString = [titleString stringByAppendingString:@" ↑"]; }
		if(roundingOption == TIPRoundingOptionTotalDown) { titleString = [titleString stringByAppendingString:@" ↓"]; }
	}

	if(roundingOption == TIPRoundingOptionPalindrome) {
		titleString = [titleString stringByAppendingString:@" ›‹"];
	}
	
	cell.titleLabel.text = titleString;
	
	NSNumber* value = self.calculator.totalAmount;
	cell.textLabel.text = [[self currencyFormatter] stringFromNumber:value];
	
	cell.shouldUseBoldStyle = YES;
	cell.indicatorType = TIPGuestCheckCellDisclosureIndicatorType;
	[[cell clearIndicator] removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureSplitCheckCell:(TIPGuestCheckCell*)cell forItemAtIndexPath:(NSIndexPath*)indexPath {
	NSIndexPath* selectedIndexPath = [[[self contentView] indexPathsForSelectedItems] lastObject];
	BOOL isSelected = [selectedIndexPath isEqual:indexPath];

	NSNumber* split = self.calculator.split;
	BOOL hasValue = [split integerValue] > 0;

	if(isSelected && !hasValue) {
		cell.titleLabel.text = SUILocalizedString(@"TIP_SPLIT_ZERO", nil);
		cell.textLabel.text = @"–––––";
	} else if(!isSelected && !hasValue) {
		cell.titleLabel.text = SUILocalizedString(@"SPLITCHECK_LABEL", nil);
		cell.textLabel.text = nil;
	} else {
		NSString* titleString = [NSString stringWithFormat:
			SUILocalizedString(@"SPLIT_TITLE", nil),
			[[self decimalNumberFormatter] stringFromNumber:split]];
		
		if([[[self calculator] split] integerValue] > 1) {
			TIPRoundingOption roundingOption = self.calculator.roundingOption;
			if(roundingOption == TIPRoundingOptionTotalUp) { titleString = [titleString stringByAppendingString:@" ↑"]; }
			if(roundingOption == TIPRoundingOptionTotalDown) { titleString = [titleString stringByAppendingString:@" ↓"]; }
		}
		
		cell.titleLabel.text = titleString;

		NSNumber* splitAmount = self.calculator.splitAmount;
		cell.textLabel.text = [[self currencyFormatter] stringFromNumber:splitAmount];
	}
	
	cell.shouldUseBoldStyle = NO;
	cell.indicatorType = TIPGuestCheckCellDisclosureIndicatorType;
	[[cell clearIndicator] removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureCellBackgroundViews:(TIPGuestCheckCell*)cell forItemAtIndexPath:(NSIndexPath*)indexPath {
	// background image
	UIImage* backgroundImage = [self cellBackgroundImageForItemAtIndexPath:indexPath controlState:UIControlStateNormal];
	if(cell.backgroundView) {
		[(UIImageView*)[cell backgroundView] setImage:backgroundImage];
	} else {
		UIImageView* backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
		cell.backgroundView = backgroundView;
	}
	
	// selected background image
	UIImage* selectedBackgroundImage = [self cellBackgroundImageForItemAtIndexPath:indexPath controlState:UIControlStateSelected];
	if(cell.selectedBackgroundView) {
		[(UIImageView*)[cell selectedBackgroundView] setImage:selectedBackgroundImage];
	} else {
		UIImageView* selectedBackgroundView = [[UIImageView alloc] initWithImage:selectedBackgroundImage];
		cell.selectedBackgroundView = selectedBackgroundView;
	}
	
	// background clips to bounds
	NSInteger numberOfRows = [[self contentView] numberOfItemsInSection:[indexPath section]];
	
	BOOL isFirstItem = indexPath.item == 0;
	BOOL isLastItem = indexPath.item == numberOfRows - 1;
	
	cell.backgroundView.clipsToBounds = !isFirstItem && !isLastItem;
	
	// content mode
	UIViewContentMode contentMode = UIViewContentModeBottom;

	[(UIImageView*)[cell backgroundView] setContentMode:contentMode];
	[(UIImageView*)[cell selectedBackgroundView] setContentMode:contentMode];
	
	if(isLastItem && !isFirstItem) {
		[(UIImageView*)[cell backgroundView] setContentMode:UIViewContentModeTop];
		[(UIImageView*)[cell selectedBackgroundView] setContentMode:UIViewContentModeCenter];
	}
}

- (UIImage*)cellBackgroundImageForItemAtIndexPath:(NSIndexPath*)indexPath controlState:(UIControlState)controlState {
	NSInteger numberOfRows = [[self contentView] numberOfItemsInSection:[indexPath section]];
	
	BOOL isFirstItem = indexPath.item == 0;
	BOOL isLastItem = indexPath.item == numberOfRows - 1;
	
	NSString* kindString = @"";
	if(isFirstItem && numberOfRows > 1) { kindString = @"-top"; }
	if(!isFirstItem && !isLastItem && numberOfRows > 2) { kindString = @"-middle"; }
	if(isLastItem && numberOfRows > 1) { kindString = @"-bottom"; }
	
	NSString* variantString = @"";
	if(controlState == UIControlStateSelected) { variantString = @"-selected"; }

	NSString* imageName = [NSString stringWithFormat:@"grouptable%@%@", kindString, variantString];
	
	UIImage* image = [UIImage imageNamed:imageName];
	//image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)];

	return image;
}

- (void)reloadAllCellsForVisibleItems {
	NSArray* visibleItems = [[self contentView] indexPathsForVisibleItems];
	
	BOOL animationsEnabled = [UIView areAnimationsEnabled];
	
	[UIView setAnimationsEnabled:NO]; {
	
		for(NSIndexPath* indexPath in visibleItems) {
			TIPGuestCheckCell* cell = (id)[[self contentView] cellForItemAtIndexPath:indexPath];
			[self configureCell:cell forItemAtIndexPath:indexPath];
			
			[cell layoutIfNeeded];
		}
	
	} [UIView setAnimationsEnabled:animationsEnabled];
}

- (void)reloadCellForItemAtIndexPath:(NSIndexPath*)indexPath {
	if(!indexPath) { return; }

	BOOL animationsEnabled = [UIView areAnimationsEnabled];
	
	[UIView setAnimationsEnabled:NO]; {
	
		TIPGuestCheckCell* cell = (id)[[self contentView] cellForItemAtIndexPath:indexPath];
		[self configureCell:cell forItemAtIndexPath:indexPath];
		
		// [cell setNeedsLayout];
		[cell layoutIfNeeded];
	
	} [UIView setAnimationsEnabled:animationsEnabled];
}

#pragma mark -

- (void)presentInputViewControllerForItemAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated {
	UIViewController* viewController;
	
	if([indexPath isEqual:[self checkAmountIndexPath]]) { viewController = self.checkAmountViewController; }
	if([indexPath isEqual:[self taxAmountIndexPath]]) { viewController = self.taxAmountViewController; }
	if([indexPath isEqual:[self tipAmountIndexPath]]) { viewController = self.tipAmountViewController; }
	if([indexPath isEqual:[self totalAmountIndexPath]]) { viewController = self.roundingOptionsViewController; }
	if([indexPath isEqual:[self splitCheckIndexPath]]) { viewController = self.splitCheckViewController; }

	[self presentInputViewController:viewController animated:animated completion:nil];
}

- (void)setContentViewsVisible:(BOOL)visible {
	[self setContentViewsVisible:visible animated:NO completion:nil];
}

- (void)setContentViewsVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
	if(visible == self.contentViewsVisible) { return; }
	
	void (^animations)(void) = ^() {
		[[self view] layoutIfNeeded];
	};
	
	_contentViewsVisible = visible;
	[[self view] setNeedsLayout];
	
	if(animated) {
		[UIView animateWithDuration:[self preferredAnimationDuration] animations:animations completion:completion];
	} else {
		animations();
		if(completion) { completion(YES); }
	}
}

#pragma mark -

- (BOOL)shouldUseLongPhoneLayout {
	return CGRectGetHeight([[UIScreen mainScreen] bounds]) > 480.0;
}

- (void)selectItemAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated {
	if(!indexPath) { return; }

	[[self contentView] selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
	
	[self reloadCellForItemAtIndexPath:indexPath];
	
	[self presentInputViewControllerForItemAtIndexPath:indexPath animated:animated];

	[self updateDoneButtonItem];
}

- (void)selectItemAtIndexPath:(NSIndexPath*)indexPath {
	[self selectItemAtIndexPath:indexPath animated:YES];
}

- (void)next:(id)sender event:(UIEvent*)event {
	NSIndexPath* selectedIndexPath = [[[self contentView] indexPathsForSelectedItems] lastObject];
	NSIndexPath* newSelectedIndexPath;

	if([selectedIndexPath isEqual:[self totalAmountIndexPath]]) {
		newSelectedIndexPath = [self splitCheckIndexPath];
	} else {
		newSelectedIndexPath = [NSIndexPath
			indexPathForItem:[selectedIndexPath item] + 1
			inSection:[selectedIndexPath section]];
	}

	[self selectItemAtIndexPath:newSelectedIndexPath];
	[self reloadCellForItemAtIndexPath:selectedIndexPath];
}

- (void)done:(id)sender event:(UIEvent*)event {
	NSIndexPath* selectedIndexPath = [[[self contentView] indexPathsForSelectedItems] lastObject];

	if([selectedIndexPath isEqual:[self splitCheckIndexPath]]) {
		[self dismissInputViewController:sender event:event];
	} else {
		[self next:sender event:event];
	}
}

- (void)dismissInputViewController:(id)sender event:(UIEvent*)event {
	NSIndexPath* selectedIndexPath = [[[self contentView] indexPathsForSelectedItems] lastObject];

	self.candyEaten = NO;
	[self dismissInputViewControllerAnimated:YES completion:nil];

	[self reloadCellForItemAtIndexPath:selectedIndexPath];

	// workaround to fix the highlighted state when dismissing while tracking/scrolling
	UICollectionViewCell* cell = [[self contentView] cellForItemAtIndexPath:selectedIndexPath];
	cell.highlighted = NO;
}

- (void)targetButtonTouchUpInside:(id)sender event:(UIEvent*)event {
	[self delicious:self event:event];
}

- (void)delicious:(id)sender event:(UIEvent*)event {
	if(self.candyEaten) { return; }

	self.candyEaten = YES;

	CGRect contentRect = self.view.bounds;
	CGRect candyRect = self.candyView.frame;

	CGRect newCandyRect = candyRect;

	newCandyRect.size.width *= 10.0;
	newCandyRect.size.height *= 10.0;

	newCandyRect.origin.x = CGRectGetMidX(contentRect) - CGRectGetWidth(newCandyRect) * 0.5;
	newCandyRect.origin.y = CGRectGetMidY(contentRect) - CGRectGetHeight(newCandyRect) * 0.5;

	id animations = ^() {
		self.candyView.frame = newCandyRect;
		self.candyView.alpha = 0.0;
	};

	id completion = ^(BOOL finished) {
		self.candyView.frame = candyRect;
	};

	[[self deliciousSound] play];
	[UIView animateWithDuration:1.0 animations:animations completion:completion];
}

- (void)checkShouldClear:(id)sender event:(UIEvent*)event {
	[self clear:sender];
}

- (void)taxShouldClear:(id)sender event:(UIEvent*)event {
	[self numericKeypadViewDidClear:[self taxAmountViewController]];
}

- (void)updateContentView {
	[self reloadAllCellsForVisibleItems];
}

- (void)updateDoneButtonItem {
	NSIndexPath* selectedIndexPath = [[[self contentView] indexPathsForSelectedItems] lastObject];

	BOOL shouldDismiss = [selectedIndexPath isEqual:[self splitCheckIndexPath]];

	NSString* title = shouldDismiss ?
		SUILocalizedString(@"DONE_BUTTONITEM", nil) :
		SUILocalizedString(@"NEXT_BUTTONITEM", nil);
	self.doneButtonItem.title = title;
}

#pragma mark -

+ (NSString*)checkNumberDefaultsKey { return @"TIPCheckNumber"; }
+ (NSInteger)maximumCheckNumber { return 999999999; }

- (void)updateCheckNumber {
	NSString* key = [[self class] checkNumberDefaultsKey];
	NSNumber* checkNumber = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	
	if(!checkNumber) {
		checkNumber = [self newCheckNumber];
		[[NSUserDefaults standardUserDefaults] setObject:checkNumber forKey:key];
	}

	NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];

	[formatter setUsesGroupingSeparator:NO];

	[formatter setFormatWidth:9];
	[formatter setPaddingCharacter:@"0"];

	NSString* string = [formatter stringFromNumber:checkNumber];
	NSMutableString* groupedString = [string mutableCopy];
	
	for(NSInteger characterIndex = 3; characterIndex < string.length; ) {
		[groupedString insertString:@"-" atIndex:characterIndex];
		characterIndex += 4;
	}

	self.checkNumber.text = groupedString;
	
	// for app store screenshots
	self.checkNumber.text = @"089-541-001";
}

- (void)advanceCheckNumber {
	NSString* key = [[self class] checkNumberDefaultsKey];
	NSInteger checkNumber = [[NSUserDefaults standardUserDefaults] integerForKey:key];

	++checkNumber;
	
	if(checkNumber > [[self class] maximumCheckNumber]) {
		checkNumber = 1;
	}

	[[NSUserDefaults standardUserDefaults] setInteger:checkNumber forKey:key];

	[self updateCheckNumber];
}

- (NSNumber*)newCheckNumber {
	float lowBound = 101;
	float highBound = [[self class] maximumCheckNumber] * 0.5;
	NSInteger random = (((float)arc4random() / 0x100000000) * (highBound - lowBound) + lowBound);
		
	NSString* checkNumberString = [@(random) stringValue];
	
	if(checkNumberString.length >= 3) {
		checkNumberString = [checkNumberString
			stringByReplacingCharactersInRange:NSMakeRange(checkNumberString.length - 3, 3)
			withString:@"001"];
	}

	NSNumber* checkNumber = @([checkNumberString integerValue]);
	return checkNumber;
}

#pragma mark -

- (void)updateCheckDate {
	self.checkDate.text = [[self dateFormatter] stringFromDate:[NSDate date]];
	
	// for screenshots
	NSDate* date = [NSDate dateWithTimeIntervalSince1970:1355418720];
	self.checkDate.text = [[self dateFormatter] stringFromDate:date];
}

#pragma mark -

- (void)presentAboutPage:(id)sender event:(UIEvent*)event {
	NSURL* URL = [NSURL URLWithString:@"https://itunes.apple.com/us/artist/sophiestication-software/id284935449?mt=8"];
	[[UIApplication sharedApplication] openURL:URL];
}

@end