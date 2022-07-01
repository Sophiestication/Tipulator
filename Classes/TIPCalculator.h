//
//  TIPCalculator.h
//  Tipulator
//
//  Created by Sophia Teutschler on 21.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TIPRoundingOption) {
	TIPRoundingOptionExact,
	TIPRoundingOptionTotalUp,
	TIPRoundingOptionTotalDown,
	TIPRoundingOptionTipDown,
	TIPRoundingOptionTipUp,
	TIPRoundingOptionPalindrome
};

@interface TIPCalculator : NSObject

@property(nonatomic, copy) NSNumber* checkAmount;

@property(nonatomic, copy) NSNumber* tipPercentage;

@property(nonatomic, copy) NSNumber* salesTax;
@property(nonatomic, copy) NSString* taxEditingString;

@property(nonatomic) BOOL excludeTaxFromTipCalculation;

@property(nonatomic) TIPRoundingOption roundingOption;

@property(nonatomic, copy) NSNumber* split;

@property(nonatomic, readonly) NSNumber* totalAmount;
@property(nonatomic, readonly) NSNumber* tipAmount;
@property(nonatomic, readonly) NSNumber* taxAmount;
@property(nonatomic, readonly) NSNumber* splitAmount;

@end

@interface TIPCalculator(UIAdditions)

- (void)appendCheckAmountString:(NSString*)string;
- (void)appendTaxString:(NSString*)string;

- (BOOL)hasValidCheckAmount;

@end