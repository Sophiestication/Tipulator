//
//  TIPTaxAmountViewController.m
//  Tipulator
//
//  Created by Sophia Teutschler on 17.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "TIPTaxAmountViewController.h"

@interface TIPTaxAmountViewController()<UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic, strong) UIPickerView* pickerView;

@end

@implementation TIPTaxAmountViewController

#pragma mark - Construction & Destruction

+ (id)viewController {
	return [[self alloc] initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 0;
}

#pragma mark - Private

- (void)loadPickerView {
	UIPickerView* pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
	pickerView.delegate = self;
	pickerView.dataSource = self;
	
	self.pickerView = pickerView;
	[[self view] addSubview:pickerView];
}

@end