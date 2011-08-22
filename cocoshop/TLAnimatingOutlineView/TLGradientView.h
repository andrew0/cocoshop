//
//  TLGradientView.h
//  Created by Jonathan Dann and on 20/10/2008.
//	Copyright (c) 2008, espresso served here.
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, 
//	are permitted provided that the following conditions are met:
//
//	Redistributions of source code must retain the above copyright notice, this list 
//	of conditions and the following disclaimer.
//
//	Redistributions in binary form must reproduce the above copyright notice, this list 
//	of conditions and the following disclaimer in the documentation and/or other materials 
//	provided with the distribution.
//
//	Neither the name of the espresso served here nor the names of its contributors may be
//	used to endorse or promote products derived from this software without specific prior 
//	written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
//	OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
//	AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
//	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
//	IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT 
//	OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains code from "TLAnimatingOutlineView" by Jonathan Dann http://code.google.com/p/tlanimatingoutlineview/" will do.

#import <Cocoa/Cocoa.h>
#import "TLGeometry.h"

enum {
	TLGradientViewActiveGradient = 0,
	TLGradientViewInactiveGradient = 1,
	TLGradientViewClickedGradient = 2
};
typedef NSUInteger TLGradientViewFillOption;

@interface TLGradientView : NSView <NSCoding> {
@private
	NSGradient *_activeFillGradient;
	NSGradient *_inactiveFillGradient;
	NSGradient *_clickedFillGradient;
	TLGradientViewFillOption _fillOption;
	CGFloat _fillAngle;
	BOOL _drawsHighlight;
	NSColor *_highlightColor;
	NSColor *_clickedHighLightColor;
	BOOL _drawsBorder;
	NSColor *_borderColor;
	TLRectEdge _borderSidesMask;
}
@property(nonatomic,readwrite,copy) NSGradient *activeFillGradient;
@property(nonatomic,readwrite,copy) NSGradient *inactiveFillGradient;
@property(nonatomic,readwrite,copy) NSGradient *clickedFillGradient;
@property(nonatomic,readwrite,assign) TLGradientViewFillOption fillOption;
@property(nonatomic,readwrite,assign) CGFloat fillAngle;
@property(nonatomic,readwrite,assign) BOOL drawsHighlight;
@property(nonatomic,readwrite,copy) NSColor *highlightColor;
@property(nonatomic,readwrite,copy) NSColor *clickedHighlightColor;
@property(nonatomic,readwrite,assign) BOOL drawsBorder;
@property(nonatomic,readwrite,copy) NSColor *borderColor;
@property(nonatomic,readwrite,assign) TLRectEdge borderSidesMask;
@end
