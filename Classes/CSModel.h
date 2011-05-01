/*
 * cocoshop
 *
 * Copyright (c) 2011 Andrew
 * Copyright (c) 2011 Stepan Generalov
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import <Cocoa/Cocoa.h>

@class CSSprite;
@class CCLayerColor;

@interface CSModel : NSObject
{
	CSSprite *selectedSprite_;
	
	CCLayerColor *backgroundLayer_;
	
	NSMutableArray *spriteArray_;
	
	NSString *name_;
	float posX_;
	float posY_;
	float posZ_;
	float anchorX_;
	float anchorY_;
	float scaleX_;
	float scaleY_;
	NSInteger flipX_;
	NSInteger flipY_;
	float opacity_;
	NSColor *color_;
	NSInteger relativeAnchor_;
	float rotation_;
}

@property(nonatomic, assign) CSSprite *selectedSprite;
@property(nonatomic, retain) CCLayerColor *backgroundLayer;
@property(nonatomic, retain) NSMutableArray *spriteArray;
@property(nonatomic, assign) NSString *name;
@property(nonatomic, assign) float posX;
@property(nonatomic, assign) float posY;
@property(nonatomic, assign) float posZ;
@property(nonatomic, assign) float anchorX;
@property(nonatomic, assign) float anchorY;
@property(nonatomic, assign) float scaleX;
@property(nonatomic, assign) float scaleY;
@property(nonatomic, assign) NSInteger flipX;
@property(nonatomic, assign) NSInteger flipY;
@property(nonatomic, assign) float opacity;
@property(nonatomic, copy) NSColor *color;
@property(nonatomic, assign) NSInteger relativeAnchor;
@property(nonatomic, assign) float rotation;

- (CSSprite *)selectedSprite;

@end
