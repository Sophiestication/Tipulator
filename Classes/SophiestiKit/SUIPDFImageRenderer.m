//
//  SUIPDFImageRenderer.m
//  Tipulator
//
//  Created by Sophia Teutschler on 06.03.12.
//  Copyright (c) 2012 Sophiestication Software. All rights reserved.
//

#import "SUIPDFImageRenderer.h"

@implementation SUIPDFImageRenderer

@synthesize URL = URL_;

@synthesize size = size_;
@synthesize scale = scale_;

#pragma mark - Construction & Destruction

- (id)initWithContentsOfURL:(NSURL*)URL {
	if((self = [super init])) {
		self.URL = URL;

		self.size = CGSizeZero;
		self.scale = 1;
	}
	
	return self;
}

#pragma mark - SUIPDFImageRenderer

- (UIImage*)renderedImage {
	UIImage* image = nil;

	UIGraphicsBeginImageContextWithOptions([self size], NO, [self scale]); {
		CGContextRef context = UIGraphicsGetCurrentContext();
	
		[self renderInContext:context];

		image = UIGraphicsGetImageFromCurrentImageContext();
	} UIGraphicsEndImageContext();
	
	return image;
}

- (void)renderInContext:(CGContextRef)context {
	// flip our context
	CGContextGetCTM(context);
	CGContextScaleCTM(context, 1, -1);
	CGContextTranslateCTM(context, 0, -self.size.height);
	
	// create a new PDF document
	CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)[self URL]);
	
	NSAssert1(document != NULL, @"Could not open PDF document: %@", [self URL]);
	NSAssert1(CGPDFDocumentGetNumberOfPages(document) >= 1, @"PDF document is empty: %@", [self URL]);
	
	CGPDFPageRef firstPage = CGPDFDocumentGetPage(document, 1);
	
	// get the rectangle of the cropped inside
	CGRect contentRect = CGPDFPageGetBoxRect(firstPage, kCGPDFCropBox);
	
	CGFloat scaleX = self.size.width /CGRectGetWidth(contentRect);
	// scaleX = round(scaleX * 10.0) / 10.0; // round to avoid blurry images
	
	CGFloat scaleY = self.size.height / CGRectGetHeight(contentRect);
	// scaleY = round(scaleY * 10.0) / 10.0; // round to avoid blurry images
	
	CGContextScaleCTM(context, scaleX, scaleY);
	CGContextTranslateCTM(context, -CGRectGetMinX(contentRect), -CGRectGetMinY(contentRect));
 
// 	NSLog(@"From %f,%f and %f,%f to %f,%f",
//		CGRectGetWidth(contentRect), CGRectGetHeight(contentRect),
//		self.size.width, self.size.height,
//		scaleX, scaleY);
 
	// render
	CGContextDrawPDFPage(context, firstPage);
	CGPDFDocumentRelease(document);
}

@end