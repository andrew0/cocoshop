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

#import "CSSprite.h"
#import "CCNode+Additions.h"
#import "CSObjectController.h"
#import "CSModel.h"
#import "NSString+RelativePath.h"
#import "CSNode.h"
#import "DebugLog.h"

@interface CCNode (Internal)

-(void) _setZOrder:(int) z;

@end

@implementation CSSprite

@synthesize sprite=sprite_;
@synthesize filename=filename_;
@dynamic dirty;
@dynamic quad;
@dynamic atlasIndex;
@dynamic textureRect;
@dynamic textureRectRotated;
@dynamic flipX;
@dynamic flipY;
@dynamic opacity;
@dynamic color;
@dynamic usesBatchNode;
@dynamic textureAtlas;
@dynamic batchNode;
@dynamic honorParentTransform;
@dynamic offsetPositionInPixels;
@dynamic blendFunc;

#pragma mark Init / DeInit

+ (id)spriteWithFile:(NSString *)file
{
	return [[[self alloc] initWithFile:file] autorelease];
}

- (id)initWithFile:(NSString *)file
{
	CCSprite *sprite = [CCSprite spriteWithFile:file];
	return [self initWithSprite:sprite];
}

- (id)initWithSprite:(CCSprite *)aSprite
{
	if((self=[super init]))
	{
		self.filename = nil;
		self.anchorPoint = ccp(0.5f, 0.5f);
		
		[self setupFromSprite:aSprite];
	}
	
	return self;
}

- (void)setupFromSprite:(CCSprite *)aSprite
{
	if(aSprite != nil)
	{
		self.sprite = aSprite;	
		aSprite.isRelativeAnchorPoint = NO;
		[self addChild:aSprite z:NSIntegerMin];
		self.contentSize = aSprite.contentSize;
	}
	else
	{
		DebugLog(@"Attempted to setup nil sprite");
	}

}

- (void)dealloc
{
	self.sprite = nil;
	self.filename = nil;
	[super dealloc];
}

#pragma mark Properties

- (void)setOpacity:(GLubyte)anOpacity
{
	if(!isLocked_)
	{
		sprite_.opacity = anOpacity;
	}
}

- (void)setColor:(ccColor3B)col
{
	if(!isLocked_)
	{
		sprite_.color = col;
	}
}

- (void)setFlipX:(BOOL)fx
{
	if(!isLocked_)
	{
		sprite_.flipX = fx;
	}
}

- (void)setFlipY:(BOOL)fy
{
	if(!isLocked_)
	{
		sprite_.flipY = fy;
	}
}

#pragma mark Message Forwarding

// need to implement these to avoid warnings

- (ccColor3B)color
{
	return sprite_.color;
}

- (GLubyte)opacity
{
	return sprite_.opacity;
}

- (CCTexture2D*)texture
{
	return sprite_.texture;
}

- (void)setTexture:(CCTexture2D*)texture
{
	sprite_.texture = texture;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
	NSMethodSignature *sig;
	
	if( [sprite_ respondsToSelector:selector] )
	{
		sig = [sprite_ methodSignatureForSelector:selector];
//		DebugLog(@"Forwarding invocation (selector: %@) from %@ to %@", NSStringFromSelector(selector), self, sprite_);
	}
	else
	{
		sig = [super methodSignatureForSelector:selector];
//		DebugLog(@"Could not forward selector %@ to %@", NSStringFromSelector(selector), sprite_);
	}
	
	return sig;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	if( [sprite_ respondsToSelector:[anInvocation selector]] )
	{
        [anInvocation invokeWithTarget:sprite_];
	}
	else
	{
        [super forwardInvocation:anInvocation];
	}
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	return ([super respondsToSelector:aSelector] || [sprite_ respondsToSelector:aSelector]);
}

#pragma mark -
#pragma mark Archiving

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];
	
	[dict setValue:filename_ forKey:@"filename"];
	[dict setValue:[NSNumber numberWithBool:sprite_.flipX] forKey:@"flipX"];
	[dict setValue:[NSNumber numberWithBool:sprite_.flipY] forKey:@"flipY"];
	[dict setValue:[NSNumber numberWithFloat:sprite_.opacity] forKey:@"opacity"];
	[dict setValue:[NSNumber numberWithFloat:sprite_.color.r] forKey:@"colorR"];
	[dict setValue:[NSNumber numberWithFloat:sprite_.color.g] forKey:@"colorG"];
	[dict setValue:[NSNumber numberWithFloat:sprite_.color.b] forKey:@"colorB"];
	
	return dict;
}

- (void)setupFromDictionaryRepresentation:(NSDictionary *)aDict
{
	[super setupFromDictionaryRepresentation:aDict];
	
	self.filename = [aDict objectForKey:@"filename"];
	
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:self.filename];
	if (!texture)
	{
		//TODO: implement spriteSetupFailed notification listener in CSObjectController & show error message
		[[NSNotificationCenter defaultCenter] postNotificationName:@"spriteSetupFailed" object:aDict];
		DebugLog(@"Sprite setup failed");
		return;
	}
	
	self.sprite = [CCSprite spriteWithTexture:texture];
	sprite_.flipX = [[aDict objectForKey:@"flipX"] boolValue];
	sprite_.flipY = [[aDict objectForKey:@"flipY"] boolValue];
	sprite_.opacity = [[aDict objectForKey:@"opacity"] floatValue];
	sprite_.color = ccc3([[aDict objectForKey:@"colorR"] floatValue],
						 [[aDict objectForKey:@"colorG"] floatValue],
						 [[aDict objectForKey:@"colorB"] floatValue]);
	
	[self setupFromSprite:sprite_];
}

@end