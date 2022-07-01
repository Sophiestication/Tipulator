//
//  TIPCalculator.m
//  Tipulator
//
//  Created by Sophia Teutschler on 21.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "TIPCalculator.h"

@interface TIPCalculator()

@property(nonatomic, copy) NSDecimalNumber* evaluatedCheckAmountExcludingTax;
@property(nonatomic, copy) NSDecimalNumber* evaluatedTotalAmount;
@property(nonatomic, copy) NSDecimalNumber* evaluatedTipAmount;
@property(nonatomic, copy) NSDecimalNumber* evaluatedTaxAmount;
@property(nonatomic, copy) NSDecimalNumber* evaluatedSplitAmount;

@property(nonatomic, strong) id<NSDecimalNumberBehaviors> roundCurrencyUpNumberBehavior;
@property(nonatomic, strong) id<NSDecimalNumberBehaviors> roundUpNumberBehavior;
@property(nonatomic, strong) id<NSDecimalNumberBehaviors> roundDownNumberBehavior;
@property(nonatomic, strong) id<NSDecimalNumberBehaviors> roundExactNumberBehavior;

@property(nonatomic) BOOL needsEvaluation;

@end

@implementation TIPCalculator

#pragma mark - Construction & Destruction

- (id)init {
	if((self = [super init])) {
		self.excludeTaxFromTipCalculation = YES;

		self.checkAmount = [NSDecimalNumber zero];

		self.roundCurrencyUpNumberBehavior = [NSDecimalNumberHandler
			decimalNumberHandlerWithRoundingMode:NSRoundUp
			scale:2
			raiseOnExactness:NO
			raiseOnOverflow:NO
			raiseOnUnderflow:NO
			raiseOnDivideByZero:NO];
		self.roundUpNumberBehavior = [NSDecimalNumberHandler
			decimalNumberHandlerWithRoundingMode:NSRoundUp
			scale:0
			raiseOnExactness:NO
			raiseOnOverflow:NO
			raiseOnUnderflow:NO
			raiseOnDivideByZero:NO];
		self.roundDownNumberBehavior = [NSDecimalNumberHandler
			decimalNumberHandlerWithRoundingMode:NSRoundDown
			scale:0
			raiseOnExactness:NO
			raiseOnOverflow:NO
			raiseOnUnderflow:NO
			raiseOnDivideByZero:NO];
		self.roundExactNumberBehavior = [NSDecimalNumberHandler
			decimalNumberHandlerWithRoundingMode:NSRoundBankers
			scale:2
			raiseOnExactness:NO
			raiseOnOverflow:NO
			raiseOnUnderflow:NO
			raiseOnDivideByZero:NO];
	}
	
	return self;
}

#pragma mark - TIPCalculator

- (void)setCheckAmount:(NSNumber*)checkAmount {
	if([checkAmount isEqual:[self checkAmount]]) { return; }
	
	_checkAmount = [checkAmount copy];
	if(!self.checkAmount) { _checkAmount = [NSDecimalNumber zero]; }
	
	self.needsEvaluation = YES;
}

- (void)setTipPercentage:(NSNumber*)tipPercentage {
	if([tipPercentage isEqual:[self tipPercentage]]) { return; }
	
	_tipPercentage = [tipPercentage copy];
	self.needsEvaluation = YES;
}

- (void)setSalesTax:(NSNumber*)salesTax {
	if([salesTax isEqual:[self salesTax]]) { return; }
	
	_salesTax = [salesTax copy];

	self.taxEditingString = [NSNumberFormatter
		localizedStringFromNumber:@([salesTax floatValue] * 100.0)
		numberStyle:NSNumberFormatterDecimalStyle];

	self.needsEvaluation = YES;
}

- (void)setExcludeTaxFromTipCalculation:(BOOL)excludeTaxFromTipCalculation {
	if(self.excludeTaxFromTipCalculation == excludeTaxFromTipCalculation) { return; }

	_excludeTaxFromTipCalculation = excludeTaxFromTipCalculation;
	self.needsEvaluation = YES;
}

- (void)setRoundingOption:(TIPRoundingOption)roundingOption {
	if(self.roundingOption == roundingOption) { return; }
	
	_roundingOption = roundingOption;
	self.needsEvaluation = YES;
}

- (void)setSplit:(NSNumber*)split {
	if([split isEqual:[self split]]) { return; }
	
	_split = [split copy];
	self.needsEvaluation = YES;
}

- (NSNumber*)totalAmount {
	[self evaluateIfNeeded];
	return self.evaluatedTotalAmount;
}

- (NSNumber*)tipAmount {
	[self evaluateIfNeeded];
	return self.evaluatedTipAmount;
}

- (NSNumber*)taxAmount {
	[self evaluateIfNeeded];
	return self.evaluatedTaxAmount;
}

- (NSNumber*)splitAmount {
	[self evaluateIfNeeded];
	return self.evaluatedSplitAmount;
}

#pragma mark - Private

- (void)evaluateIfNeeded {
	if(!self.needsEvaluation) { return; }

	self.needsEvaluation = NO;

	[self evaluateTaxAmount];
	[self evaluateTipAmount];
	[self evaluateTotalAmount];
	[self evaluateSplitAmount];
	[self evaluateForRoundingOptions];
}

- (void)evaluateTaxAmount {
	NSDecimalNumber* tax = [self decimalNumberForNumber:[self salesTax]];
	BOOL hasTax = tax != nil && [tax compare:@(0)] >= NSOrderedSame;

	NSDecimalNumber* checkAmount = [self decimalNumberForNumber:[self checkAmount]];

	if(hasTax) {
		NSDecimalNumber* taxAmount = [checkAmount
			decimalNumberByMultiplyingBy:tax
			withBehavior:[self roundExactNumberBehavior]];

		if([taxAmount isEqual:[NSDecimalNumber notANumber]]) {
			taxAmount = [NSDecimalNumber zero];
		}

		self.evaluatedTaxAmount = taxAmount;

		NSDecimalNumber* checkAmountExcludingTax = [checkAmount
			decimalNumberBySubtracting:taxAmount
			withBehavior:[self roundExactNumberBehavior]];
		self.evaluatedCheckAmountExcludingTax = checkAmountExcludingTax;
	} else {
		self.evaluatedTaxAmount = [NSDecimalNumber zero];
		self.evaluatedCheckAmountExcludingTax = checkAmount;
	}
}

- (void)evaluateTipAmount {
	NSDecimalNumber* tipPercentage = [self decimalNumberForNumber:[self tipPercentage]];

	// no tip
	if(!tipPercentage || [tipPercentage isEqual:[NSDecimalNumber zero]]) {
		self.evaluatedTipAmount = [NSDecimalNumber zero];
		return;
	}

	// calculate tip amount with the appropiate rounding mode
	TIPRoundingOption roundingOptions = self.roundingOption;
	BOOL shouldSplit = self.split != nil && [[self split] compare:@(1)] == NSOrderedDescending;

	if(shouldSplit && (roundingOptions == TIPRoundingOptionTotalUp || roundingOptions == TIPRoundingOptionTotalDown)) {
		roundingOptions = TIPRoundingOptionExact;
	}

	id<NSDecimalNumberBehaviors> behavior = self.roundExactNumberBehavior;
	if(roundingOptions == TIPRoundingOptionTipUp) { behavior = self.roundUpNumberBehavior; }
	if(roundingOptions == TIPRoundingOptionTipDown) { behavior = self.roundDownNumberBehavior; }

	NSDecimalNumber* checkAmount = [self decimalNumberForNumber:[self checkAmount]]; //self.evaluatedCheckAmountExcludingTax;

	// include tax in the tip calculation
	if(!self.excludeTaxFromTipCalculation) {
		checkAmount = [checkAmount decimalNumberByAdding:[self evaluatedTaxAmount]];
	}

	NSDecimalNumber* tipAmount = [checkAmount
		decimalNumberByMultiplyingBy:tipPercentage
		withBehavior:behavior];
	self.evaluatedTipAmount = tipAmount;
}

- (void)evaluateTotalAmount {
	BOOL shouldSplit = self.split != nil && [[self split] compare:@(1)] == NSOrderedDescending;

	TIPRoundingOption roundingOption = self.roundingOption;
	if(shouldSplit) { roundingOption = TIPRoundingOptionExact; }

	self.evaluatedTotalAmount = [self evaluatedTotalAmountForRoundingOption:roundingOption];
	
	if(self.roundingOption == TIPRoundingOptionPalindrome) {
		self.evaluatedTotalAmount = [self palindromize:[self evaluatedTotalAmount]];
	}
}

- (NSDecimalNumber*)evaluatedTotalAmountForRoundingOption:(TIPRoundingOption)roundingOption {
	NSDecimalNumber* checkAmount = [self decimalNumberForNumber:[self checkAmount]];

	// add tip amount
	NSDecimalNumber* tipAmount = self.evaluatedTipAmount;

	NSDecimalNumber* totalAmount = [checkAmount
		decimalNumberByAdding:tipAmount
		withBehavior:[self roundExactNumberBehavior]];

	if([totalAmount isEqual:[NSDecimalNumber notANumber]]) {
		totalAmount = [NSDecimalNumber zero];
	}
	
	id<NSDecimalNumberBehaviors> behavior = self.roundExactNumberBehavior;
	if(roundingOption == TIPRoundingOptionTotalUp) { behavior = self.roundUpNumberBehavior; }
	if(roundingOption == TIPRoundingOptionTotalDown) { behavior = self.roundDownNumberBehavior; }

	// include tax
	NSDecimalNumber* taxAmount = self.evaluatedTaxAmount;

	totalAmount = [totalAmount
		decimalNumberByAdding:taxAmount
		withBehavior:behavior];

	if([totalAmount isEqual:[NSDecimalNumber notANumber]]) {
		totalAmount = [NSDecimalNumber zero];
	}

	return totalAmount;
}

- (void)evaluateSplitAmount {
	NSDecimalNumber* split = [self decimalNumberForNumber:[self split]];

	BOOL shouldSplit = self.split != nil && [split compare:@(1)] == NSOrderedDescending;

	id<NSDecimalNumberBehaviors> behavior = self.roundCurrencyUpNumberBehavior;

	if(shouldSplit) {
		TIPRoundingOption roundingOptions = self.roundingOption;

		if(roundingOptions == TIPRoundingOptionTotalUp) { behavior = self.roundUpNumberBehavior; }
		if(roundingOptions == TIPRoundingOptionTotalDown) { behavior = self.roundDownNumberBehavior; }
		// if(roundingOptions == TIPRoundingOptionTipUp) { behavior = self.roundCurrencyUpNumberBehavior; }
		// if(roundingOptions == TIPRoundingOptionTipDown) { behavior = self.roundCurrencyUpNumberBehavior; }
	}

	NSDecimalNumber* totalAmount = self.evaluatedTotalAmount;

	NSDecimalNumber* splitAmount = [totalAmount
		decimalNumberByDividingBy:split
		withBehavior:behavior];

	if([splitAmount isEqual:[NSDecimalNumber notANumber]]) {
		splitAmount = [NSDecimalNumber zero];
	}

	self.evaluatedSplitAmount = splitAmount;
}

- (void)evaluateForRoundingOptions {
	TIPRoundingOption roundingOptions = self.roundingOption;

	NSDecimalNumber* split = [self decimalNumberForNumber:[self split]];
	BOOL shouldSplit = self.split != nil && [split compare:@(1)] == NSOrderedDescending;

	BOOL shouldRoundTotal =
		roundingOptions == TIPRoundingOptionTotalUp ||
		roundingOptions == TIPRoundingOptionTotalDown;

	BOOL shouldPalindrome = roundingOptions == TIPRoundingOptionPalindrome;

	if(shouldSplit && shouldRoundTotal) {
		self.evaluatedTotalAmount = [[self evaluatedSplitAmount]
			decimalNumberByMultiplyingBy:split
			withBehavior:[self roundExactNumberBehavior]];
	}

	if(shouldRoundTotal || shouldPalindrome) {
		// adjust the tip amount if we round the total
		NSDecimalNumber* totalAmount = self.evaluatedTotalAmount;
		NSDecimalNumber* exactTotalAmount = [self evaluatedTotalAmountForRoundingOption:TIPRoundingOptionExact];
		
		NSDecimalNumber* totalDelta = [totalAmount
			decimalNumberBySubtracting:exactTotalAmount
			withBehavior:[self roundExactNumberBehavior]];
			
		self.evaluatedTipAmount = [[self evaluatedTipAmount]
			decimalNumberByAdding:totalDelta
			withBehavior:[self roundExactNumberBehavior]];
	}
}

- (NSDecimalNumber*)decimalNumberForNumber:(NSNumber*)number {
	if([number isKindOfClass:[NSDecimalNumber class]]) { return (id)number; }
	return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
}

#pragma mark -

- (NSDecimalNumber*)palindromize:(NSDecimalNumber*)value {
	NSString* stringValue = [value stringValue];
	
	NSString* decimalSeparator = @".";
	NSRange decimalSeparatorRange = [stringValue rangeOfString:decimalSeparator options:NSBackwardsSearch];
	
	if(decimalSeparatorRange.location != NSNotFound) {
		stringValue = [stringValue substringToIndex:decimalSeparatorRange.location];
	}
	
	NSString* reversedString = [self stringByReversingString:stringValue];
	
	if(reversedString.length > 2) {
		reversedString = [reversedString substringToIndex:2];
	}
	
	NSNumberFormatter* decimalFormatter = [[NSNumberFormatter alloc] init];
	[decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[decimalFormatter setGeneratesDecimalNumbers:YES];
	
	NSString* palindromizeString = [NSString stringWithFormat:@"%@%@%@",
		stringValue,
		[decimalFormatter decimalSeparator],
		reversedString];
	
	NSDecimalNumber* palindromizedNumber = (NSDecimalNumber*)[decimalFormatter numberFromString:palindromizeString];
	
	return palindromizedNumber;
}

- (NSString*)stringByReversingString:(NSString*)string {
	NSInteger length = string.length;
	NSMutableString* reversedString = [NSMutableString stringWithCapacity:length];

	for(NSInteger characterIndex = (length - 1); characterIndex >= 0; --characterIndex) {
		NSString* c = [string substringWithRange:NSMakeRange(characterIndex, 1)];
		[reversedString appendString:c];
	}
	
	return reversedString;
}

@end

#pragma mark - UIAdditions

@implementation TIPCalculator(UIAdditions)

+ (NSInteger)maximumNumberOfCheckAmountDigits { return 7; }

- (void)appendCheckAmountString:(NSString*)string {
	NSDecimalNumber* checkAmount = [self decimalNumberForNumber:[self checkAmount]];

	NSDecimalNumber* centsFraction = (id)[NSDecimalNumber numberWithInteger:100];
	NSDecimalNumber* checkAmountInCents = [checkAmount decimalNumberByMultiplyingBy:centsFraction];

	NSString* amountString = [checkAmountInCents stringValue];
	amountString = [amountString stringByAppendingString:string];
	
	if(amountString.length > [[self class] maximumNumberOfCheckAmountDigits]) {
		return; // limit exceeded
	}
	
	checkAmount = [NSDecimalNumber decimalNumberWithString:amountString];
	checkAmount = [checkAmount decimalNumberByDividingBy:centsFraction];
	
	self.checkAmount = checkAmount;
}

- (void)appendTaxString:(NSString*)string {
	// check for possible decimal separator strings first
	unichar character = string.length > 0 ?
		[string characterAtIndex:0] : 0;
	BOOL stringIsSeparator = ![[NSCharacterSet decimalDigitCharacterSet]
		characterIsMember:character];

	// if(stringIsSeparator) { string = [[NSLocale systemLocale] objectForKey:NSLocaleDecimalSeparator]; }

	// skip if we already have a decimal separator
	NSString* taxEditingString = self.taxEditingString;
	if(taxEditingString.length == 0) { taxEditingString = @""; }

	if(stringIsSeparator) {
		if([taxEditingString rangeOfString:string].location != NSNotFound) {
			return;
		}
	}

	taxEditingString = [taxEditingString stringByAppendingString:string];

	// prepend a leading zero if needed
	if(stringIsSeparator && taxEditingString.length == 1) {
		taxEditingString = [@"0" stringByAppendingString:taxEditingString];
	}

	// limit the number of fractional digits to 3
	NSRange separatorRange = [taxEditingString rangeOfCharacterFromSet:
		[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];

	if(separatorRange.location != NSNotFound && (taxEditingString.length - separatorRange.location) > 4) {
		return;
	}

	// limit the nmber of digits to 2
	if(separatorRange.location == NSNotFound && taxEditingString.length > 2) {
		return;
	}

	// remove leading zeros
	if(separatorRange.location == NSNotFound) {
		taxEditingString = [[NSDecimalNumber decimalNumberWithString:taxEditingString] stringValue];
	}

	// parse the actual tax decimal number
	NSDecimalNumber* fractions = (id)[NSDecimalNumber numberWithInteger:100];

	NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setPartialStringValidationEnabled:YES];
	[numberFormatter setGeneratesDecimalNumbers:YES];

	NSDecimalNumber* tax = (id)[numberFormatter numberFromString:taxEditingString];
	tax = [tax decimalNumberByDividingBy:fractions];

	self.salesTax = tax;
	self.taxEditingString = taxEditingString;
}

- (BOOL)hasValidCheckAmount {
	if(!self.checkAmount) { return NO; }

	NSDecimalNumber* checkAmount = [self decimalNumberForNumber:[self checkAmount]];
	return ![checkAmount isEqual:[NSDecimalNumber zero]];
}

@end