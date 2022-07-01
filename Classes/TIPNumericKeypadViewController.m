//
//  TIPNumericKeypadViewController.m
//  Tipulator
//
//  Created by Sophia Teutschler on 17.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "TIPNumericKeypadViewController.h"
#import "TIPNumericKeypadView.h"

@interface TIPNumericKeypadViewController()
@end

@implementation TIPNumericKeypadViewController

#pragma mark - Construction & Destruction

+ (id)viewController {
	return [[self alloc] initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.keypadType = TIPNumericKeypadTypeDecimal;
	}

    return self;
}

#pragma mark - TIPNumericKeypadViewController

#pragma mark - UIViewController

- (void)loadView {
	TIPNumericKeypadView* view = [[TIPNumericKeypadView alloc]
		initWithKeypadType:[self keypadType]];

	view.keypadViewController = self;

	self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

@end