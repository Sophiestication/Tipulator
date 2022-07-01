//
//  TIPTipAmountViewController.m
//  Tipulator
//
//  Created by Sophia Teutschler on 17.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "TIPTipAmountViewController.h"

@interface TIPTipAmountViewController()<UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic, strong) UIPickerView* pickerView;

@property(nonatomic, strong) NSNumberFormatter* tipAmountFormatter;
@property(nonatomic, strong) NSDictionary* ratings;

@property(nonatomic, weak) NSTimer* updatePickerSelectionTimer;
@property(nonatomic) NSInteger currentPickerSelection;

@end

@implementation TIPTipAmountViewController

#pragma mark - Construction & Destruction

+ (id)viewController {
	return [[self alloc] initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.currentPickerSelection = NSNotFound;
	}

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// tip amount formatter
	NSNumberFormatter* tipAmountFormatter = [[NSNumberFormatter alloc] init];
	
	[tipAmountFormatter setNumberStyle:NSNumberFormatterPercentStyle];
	
//	[tipAmountFormatter setFormatWidth:20];
//	[tipAmountFormatter setPaddingCharacter:@" "];
	[tipAmountFormatter setPaddingPosition:NSNumberFormatterPadBeforePrefix];
	
	self.tipAmountFormatter = tipAmountFormatter;
	
	// tip ratings
	NSURL* ratingsURL = [[NSBundle mainBundle] URLForResource:@"ratings" withExtension:@"plist"];
	self.ratings = [NSDictionary dictionaryWithContentsOfURL:ratingsURL];
	
	[self loadPickerView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self beginUpdatePickerSelectionIfNeeded];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self endUpdatePickerSelection];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	self.pickerView.frame = self.view.bounds;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [[self class] maximumTipAmount] + 1;
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView*)pickerView widthForComponent:(NSInteger)component {
	NSString* pickerWidth = NSLocalizedString(@"PICKER_WIDTH_PERCENTAGE", @"");
	return [pickerWidth doubleValue];
}

/* - (NSAttributedString*)pickerView:(UIPickerView*)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return nil;
} */

- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSNumber* tipAmount = [self tipAmountForRowAtIndex:row];
	NSString* title = [self stringForTipAmount:tipAmount];
	return title;
}

- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSNumber* tipAmount = [self tipAmountForRowAtIndex:row];

	if(tipAmount) {
		tipAmount = @([tipAmount floatValue] / 100.0); // use fractional numbers for actual calculations
	}

	self.tipAmount = tipAmount;

	[[self delegate] tipAmountViewController:self didSelectValue:tipAmount];
}

#pragma mark - Private

+ (NSInteger)maximumTipAmount { return 50; }

- (NSNumber*)tipAmountForRowAtIndex:(NSInteger)rowIndex {
	NSInteger maximumTipAmount = [[self class] maximumTipAmount];
	if(rowIndex == maximumTipAmount) { return nil; }
	return @(maximumTipAmount - rowIndex);
}

- (NSInteger)rowIndexForTipAmount:(NSNumber*)tipAmount {
	NSInteger maximumTipAmount = [[self class] maximumTipAmount];

	if(!tipAmount) { return maximumTipAmount; }

	NSInteger rowIndex =  maximumTipAmount - [tipAmount integerValue];
	return rowIndex;
}

- (NSString*)stringForTipAmount:(NSNumber*)tipAmount {
	NSString* title;

	if(tipAmount) {
		title = [[self tipAmountFormatter]
			stringFromNumber:@([tipAmount floatValue] / 100.0)];
	
		NSString* ratingString = self.ratings[[tipAmount stringValue]];
		if(ratingString.length > 0) {
			title = [NSString stringWithFormat:@"%@ %@", title, ratingString];
		}
	} else {
		title = NSLocalizedString(@"TIP_PERCENTAGE_ZERO", nil);
	}
	
	NSString* indent = NSLocalizedString(@"PICKER_INDENT_PERCENTAGE", @"");
	title = [indent stringByAppendingString:title];
	
	return title;
}

- (void)loadPickerView {
	UIPickerView* pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
	pickerView.delegate = self;
	pickerView.dataSource = self;
	
	pickerView.showsSelectionIndicator = YES;

	NSNumber* tipPercentage = @([[self tipAmount] floatValue] * 100.0);
	NSInteger rowIndex = [self rowIndexForTipAmount:tipPercentage];
	[pickerView selectRow:rowIndex inComponent:0 animated:NO];
	
	self.pickerView = pickerView;
	[[self view] addSubview:pickerView];
}

#pragma mark -

- (void)beginUpdatePickerSelectionIfNeeded {
	if(self.updatePickerSelectionTimer) { return; }
	
	NSTimer* timer = [NSTimer
		timerWithTimeInterval:0.2
		target:self
		selector:@selector(updatePickerSelection)
		userInfo:nil
		repeats:YES];
	[[NSRunLoop currentRunLoop]
		addTimer:timer
		forMode:NSRunLoopCommonModes];
	self.updatePickerSelectionTimer = timer;
}

- (void)endUpdatePickerSelection {
	[[self updatePickerSelectionTimer] invalidate];
	self.updatePickerSelectionTimer = nil;
}

- (void)updatePickerSelection {
	NSInteger pickerSelection = [[self pickerView] selectedRowInComponent:0];
	if(self.currentPickerSelection == pickerSelection) { return; }
	
	self.currentPickerSelection = pickerSelection;
	[self pickerView:[self pickerView] didSelectRow:pickerSelection inComponent:0];
}

@end