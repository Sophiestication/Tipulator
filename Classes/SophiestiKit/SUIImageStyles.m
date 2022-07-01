//
//  SUIImageStyles.m
//  Tipulator
//
//  Created by Sophia Teutschler on 08.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import "SUIImageStyles.h"

#import "UIColor+Interface.h"
#import "UIImage+Styles.h"

NSMutableDictionary* SUIGetImageStyles(void) {
	static dispatch_once_t once;
    static NSMutableDictionary* sharedImageStyles;
	
    dispatch_once(&once, ^{
		sharedImageStyles = [[NSMutableDictionary alloc] initWithCapacity:6];
		
		NSDictionary* style;
		
		// SUIGroupedTableViewHeaderImageStyle
		style = [NSDictionary dictionaryWithObjectsAndKeys:
			[UIColor groupTableViewHeaderTextColor], SUIImageStyleFillColor,
			[UIColor whiteColor], SUIImageStyleShadowColor,
			nil];
		[sharedImageStyles setObject:style forKey:SUIGroupedTableViewHeaderImageStyle];
	
		// SUITableViewCellImageStyle
		style = [NSDictionary dictionaryWithObjectsAndKeys:
			[UIColor colorWithWhite:0.251 alpha:1.000], SUIImageStyleFillColor,
			nil];
		[sharedImageStyles setObject:style forKey:SUITableViewCellImageStyle];

        // SUITableViewCellDarkImageStyle
		style = [NSDictionary dictionaryWithObjectsAndKeys:
			[UIColor darkTextColor], SUIImageStyleFillColor,
			nil];
		[sharedImageStyles setObject:style forKey:SUITableViewCellDarkImageStyle];
	
		// SUITableViewCellSelectedImageStyle
		style = [NSDictionary dictionaryWithObjectsAndKeys:
			[UIColor selectedTableViewCellTextColor], SUIImageStyleFillColor,
			nil];
		[sharedImageStyles setObject:style forKey:SUITableViewCellSelectedImageStyle];
	
		// SUITableViewCellGrayImageStyle
		style = [NSDictionary dictionaryWithObjectsAndKeys:
			[UIColor grayTableViewCellTextColor], SUIImageStyleFillColor,
			nil];
		[sharedImageStyles setObject:style forKey:SUITableViewCellGrayImageStyle];
	
		// SUITableViewCellBlueImageStyle
		style = [NSDictionary dictionaryWithObjectsAndKeys:
			[UIColor blueTableViewCellTextColor], SUIImageStyleFillColor,
			nil];
		[sharedImageStyles setObject:style forKey:SUITableViewCellBlueImageStyle];
	
		// SUIToolbarItemImageStyle
		style = [NSDictionary dictionaryWithObjectsAndKeys:
			[UIColor whiteColor], SUIImageStyleFillColor,
			[[UIColor blackColor] colorWithAlphaComponent:0.5], SUIImageStyleShadowColor,
			[NSValue valueWithCGPoint:CGPointMake(0.0, 1.0)], SUIImageStyleShadowOffset,
			nil];
		[sharedImageStyles setObject:style forKey:SUIToolbarItemImageStyle];
	});

    return sharedImageStyles;
}