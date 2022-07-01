//
//  NSBundle+Localization.m
//  Groceries
//
//  Created by Sophia Teutschler on 23.10.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "NSBundle+Localization.h"

#import <objc/runtime.h>

@implementation NSBundle(Localization)

void* const SUILocalizedBundleStringsAssocitatedObjectKey;

- (NSString*)localizedStringForKey:(NSString*)key value:(NSString*)value table:(NSString*)tableName locale:(NSLocale*)locale {
	if(!locale /*|| [locale isEqual:[NSLocale currentLocale]]*/) {
		return [self localizedStringForKey:key value:value table:tableName];
	}
	
	if(!tableName) { tableName = @"Localizable"; } // default .strings file
	
	NSCache* cache = objc_getAssociatedObject(self, &SUILocalizedBundleStringsAssocitatedObjectKey);

	NSString* localeIdentifier = [locale localeIdentifier];

	NSString* cacheKey = [NSString stringWithFormat:@"%@-%@", tableName, localeIdentifier];
	NSDictionary* strings = [cache objectForKey:cacheKey];
	
	if(!strings) {
		NSURL* URL = [self URLForResource:tableName withExtension:@"strings" subdirectory:nil localization:localeIdentifier];
		
		if(!URL) {
			localeIdentifier = [locale objectForKey:NSLocaleLanguageCode];
			URL = [self URLForResource:tableName withExtension:@"strings" subdirectory:nil localization:localeIdentifier];
		}
		
		strings = [NSDictionary dictionaryWithContentsOfURL:URL];

		if(!cache) {
			cache = [[NSCache alloc] init];
			objc_setAssociatedObject(self, &SUILocalizedBundleStringsAssocitatedObjectKey, cache, OBJC_ASSOCIATION_RETAIN);
		}

		if(!strings) { strings = (id)[NSNull null]; } // prevents frequent bundle lookups
		[cache setObject:strings forKey:cacheKey];
	}

	if(!strings || [strings isEqual:[NSNull null]]) { // fallback for unsupported locales
		return [self localizedStringForKey:key value:value table:tableName];
	}

	NSString* localizedString = strings[key];
	
	if(!localizedString && value) { return value; }
	if(!localizedString) { return key; }
	
	return localizedString;
}

@end