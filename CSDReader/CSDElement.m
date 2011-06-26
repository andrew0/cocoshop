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

#import "CSDElement.h"

@implementation CSDElement

@synthesize tag = tag_;
@synthesize name = name_;
@synthesize contentSize = size_;
@synthesize color = color_;
@synthesize anchorPoint = anchorPoint_;
@synthesize flipX = flipX_;
@synthesize flipY = flipY_;
@synthesize position = position_;
@synthesize zOrder = zOrder_;
@synthesize relativeAnchor = relativeAnchor_;
@synthesize scale = scale_;
@synthesize imageName = imageName_;
@synthesize rotation = rotation_;
@dynamic opacity;
- (GLubyte) opacity
{
	return color_.a;
}

+ (id) elementWithDictionary: (NSDictionary *) dict tag: (NSInteger) aTag;
{
	if ([self canInitWithDictionary: dict]) 
	{
		return [[[self alloc] initWithDictionary: dict tag: aTag] autorelease ];
	}
	else if ( [CSDBackgroundLayer canInitWithDictionary: dict] )
	{
		return [[[CSDBackgroundLayer alloc] initWithDictionary: dict tag: aTag ] autorelease ];
	}
	else if ( [CSDSprite canInitWithDictionary: dict] )
	{
		return [[[CSDSprite alloc] initWithDictionary: dict tag: aTag ] autorelease ];
	} //TODO: list supported CSDElements here in else-if's
	else
	{
		NSAssert(NO, @"Cannot find supported CSDElement for given dictionary. Need to update CSDReader? ");
		return nil;
	}
}

- (void) dealloc
{
	[name_ release]; name_ = nil;
	[imageName_ release]; imageName_ = nil;
	
	[super dealloc];
}

#pragma mark Methods to Reimplement in SubClasses

+ (BOOL) canInitWithDictionary: (NSDictionary *) dict
{
	return NO;
}

- (id) initWithDictionary: (NSDictionary *) dict tag: (NSInteger) aTag;
{
	NSAssert(NO, @"CSDElement#init Please, don't use CSDElement instances, use it subclasses instead!");
	return nil;
}

- (BOOL) canCreateNewNodeWithBatchNode: (CCSpriteBatchNode *) batchNode
{
	return NO;
};

- (id) newNode
{
	return nil;
}

- (id) newNodeWithClass: (Class) nodeClass
{
	return nil;
}

- (id) newNodeWithBatchNode: (CCSpriteBatchNode *) batchNode
{
	return nil;
}

@end


@implementation CSDBackgroundLayer

+ (BOOL) canInitWithDictionary: (NSDictionary *) dict
{
	if (dict)
	{
		NSNumber *height = [dict objectForKey:@"stageHeight"];
		NSNumber *width = [dict objectForKey:@"stageWidth"];
		
		if ( [height intValue] && [width intValue] )
			return YES;
	}
	
	return NO;
}

- (id) initWithDictionary: (NSDictionary *) dict tag: (NSInteger) aTag;
{
	if ( ([[self class] canInitWithDictionary: dict]) && (self = [super init]) )
	{
		NSNumber *height = [dict objectForKey:@"stageHeight"];
		NSNumber *width = [dict objectForKey:@"stageWidth"];
		
		size_ = CGSizeMake((CGFloat)([width intValue]), (CGFloat)([height intValue]));
		
		color_ = ccc4((GLubyte)[[dict valueForKey: @"colorR" ] intValue],
					  (GLubyte)[[dict valueForKey: @"colorG" ] intValue],
					  (GLubyte)[[dict valueForKey: @"colorB" ] intValue],
					  (GLubyte)[[dict valueForKey: @"opacity" ] intValue] );
		
		tag_ = aTag;
		
		name_ = [[dict objectForKey:@"name"] copy];
	}
	
	return self;
}

- (id) newNode
{
	return [CCLayerColor layerWithColor: color_ width: size_.width height:size_.height];
}

- (id) newNodeWithClass: (Class) nodeClass
{
	return [[(CCLayerColor *)[nodeClass alloc] initWithColor: color_ width: size_.width height:size_.height] autorelease];
}

- (CGSize) contentSize
{
	return size_;
}

@end


@implementation CSDSprite

+ (BOOL) canInitWithDictionary: (NSDictionary *) dict
{
	if (dict)
	{
		NSString *imagename = [dict objectForKey:@"filename"];
		if (imagename)			
			return YES;
	}
	
	CCLOGERROR(NO ,@"CSDSprite#canInitWithDictionary: no filename given!");	
	return NO;	
	
}

- (id) initWithDictionary: (NSDictionary *) dict tag: (NSInteger) aTag
{
	if ( ([[self class] canInitWithDictionary: dict]) && (self = [super init]) )
	{
		// CSDElement
		name_ = [[dict objectForKey:@"name"] copy];
		
		// CCNode
		tag_ = aTag;
		anchorPoint_ = CGPointMake([[dict valueForKey:@"anchorX"] floatValue], [[dict valueForKey:@"anchorY"]floatValue]);
		flipX_ = [[dict valueForKey:@"flipX"] boolValue];
		flipY_ = [[dict valueForKey:@"flipY"] boolValue];
		position_ = CGPointMake([[dict valueForKey:@"posX"] floatValue], [[dict valueForKey:@"posY"]floatValue]);
		zOrder_ = [[dict valueForKey:@"posX"] intValue];
		relativeAnchor_ = [[dict valueForKey:@"relativeAnchor"] boolValue];
		scale_ = CGPointMake([[dict valueForKey:@"scaleX"] floatValue], [[dict valueForKey:@"scaleY"]floatValue]);;
		rotation_ = [[dict valueForKey:@"rotation"] floatValue];
		
		// CCRGBAProtocol
		color_ = ccc4((GLubyte)[[dict valueForKey: @"colorR" ] intValue],
					  (GLubyte)[[dict valueForKey: @"colorG" ] intValue],
					  (GLubyte)[[dict valueForKey: @"colorB" ] intValue],
					  (GLubyte)[[dict valueForKey: @"opacity" ] intValue] );
		
		// CCSprite
		imageName_ = [[[dict valueForKey:@"filename"] lastPathComponent] retain];		
	}
	
	return self;
}

- (BOOL) canCreateNewNodeWithBatchNode: (CCSpriteBatchNode *) batchNode
{
	if (batchNode)
	{
		CCTexture2D *texture = batchNode.textureAtlas.texture;
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName_];
		
		if (frame && frame.texture == texture) {
			return YES;
		}
	}
	
	return NO;
}

- (id) newNode
{
	return [self newSprite];
}

- (id) newNodeWithClass: (Class) nodeClass
{
	return [self newSpriteWithClass: nodeClass];
}

- (id) newNodeWithBatchNode: (CCSpriteBatchNode *) batchNode
{
	return [self newSpriteWithBatchNode: batchNode];
}

- (CCSprite *) newSprite
{
	return [self newSpriteWithClass:[CCSprite class]];
}

- (id) newSpriteWithClass: (Class) nodeClass
{
	CCSprite *sprite = [[[nodeClass alloc] init] autorelease];
	[self setupSprite: sprite];
	return sprite;
}

- (CCSprite *) newSpriteWithBatchNode: (CCSpriteBatchNode *) batchNode
{
	CCSprite *sprite = [[[CCSprite alloc] init] autorelease];
	[self setupSprite: sprite withBatchNode: batchNode];
	return sprite;
}

- (void) setupSprite: (CCSprite *) aSprite
{
	[self setupSprite: aSprite withBatchNode: nil];
}

- (void) setupSprite: (CCSprite *) aSprite withBatchNode: (CCSpriteBatchNode *) batchNode
{
	if ([self canCreateNewNodeWithBatchNode: batchNode] && (![aSprite parent] || [aSprite parent] == batchNode))
	{
		// SpriteBatchNode Mode
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName_];
		[aSprite setDisplayFrame: frame];
		
		if (![aSprite parent])
			[batchNode addChild: aSprite z: zOrder_ tag: tag_ ];
	}
	else 
	{
		CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:imageName_];
		
		if (texture)
		{
			// Independent Sprite Mode from texture File.
			CGRect rect = CGRectZero;
			rect.size = texture.contentSize;
			[aSprite setTexture:texture];
			[aSprite setTextureRect:rect];
			
		}
		else
		{
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: imageName_];
			
			NSAssert(frame, @"CSDSprite#setupSprite:withBatchNode: failed - can not load image (texture nor sprite frame).");
	
			[aSprite setDisplayFrame: frame];
		}
		
		aSprite.tag = tag_;
		[aSprite _setZOrder: zOrder_];
		
		// isRelativeAnchorPoint is valid only when sprite DOES NOT use batch node
		aSprite.isRelativeAnchorPoint = relativeAnchor_;
	}
	
	// common sprite setup
	aSprite.anchorPoint = anchorPoint_;
	aSprite.flipX = flipX_;
	aSprite.flipY = flipY_;
	aSprite.position = position_;
	aSprite.rotation = rotation_;
	aSprite.scaleX = scale_.x;
	aSprite.scaleY = scale_.y;
	aSprite.color = ccc3(color_.r, color_.g, color_.b);
	aSprite.opacity = color_.a;	
}

@end
























