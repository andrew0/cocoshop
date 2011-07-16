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

/**
 * The selected sprite
 */
@property(nonatomic, assign) CSSprite *selectedSprite;
/**
 * The background layer
 */
@property(nonatomic, retain) CCLayerColor *backgroundLayer;
/**
 * Array of all the sprites
 */
@property(nonatomic, retain) NSMutableArray *spriteArray;


#pragma mark CCNode Properties
/**
 * X position for selection
 */
@property(nonatomic, assign) CGFloat posX;
/**
 * Y position for selection
 */
@property(nonatomic, assign) CGFloat posY;
/**
 * Z order for selection
 */
@property(nonatomic, assign) CGFloat posZ;
/**
 * X anchor for selection
 */
@property(nonatomic, assign) CGFloat anchorX;
/**
 * Y anchor for selection
 */
@property(nonatomic, assign) CGFloat anchorY;
/**
 * X scale for selection
 */
@property(nonatomic, assign) CGFloat scaleX;
/**
 * Y scale for selection
 */
@property(nonatomic, assign) CGFloat scaleY;
/**
 * Rotation for selection
 */
@property(nonatomic, assign) CGFloat rotation;
/**
 * Content size width for selection
 */
@property(nonatomic, assign) CGFloat contentSizeWidth;
/**
 * Content size height for selection
 */
@property(nonatomic, assign) CGFloat contentSizeHeight;
/**
 * If the selection has a relative anchor or not
 */
@property(nonatomic, assign) NSInteger relativeAnchor;
/**
 * Tag of the selection
 */
@property(nonatomic, assign) NSInteger tag;


#pragma mark CCSprite Properties
/**
 * If the X axis should be flipped for the sprite or not
 */
@property(nonatomic, assign) NSInteger flipX;
/**
 * If the Y axis should be flipped for the sprite or not
 */
@property(nonatomic, assign) NSInteger flipY;
/**
 * The opacity for the sprite
 */
@property(nonatomic, assign) CGFloat opacity;
/**
 * The color of the sprite
 */
@property(nonatomic, copy) NSColor *color;

#pragma mark General Properties
/**
 * The name of the selection
 */
@property(nonatomic, assign) NSString *name;
/**
 * The width of the project
 */
@property(nonatomic, assign) CGFloat stageWidth;
/**
 * The height of the project
 */
@property(nonatomic, assign) CGFloat stageHeight;


#pragma mark Sprites Access
/**
 * Returns sprite that is currently selected
 * @returns The selected sprite
 */
- (CSSprite *)selectedSprite;
/**
 * Find sprite from name
 * @param name Name of the sprite
 * @returns The CSSprite with given name
 */
- (CSSprite *)spriteWithName:(NSString *)name;
/**
 * Multiple selection sprite access
 * @returns Array of selected sprites, nil if no sprite is selected
 */
- (NSArray *)selectedSprites;

@end
