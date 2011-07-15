/*
 * cocoshop
 *
 * Copyright (c) 2011 Andrew
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

#import "cocos2d.h"
#import "CSNode.h"

#define kCSSpriteStrokeSize 1

@class CSObjectController;

/*
	CSSprite is a CCSprite subclass, that is used in cocoshop to display sprites
 on the workspace.
	It can be selected - in that state it is highlighted with a rectangle around
 its contents, shows anchorPoint and position.
	Also it supports NSCoding and provides methods to load & save self to/from 
 NSDictionary.
	TODO: Refactor it to the CSNode, for support of other CCNodes in Cocoshop.
 */
@interface CSSprite : CSNode <CCRGBAProtocol, CCTextureProtocol>
{
	CCSprite *sprite_;
	NSString *filename_;
}

/**
 * The actual sprite
 */
@property(nonatomic, retain) CCSprite *sprite;
/**
 * The filename of the sprite
 */
@property(nonatomic, copy) NSString *filename;

// CCSprite properties
@property (nonatomic,readwrite) BOOL dirty;
@property (nonatomic,readonly) ccV3F_C4B_T2F_Quad quad;
@property (nonatomic,readwrite) NSUInteger atlasIndex;
@property (nonatomic,readwrite) CGRect textureRect;
@property (nonatomic,readonly) BOOL textureRectRotated;
@property (nonatomic,readwrite) BOOL flipX;
@property (nonatomic,readwrite) BOOL flipY;
@property (nonatomic,readwrite) GLubyte opacity;
@property (nonatomic,readwrite) ccColor3B color;
@property (nonatomic,readwrite) BOOL usesBatchNode;
@property (nonatomic,readwrite,assign) CCTextureAtlas *textureAtlas;
@property (nonatomic,readwrite,assign) CCSpriteBatchNode *batchNode;
@property (nonatomic,readwrite) ccHonorParentTransform honorParentTransform;
@property (nonatomic,readonly) CGPoint offsetPositionInPixels;
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

/**
 * Allocate and init a CSSprite from a file
 * @param file File to import sprite from
 * @returns Instance of CSSprite with the sprite from the given file
 */
+ (id)spriteWithFile:(NSString *)file;
/**
 * Init CSSprite with sprite
 * @param aSprite CCSprite to setup with
 * @returns Instance of CSSprite from the given sprite
 */
- (id)initWithSprite:(CCSprite *)aSprite;
/**
 * Setup the class from a CCSprite
 * @param aSprite CCSprite to setup with
 */
- (void)setupFromSprite:(CCSprite *)aSprite;

@end
