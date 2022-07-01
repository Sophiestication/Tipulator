//
//  UIImage+Styles.m
//  Tipulator
//
//  Created by Sophia Teutschler on 03.01.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import "UIImage+Styles.h"

#import "SUIStyledImageRenderer.h"
#import "SUIImageCache.h"
#import	"SUIImageStyles.h"

#import "UIImage+PDF.h"

NSString* const SUIGroupedTableViewHeaderImageStyle = @"SUIGroupedTableViewHeaderImageStyle";
NSString* const SUITableViewCellImageStyle = @"SUITableViewCellImageStyle";
NSString* const SUITableViewCellDarkImageStyle = @"SUITableViewCellDarkImageStyle";
NSString* const SUITableViewCellSelectedImageStyle = @"SUITableViewCellSelectedImageStyle";
NSString* const SUITableViewCellGrayImageStyle = @"SUITableViewCellGrayImageStyle";
NSString* const SUITableViewCellBlueImageStyle = @"SUITableViewCellBlueImageStyle";

NSString* const SUIToolbarItemImageStyle = @"SUIToolbarItemImageStyle";

NSString* const SUIImageStyleFillColor = @"SUIImageStyleFillColor";

NSString* const SUIImageStyleShadowColor = @"SUIImageStyleShadowColor";
NSString* const SUIImageStyleShadowOffset = @"SUIImageStyleShadowOffset";

NSString* const SUIImageStyleFillStartColor = @"SUIImageStyleFillStartColor";
NSString* const SUIImageStyleFillEndColor = @"SUIImageStyleFillEndColor";

@implementation UIImage(Styles)

+ (UIImage*)imageNamed:(NSString*)imageName style:(NSString*)styleName {
	NSString* cacheKey = [[imageName stringByAppendingString:@"-"] stringByAppendingString:styleName];
	NSCache* cache = SUIGetImageCache();
	
	UIImage* styledImage = [cache objectForKey:cacheKey];
	
	if(!styledImage) {
		NSDictionary* styles = [SUIGetImageStyles() objectForKey:styleName];
		UIImage* image = [UIImage imageNamed:imageName];
		
		if(styles) {
			image = [image imageByApplyingStyles:styles];
			
			if(image) {
				NSUInteger imageCost = image.size.width * image.size.height * image.scale * 4.0; // accurate enough for caching purpose
				[cache setObject:image forKey:cacheKey cost:imageCost];
			}
		}
		
		styledImage = image;
	}
	
	return styledImage;
}

- (UIImage*)imageByApplyingStyles:(NSDictionary*)imageStyles {
	SUIStyledImageRenderer* renderer = [[SUIStyledImageRenderer alloc] init];
	
	renderer.maskImage = self;
	renderer.imageStyles = imageStyles;
	
	return [renderer renderedImage];
}

+ (void)registerImageStyle:(NSDictionary*)imageStyle forKey:(NSString*)styleKey {
	[SUIGetImageStyles() setObject:imageStyle forKey:styleKey];
}

+ (void)unregisterImageStyleForKey:(NSString*)styleKey {
	[SUIGetImageStyles() removeObjectForKey:styleKey];
}

@end