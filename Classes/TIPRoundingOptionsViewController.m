//
//  TIPRoundingOptionsViewController.m
//  Tipulator
//
//  Created by Sophia Teutschler on 17.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "TIPRoundingOptionsViewController.h"

@interface TIPRoundingOptionsViewController()<UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic, strong) UIPickerView* pickerView;
@property(nonatomic, strong) NSArray* roundingOptions;

@end

@implementation TIPRoundingOptionsViewController

#pragma mark - Construction & Destruction

+ (id)viewController {
	return [[self alloc] initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.selectedRoundingOption = TIPRoundingOptionExact;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.roundingOptions = @[
		@{ @"title": NSLocalizedString(@"ROUNDINGOPTION_ROUND_TOTAL_UP", ), @"value": @(TIPRoundingOptionTotalUp) },
		@{ @"title": NSLocalizedString(@"ROUNDINGOPTION_ROUND_TIP_UP", ), @"value": @(TIPRoundingOptionTipUp) },
		@{ @"title": NSLocalizedString(@"ROUNDINGOPTION_NONE", ), @"value": @(TIPRoundingOptionExact) },
		@{ @"title": NSLocalizedString(@"ROUNDINGOPTION_PALINDROME", ), @"value": @(TIPRoundingOptionPalindrome) },
		@{ @"title": NSLocalizedString(@"ROUNDINGOPTION_ROUND_TIP_DOWN", ), @"value": @(TIPRoundingOptionTipDown) },
		@{ @"title": NSLocalizedString(@"ROUNDINGOPTION_ROUND_TOTAL_DOWN", ), @"value": @(TIPRoundingOptionTotalDown) } ];

	[self loadPickerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
	return self.roundingOptions.count;
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView*)pickerView widthForComponent:(NSInteger)component {
	NSString* pickerWidth = NSLocalizedString(@"PICKER_WIDTH_ROUNDING", @"");
	return [pickerWidth doubleValue];
}

- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSDictionary* roundingOption = [[self roundingOptions] objectAtIndex:row];
	NSString* title = roundingOption[@"title"];

	NSString* indent = NSLocalizedString(@"PICKER_INDENT_ROUNDING", @"");
	title = [indent stringByAppendingString:title];

	return title;
}

- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSDictionary* roundingOption = [[self roundingOptions] objectAtIndex:row];

	TIPRoundingOption value = [[roundingOption objectForKey:@"value"] integerValue];
	self.selectedRoundingOption = value;

	[[self delegate] roundingOptionsView:self didSelectOption:value];
}

#pragma mark - Private

- (void)loadPickerView {
	UIPickerView* pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];

	pickerView.showsSelectionIndicator = YES;

	pickerView.delegate = self;
	pickerView.dataSource = self;

	NSUInteger selectedRowIndex = [self rowIndexForRoundingOption:[self selectedRoundingOption]];
	[pickerView selectRow:selectedRowIndex inComponent:0 animated:NO];
	
	self.pickerView = pickerView;
	[[self view] addSubview:pickerView];
}

- (NSUInteger)rowIndexForRoundingOption:(TIPRoundingOption)roundingOption {
	for(NSDictionary* dictionary in self.roundingOptions) {
		if(roundingOption == [[dictionary objectForKey:@"value"] integerValue]) {
			return [[self roundingOptions] indexOfObject:dictionary];
		}
	}

	return NSNotFound;
}

@end