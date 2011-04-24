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

#import "HelloWorldLayer.h"
#import "CCNode+Additions.h"
#import "CSSprite.h"
#import "CSObjectController.h"
#import "CSModel.h"

@implementation HelloWorldLayer

enum 
{
	kTagBackgroundCheckerboard,
};

@synthesize controller=controller_;

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild:layer];	
	return scene;
}

+ (id)nodeWithController:(CSObjectController *)aController
{
	return [[[self alloc] initWithController:aController] autorelease];
}

- (id)initWithController:(CSObjectController *)aController
{
	if((self=[super init]))
	{
		[self setIsMouseEnabled:YES];
		[self setIsKeyboardEnabled:YES];
		[self setController:aController];
		
		prevSize_ = [[CCDirector sharedDirector] winSize];
		
		// Register for Notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedSprite:) name:@"addedSprite" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(safeUpdateForScreenReshape:) 
													 name: NSViewFrameDidChangeNotification 
												   object: [CCDirector sharedDirector].openGLView];
		[[CCDirector sharedDirector].openGLView setPostsFrameChangedNotifications: YES];
		
		// Add background checkerboard
		CCSprite *sprite = [CCSprite spriteWithFile:@"checkerboard.png"];
		[self addChild:sprite z:NSIntegerMin tag: kTagBackgroundCheckerboard ];
		sprite.position = sprite.anchorPoint = ccp(0,0);
		
		// Add Colored Background
		CCLayerColor *bgLayer = [[controller_ modelObject] backgroundLayer];
		if (bgLayer)
			[self addChild:bgLayer z:NSIntegerMin];
		
		ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
		[sprite.texture setTexParameters:&params];
		
		[self safeUpdateForScreenReshape: nil];
	}
	return self;
}


// can be called from another thread
- (void) safeUpdateForScreenReshape: (NSNotification *) aNotification
{	
	// call updateForScreenReshape on Cocos2D Thread
	[self runAction: [CCCallFunc actionWithTarget: self selector: @selector(updateForScreenReshape) ]];
}

- (void) updateForScreenReshape
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	// update checkerboard size to fit winSize
	CCSprite *bg = (CCSprite *)[self getChildByTag: kTagBackgroundCheckerboard];
	if ([bg isKindOfClass:[CCSprite class]])
		[bg setTextureRect: CGRectMake(0, 0, s.width, s.height)];
	
	// update color layer size to fit winSize
	CCLayerColor *bgLayer = [[controller_ modelObject] backgroundLayer];
	if ( [bgLayer isKindOfClass:[CCLayerColor class]] )
		[bgLayer setContentSize: s];
	
	// dont calculate difference for X value - only the Y value
	float diffY = s.height - prevSize_.height;
	CCNode *child;
	CCARRAY_FOREACH(children_, child)
	{
		// reposition all CSSprites
		if ( [child isKindOfClass:[CSSprite class]] )
		{
			float currentY = [[controller_ modelObject] posY];
			[[controller_ modelObject] setPosY:(currentY + diffY)];
		}
	}
	
	prevSize_ = s;
}

- (CSSprite *)spriteForEvent:(NSEvent *)event
{
	// we check to see if it's less than children_'s count as well
	// because once it gets to zero, the i-- will make it NSUIntegerMax
	for(NSUInteger i=[children_ count]-1; i>=0 && i<[children_ count]; i--)
	{
		CCNode *child = [children_ objectAtIndex:i];
		if([child isKindOfClass:[CSSprite class]] && [child isEventInRect:event])
		{
			return (CSSprite *)child;
		}
	}
	
	return nil;
}

#pragma mark Sprites Added Notification

// adds new sprites as children if needed - should be called on Cocos2D Thread
- (void) updateSpritesFromModel
{
	CSModel *model = [controller_ modelObject];
	NSMutableDictionary *spriteDictionary = [model spriteDictionary];
	
	@synchronized (spriteDictionary)
	{
		for(NSString *key in spriteDictionary)
		{
			// check each sprite's parent. if there is none, add it
			CSSprite *sprite = [spriteDictionary objectForKey:key];
			if(![sprite parent])
			{
				[self addChild:sprite];
				[model setSelectedSpriteKey:key];
			}
		}
	}
}

- (void) visit
{
	if (spriteWasAdded_)
		[self updateSpritesFromModel];
	spriteWasAdded_ = NO;
	
	[super visit];
}

- (void)addedSprite:(NSNotification *)aNotification
{
	// queue sprites update on next visit (in Cocos2D Thread)
	spriteWasAdded_ = YES;
}

#pragma mark Touch Events

- (void)csMagnifyWithEvent:(NSEvent *)event
{
	CSSprite *sprite = [[controller_ modelObject] selectedSprite];
	if (sprite)
	{
		float currentScale = [sprite scale];
		float newScale = currentScale + [event magnification];
		
		// rounding
		newScale = roundf(newScale * 100)/100.0f;
		
		[[controller_ modelObject] setScale:newScale];
	}
}

- (void)csRotateWithEvent:(NSEvent *)event
{
	CSSprite *sprite = [[controller_ modelObject] selectedSprite];
	if (sprite)
	{
		float currentRotation = [sprite rotation];
		float rotationChange = -[event rotation]; // need to negate
		float newRotation = currentRotation + rotationChange;
		
		// make the new rotation 0 - 360
		if (newRotation < 0)
			newRotation += 360;
		else if (newRotation > 360)
			newRotation -= 360;
		
		// rounding
		newRotation = roundf(newRotation);
		
		[[controller_ modelObject] setRotation:newRotation];
	}
}

#pragma mark Mouse Events

- (BOOL)ccMouseDown:(NSEvent *)event
{
	shouldToggleVisibility_ = NO;
	shouldDragSprite_ = NO;
	
	CSModel *model = [controller_ modelObject];
	
	CSSprite *sprite = [self spriteForEvent:event];
	if(sprite)
	{
		// if this isn't the selected sprite, select it
		// otherwise, plan on deselecting it (unless it is moved)
		if([model selectedSprite] != sprite)
		{
			[model setSelectedSpriteKey:[sprite key]];
		}
		else
		{
			shouldToggleVisibility_ = YES;
		}
		
		shouldDragSprite_ = YES;
	}
	
	// if we touch outside of selected sprite, deselect it
	CSSprite *selectedSprite = [model selectedSprite];
	if(selectedSprite)
	{
		if(![selectedSprite isEventInRect:event])
		{
			[model setSelectedSpriteKey:nil];
		}
	}
	
	prevLocation_ = [[CCDirector sharedDirector] convertEventToGL:event];
	
	return YES;
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
	// we're dragging the sprite, so don't deselect it
	shouldToggleVisibility_ = NO;
	
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
	
	CSModel *model = [controller_ modelObject];
	
	// drag the sprite
	if(shouldDragSprite_)
	{
		CSSprite *sprite = [model selectedSprite];
		if(sprite)
		{
			// note that we don't change the position value directly
			// the control will observe the change in posX and do it
			// for us
			CGPoint diff = ccpSub(location, prevLocation_);
			CGPoint currentPos = [sprite position];
			CGPoint newPos = ccpAdd(currentPos, diff);
			[[controller_ modelObject] setPosX:newPos.x];
			[[controller_ modelObject] setPosY:newPos.y];
		}
	}
	
	prevLocation_ = location;
	
	return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
	// are we supposed to toggle the visibility?
	if(shouldToggleVisibility_)
	{
		CSModel *model = [controller_ modelObject];
		[model setSelectedSpriteKey:nil];
	}
	
	prevLocation_ = [[CCDirector sharedDirector] convertEventToGL:event];
	
	return YES;
}

#pragma mark Keyboard Events

- (BOOL)ccKeyDown:(NSEvent *)event
{
	unsigned short keyCode = [event keyCode];
	
	// we delete the sprite if the user hits delete (0x33) or forward delete (0x75)
	if(keyCode == 0x33 || keyCode == 0x75)
	{
		[controller_ deleteSpriteWithKey:[[controller_ modelObject] selectedSpriteKey]];
		return YES;
	}
	
	return NO;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[self setController:nil];
	[super dealloc];
}
@end
