//
//  SFShadowView.h
//  Articles
//
//  Created by Sophia Teutschler on 15.05.10.
//  Copyright 2010 Sophia Teutschler. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	SFShadowViewEdgeTop,
	SFShadowViewEdgeRight,
	SFShadowViewEdgeBottom,
	SFShadowViewEdgeLeft
} SFShadowViewEdge;

@interface SFShadowView : UIView {
@private
	CGSize _offset;
	CGFloat _blur;
	UIColor* _shadowColor;
	SFShadowViewEdge _shadowEdge;
}

@property(nonatomic) CGSize offset;
@property(nonatomic) CGFloat blur;
@property(nonatomic, retain) UIColor* shadowColor;
@property(nonatomic) SFShadowViewEdge shadowEdge;

@end