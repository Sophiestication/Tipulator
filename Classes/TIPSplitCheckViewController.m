//
//  TIPSplitCheckViewController.m
//  Tipulator
//
//  Created by Sophia Teutschler on 17.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "TIPSplitCheckViewController.h"

@interface TIPSplitCheckViewController()<UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic, strong) UIPickerView* pickerView;
@property(nonatomic, strong) NSNumberFormatter* decimalNumberFormatter;

@property(nonatomic, weak) NSTimer* updatePickerSelectionTimer;
@property(nonatomic) NSInteger currentPickerSelection;

@end

@implementation TIPSplitCheckViewController

#pragma mark - Construction & Destruction

+ (id)viewController {
	return [[self alloc] initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.currentPickerSelection = NSNotFound;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	// number formatter
	NSNumberFormatter* decimalNumberFormatter = [[NSNumberFormatter alloc] init];
	[decimalNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	self.decimalNumberFormatter = decimalNumberFormatter;
	
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [[self class] maximumSplitAmount];
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView*)pickerView widthForComponent:(NSInteger)component {
	NSString* pickerWidth = NSLocalizedString(@"PICKER_WIDTH_SPLIT", @"");
	return [pickerWidth doubleValue];
}

- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSNumber* splitAmount = [self splitAmountForRowAtIndex:row];
	NSString* title;

	if(splitAmount) {
		NSString* splitAmountString = [[self decimalNumberFormatter] stringFromNumber:splitAmount];
		title = [NSString stringWithFormat:NSLocalizedString(@"SPLIT_TITLE", nil), splitAmountString];
	} else {
		title = NSLocalizedString(@"SPLIT_ZERO_TITLE", nil);
	}

	return title;
}

- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSNumber* value = [self splitAmountForRowAtIndex:row];

	self.selectedValue = value;

	[[self delegate] splitCheckView:self didSelectValue:value];
}

#pragma mark - Private

+ (NSInteger)maximumSplitAmount { return 50; }

- (NSNumber*)splitAmountForRowAtIndex:(NSInteger)rowIndex {
	if(rowIndex == 0) { return nil; }
	return @(rowIndex + 1);
}

- (NSInteger)rowIndexForSplitAmount:(NSNumber*)splitAmount {
	if(!splitAmount || [splitAmount integerValue] <= 1) { return 0; }
	return [splitAmount integerValue] - 1;
}

- (void)loadPickerView {
	UIPickerView* pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
	pickerView.delegate = self;
	pickerView.dataSource = self;

	pickerView.showsSelectionIndicator = YES;

	NSInteger rowIndex = [self rowIndexForSplitAmount:[self selectedValue]];
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