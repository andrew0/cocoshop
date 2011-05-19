/*
 * CSDElement.h
 * cocoshop
 *
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCNode (Internal)

- (void) _setZOrder:(NSInteger)z;

@end


// Virtual Base class for all CSDElements
// For less code - this class takes care about properties for all subclasses
@interface CSDElement : NSObject
{
	// CSDElement
	NSString *name_;
	
	// CCNode
	NSInteger tag_;
	CGSize size_;
	CGPoint anchorPoint_;
	BOOL flipX_, flipY_;
	CGPoint position_;
	CGFloat rotation_;
	NSInteger zOrder_;
	BOOL relativeAnchor_;
	CGPoint scale_;
	
	// CCRGBAProtocol
	ccColor4B color_;
	
	// CCSprite
	NSString *imageName_;
}
// CSDElement
@property(readonly) NSString *name;

// CCNode
@property(readonly) NSInteger tag;
@property(readonly) GLubyte opacity;
@property(readonly) CGSize contentSize;
@property(readonly) CGPoint anchorPoint;
@property(readonly) BOOL flipX;
@property(readonly) BOOL flipY;
@property(readonly) CGPoint position;
@property(readonly) CGFloat rotation;
@property(readonly) NSInteger zOrder;
@property(readonly) BOOL relativeAnchor;
@property(readonly) CGPoint scale;

// CCRGBAProtocol
@property(readonly) ccColor4B color;

// CCSprite
@property(readonly) NSString * imageName;

#pragma mark Creation

// Returns YES if CSDElement subclass can be created with given dictionary
+ (BOOL) canInitWithDictionary: (NSDictionary *) dict;

// Creates CSDElement SubClass from given dictionary.
// If there's no CSDElement SubClasses, that can be created with given
// dictionary - returns nil.
+ (id) elementWithDictionary: (NSDictionary *) dict tag: (NSInteger) aTag;

// Virtual Designated init method for all CSDElements, 
// returns nil, implemented in subclasses
- (id) initWithDictionary: (NSDictionary *) dict tag: (NSInteger) aTag;


#pragma mark Element Info

// Returns YES, if node created with element can be created with and added as a
// child to batchNode.
// Otherwise returns NO.
- (BOOL) canCreateNewNodeWithBatchNode: (CCSpriteBatchNode *) batchNode;

#pragma mark Cocos2D Nodes Creation

// Creates newNode, that can be any CCNode, depending on CSDElement subclass
// Virtual method, returns nil in CSDElement, implemented in subclasses
- (id) newNode;
- (id) newNodeWithClass: (Class) nodeClass;
- (id) newNodeWithBatchNode: (CCSpriteBatchNode *) batchNode;

@end

#pragma mark -
#pragma mark CSD Elements

// CSDElement for background layer.
// Creates CCLayerColor.
// Also used in CSDReader for handling node's size.
@interface CSDBackgroundLayer : CSDElement
{}
@end


// CSDSprite is CSDElement that creates CCSprites
// It can create sprites for CCSpriteBatchNode
@interface CSDSprite: CSDElement
{}

#pragma mark Sprites Creation
- (CCSprite *) newSprite;
- (id) newSpriteWithClass: (Class) nodeClass;
- (CCSprite *) newSpriteWithBatchNode: (CCSpriteBatchNode *) batchNode;

#pragma mark Sprites Setup

// setups given sprite, doesn't add it to anything, but sets it's zOrder and tag
// so you can add it later with addChild: aSprite z: [aSprite zOrder] tag: [aSprite tag] without using CSDSprite
- (void) setupSprite: (CCSprite *) aSprite;

// designated setup, will add aSprite to batchNode if canCreateNewNodeWithBatchNode: batchNode
- (void) setupSprite: (CCSprite *) aSprite withBatchNode: (CCSpriteBatchNode *) batchNode;

@end

