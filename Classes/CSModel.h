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
	
	// CCNode
	CGFloat posX_;
	CGFloat posY_;
	CGFloat posZ_;
	CGFloat anchorX_;
	CGFloat anchorY_;
	CGFloat scaleX_;
	CGFloat scaleY_;
	CGFloat rotation_;
	CGFloat contentSizeWidth_;
	CGFloat contentSizeHeight_;
	NSInteger relativeAnchor_;
	NSInteger tag_;
	
	// CCSprite
	NSInteger flipX_;
	NSInteger flipY_;
	CGFloat opacity_;
	NSColor *color_;	
	
	// General
	NSString *name_;
	CGFloat stageWidth_;
	CGFloat stageHeight_;
}

@property(nonatomic, assign) CSSprite *selectedSprite;
@property(nonatomic, retain) CCLayerColor *backgroundLayer;
@property(nonatomic, retain) NSMutableArray *spriteArray;

// CCNode Properties
@property(nonatomic, assign) CGFloat posX;
@property(nonatomic, assign) CGFloat posY;
@property(nonatomic, assign) CGFloat posZ;
@property(nonatomic, assign) CGFloat anchorX;
@property(nonatomic, assign) CGFloat anchorY;
@property(nonatomic, assign) CGFloat scaleX;
@property(nonatomic, assign) CGFloat scaleY;
@property(nonatomic, assign) CGFloat rotation;
@property(nonatomic, assign) CGFloat contentSizeWidth;
@property(nonatomic, assign) CGFloat contentSizeHeight;
@property(nonatomic, assign) NSInteger relativeAnchor;
@property(nonatomic, assign) NSInteger tag;

// CCSprite Properties
@property(nonatomic, assign) NSInteger flipX;
@property(nonatomic, assign) NSInteger flipY;
@property(nonatomic, assign) CGFloat opacity;
@property(nonatomic, copy) NSColor *color;

// General Properties
@property(nonatomic, assign) NSString *name;
@property(nonatomic, assign) CGFloat stageWidth;
@property(nonatomic, assign) CGFloat stageHeight;

// Sprites Access
- (CSSprite *)selectedSprite;
- (CSSprite *)spriteWithName: (NSString *) name;

// Multiple Selection Sprite Access, returns nil if no sprite is selected
- (NSArray *)selectedSprites;

@end
