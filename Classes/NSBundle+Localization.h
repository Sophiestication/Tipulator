//
//  NSBundle+Localization.h
//  Groceries
//
//  Created by Sophia Teutschler on 23.10.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle(Localization)

- (NSString*)localizedStringForKey:(NSString*)key value:(NSString*)value table:(NSString*)tableName locale:(NSLocale*)locale;

@end

#define SUILocalizedString(key, comment) \
	    [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil locale:[NSLocale autoupdatingCurrentLocale]]