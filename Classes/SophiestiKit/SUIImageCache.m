//
//  SUIImageCache.m
//  Tipulator
//
//  Created by Sophia Teutschler on 04.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import "SUIImageCache.h"

NSCache* SUIGetImageCache(void) {
	static dispatch_once_t once;
    static NSCache* sharedImageCache;
	
    dispatch_once(&once, ^{
		sharedImageCache = [[NSCache alloc] init];
		sharedImageCache.name = @"SUIImageCache";
	});
	
	return sharedImageCache;
}