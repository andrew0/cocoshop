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

#import "CSMainLayer.h"
#import "CCNode+Additions.h"
#import "CSSprite.h"
#import "CSObjectController.h"
#import "CSModel.h"
#import "CSMacGLView.h"
#import "NSString+RelativePath.h"
#import "cocoshopAppDelegate.h"

@implementation CSMainLayer

enum 
{
	kTagBackgroundCheckerboard,
};

@synthesize controller=controller_;
@synthesize showBorders = showBorders_;


#pragma mark Init / DeInit
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
		
		// Show Borders if needed (On on first run)
		NSNumber *showBordersState = [[NSUserDefaults standardUserDefaults] valueForKey:@"CSMainLayerShowBorders"];
		if (!showBordersState)
			self.showBorders = YES;
		else 
			self.showBorders = [showBordersState intValue];
		
		prevSize_ = [[CCDirector sharedDirector] winSize];
		
		// Register for Notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedSprite:) name:@"addedSprite" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(updateForScreenReshapeSafely:) 
													 name: NSViewFrameDidChangeNotification 
												   object: [CCDirector sharedDirector].openGLView];
		[[CCDirector sharedDirector].openGLView setPostsFrameChangedNotifications: YES];
		
		// Add background checkerboard
		CCSprite *sprite = [CCSprite spriteWithFile:@"checkerboard.png"];
		ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
		[sprite.texture setTexParameters:&params];
		sprite.position = sprite.anchorPoint = ccp(0,0);
		[self addChild:sprite z:NSIntegerMin tag:kTagBackgroundCheckerboard ];
		
		// Add Colored Background
		CCLayerColor *bgLayer = [[controller_ modelObject] backgroundLayer];
		if (bgLayer)
			[self addChild:bgLayer z:NSIntegerMin];
		
		[self updateForScreenReshapeSafely: nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[self setController:nil];
	[super dealloc];
}

#pragma mark Loading CSD Files
//TODO: move loading logic to CSObjectController

- (void)loadProjectFromDictionarySafely:(NSDictionary *)dict
{
	NSThread *cocosThread = [[CCDirector sharedDirector] runningThread] ;
	
	[self performSelector:@selector(loadProjectFromDictionary:)
				 onThread:cocosThread
			   withObject:dict
			waitUntilDone:([[NSThread currentThread] isEqualTo:cocosThread])];
}

- (void)loadProjectFromDictionary:(NSDictionary *)dict
{
	NSDictionary *bg = [dict objectForKey:@"background"];
	NSDictionary *children = [dict objectForKey:@"children"];
		
	if(bg && children)
	{
		// clear all existing sprites first
		[controller_ deleteAllSprites];
		
		CCLayerColor *bgLayer = [[controller_ modelObject] backgroundLayer];
		
		CGSize workspaceSize = CGSizeMake([[bg objectForKey:@"stageWidth"] floatValue], [[bg objectForKey:@"stageHeight"] floatValue]);
		[(CSMacGLView *)[[CCDirector sharedDirector] openGLView] setWorkspaceSize: workspaceSize];
		[(CSMacGLView *)[[CCDirector sharedDirector] openGLView] updateWindow];
		[[controller_ modelObject] setSelectedSprite: nil];
		
		
		CGPoint bgPos = ccp([[bg objectForKey:@"posX"] floatValue], [[bg objectForKey:@"posY"] floatValue]);
		[bgLayer setPosition:bgPos];
		
		CGPoint bgAnchor = ccp([[bg objectForKey:@"anchorX"] floatValue], [[bg objectForKey:@"anchorY"] floatValue]);
		[bgLayer setAnchorPoint:bgAnchor];
		
		CGFloat bgScaleX = [[bg objectForKey:@"scaleX"] floatValue];
		CGFloat bgScaleY = [[bg objectForKey:@"scaleY"] floatValue];
		[bgLayer setScaleX:bgScaleX];
		[bgLayer setScaleY:bgScaleY];
		
		CGFloat bgOpacity = [[bg objectForKey:@"opacity"] floatValue];
		[bgLayer setOpacity:bgOpacity];
		
		ccColor3B bgColor = ccc3([[bg objectForKey:@"colorR"] floatValue], [[bg objectForKey:@"colorG"] floatValue], [[bg objectForKey:@"colorB"] floatValue]);
		[bgLayer setColor:bgColor];
		
		CGFloat bgRotation = [[bg objectForKey:@"rotation"] floatValue];
		[bgLayer setRotation:bgRotation];
		
		BOOL bgRelativeAnchor = [[bg objectForKey:@"relativeAnchor"] boolValue];
		[bgLayer setIsRelativeAnchorPoint:bgRelativeAnchor];
		
		for(NSDictionary *child in children)
		{
			// change path to relative while loading
			NSMutableDictionary *mutableChild = [NSMutableDictionary dictionaryWithDictionary: child];
			NSString *absolutePath = [[mutableChild objectForKey:@"filename"] absolutePathFromBaseDirPath: [controller_.projectFilename stringByDeletingLastPathComponent]];
			if (absolutePath)
			{
				[mutableChild removeObjectForKey:@"filename"];
				[mutableChild setObject: absolutePath forKey:@"filename"];
			}
			
			// Create & setup Sprite
			CSSprite *sprite = [[CSSprite new] autorelease];			
			[sprite setupFromDictionaryRepresentation: mutableChild ];
			
			@synchronized ([[controller_ modelObject] spriteArray])
			{
				[[[controller_ modelObject] spriteArray] addObject:sprite];
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"addedSprite" object:nil];
		}
	}
}

#pragma mark Children Getters

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


#pragma mark Notifications

// can be called from another thread
- (void) updateForScreenReshapeSafely: (NSNotification *) aNotification
{	
	// call updateForScreenReshape on next visit (CCActions aren't threadsafe in fullscreen)
	shouldUpdateAfterScreenReshape_ = YES;
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
	
	[self setContentSize: s];
	
	// dont calculate difference for X value - only the Y value
	/*CGFloat diffY = s.height - prevSize_.height;
	CCNode *child;
	CCARRAY_FOREACH(children_, child)
	{
		// reposition all CSSprites
		if ( [child isKindOfClass:[CSSprite class]] )
		{
			CGPoint currentPos = [child position];
			currentPos.y += diffY;
			[child setPosition:currentPos];
			
			// if the sprite is selected, fix the positions in the panel
			if ( [[controller_ modelObject] selectedSprite] == child )
			{
				[[controller_ modelObject] setPosY:currentPos.y];
			}
		}
	}*/
	
	prevSize_ = s;
}

- (void)addedSprite:(NSNotification *)aNotification
{
	// queue sprites update on next visit (in Cocos2D Thread)
	didAddSprite_ = YES;
	[[controller_ spriteTableView] reloadData];
}

// adds new sprites as children if needed - should be called on Cocos2D Thread
- (void) updateSpritesFromModel
{
	CSModel *model = [controller_ modelObject];
	NSMutableArray *spriteArray = [model spriteArray];
	
	@synchronized(spriteArray)
	{
		for(CSSprite *sprite in spriteArray)
		{
			if( ![sprite parent] )
			{
				[self addChild:sprite z: [sprite zOrder]];
				[model setSelectedSprite:sprite];
			}
		}
	}
}

#pragma mark CCNode Reimplemented Methods

- (void) onEnter
{
	[super onEnter];
	
	// Update Background Info View at App Start
	[[controller_ modelObject] setSelectedSprite: nil];
	
	NSString *filename = nil;
	if ( (filename = [(cocoshopAppDelegate *)[[NSApplication sharedApplication ] delegate] filenameToOpen]))
	{
		[self runAction:[CCCallBlock actionWithBlock: ^{
			NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: filename];
			controller_.projectFilename = filename;
			[self loadProjectFromDictionarySafely: dict];			
			[(cocoshopAppDelegate *)[[NSApplication sharedApplication ] delegate] setFilenameToOpen: nil];
		}]];
		
	}
}

- (void) visit
{
	if (shouldUpdateAfterScreenReshape_)
		[self updateForScreenReshape];
	shouldUpdateAfterScreenReshape_ = NO;
	
	if (didAddSprite_)
		[self updateSpritesFromModel];
	didAddSprite_ = NO;
	
	[super visit];
}

- (void)draw
{
	[super draw];
	
	CGSize s = contentSize_;

	if (self.showBorders)
	{
		// Get BG Color
		ccColor3B bgColor = [[[controller_ modelObject] backgroundLayer] color];
		GLfloat bgR = ( (float)bgColor.r / 255.0f );
		GLfloat bgB = ( (float)bgColor.g / 255.0f );
		GLfloat bgG = ( (float)bgColor.b / 255.0f );
		GLfloat antiBrightness = 1.0f / sqrtf(bgR*bgR + bgB*bgB + bgG*bgG);
		GLfloat lineWidth = 2.0f;

		// Use Inverted BG Color to Draw the Outline
		glColor4f(antiBrightness * (0.5f - (bgR - 0.5f)),
				  antiBrightness * (0.5f - (bgB - 0.5f)),
				  antiBrightness * (0.5f - (bgG - 0.5f)),
				  1.0f);
		glLineWidth(2.0f);
		
		CGPoint vertices[] = {
			ccp(1, s.height - lineWidth / 2.0f),
			ccp(s.width - lineWidth / 2.0f, s.height - lineWidth / 2.0f),
			ccp(s.width - lineWidth / 2.0f, 1),
			ccp(1, 1)
		};
		
		ccDrawPoly(vertices, 4, YES);
	}
}



#pragma mark Touch Events

- (void)csMagnifyWithEvent:(NSEvent *)event
{
	CSSprite *sprite = [[controller_ modelObject] selectedSprite];
	if (sprite)
	{
		float currentScaleX = [sprite scaleX];
		float currentScaleY = [sprite scaleY];
		float newScaleX = currentScaleX + [event magnification];
		float newScaleY = currentScaleY + [event magnification];
		
		// round to nearest hundredth
		newScaleX = roundf(newScaleX * 100)/100.0f;
		newScaleY = roundf(newScaleY * 100)/100.0f;
				
		[[controller_ modelObject] setScaleX:newScaleX];
		[[controller_ modelObject] setScaleY:newScaleY];
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
			[model setSelectedSprite:sprite];
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
			[model setSelectedSprite:nil];
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
		[model setSelectedSprite:nil];
	}
	
	prevLocation_ = [[CCDirector sharedDirector] convertEventToGL:event];
	
	return YES;
}

#pragma mark Keyboard Events

- (BOOL)ccKeyDown:(NSEvent *)event
{
	NSUInteger modifiers = [event modifierFlags];
	unsigned short keyCode = [event keyCode];
	CSModel *model = [controller_ modelObject];
	
	// delete sprites
	switch(keyCode)
	{
		case 0x33: // delete
		case 0x75: // forward delete
			[controller_ performSelectorOnMainThread:@selector(deleteSprite:) withObject:[[controller_ modelObject] selectedSprite] waitUntilDone:NO];
			return YES;
		default:
			break;
	}
	
	// if option/alt key is pressed....
	if(modifiers & NSAlternateKeyMask)
	{
		// move anchor point
		CGFloat increment = (modifiers & NSShiftKeyMask) ? 0.1f : 0.01f;
		
		switch(keyCode)
		{
			case 0x7B: // left arrow
				[model setAnchorX:[model anchorX]-increment];
				return YES;
			case 0x7C: // right arrow
				[model setAnchorX:[model anchorX]+increment];
				return YES;
			case 0x7D: // down arrow
				[model setAnchorY:[model anchorY]-increment];
				return YES;
			case 0x7E: // up arrow
				[model setAnchorY:[model anchorY]+increment];
				return YES;
			default:
				return NO;
		}		
	}
	else if (modifiers & NSControlKeyMask)
	{
		// rotate sprite
		CGFloat increment = (modifiers & NSShiftKeyMask) ? 10.0f : 1.0f;
		
		switch(keyCode)
		{
			case 0x7B: // left arrow
				[model setRotation:[model rotation]-increment];
				return YES;
			case 0x7C: // right arrow
				[model setRotation:[model rotation]+increment];
				return YES;
			default:
				return NO;
		}
	}
	else
	{
		// move position & change z
		NSInteger increment = (modifiers & NSShiftKeyMask) ? 10 : 1;
		
		switch(keyCode)
		{
			case 0x7B: // left arrow
				[model setPosX:[model posX]-increment];
				return YES;
			case 0x7C: // right arrow
				[model setPosX:[model posX]+increment];
				return YES;
			case 0x7D: // down arrow
				[model setPosY:[model posY]-increment];
				return YES;
			case 0x7E: // up arrow
				[model setPosY:[model posY]+increment];
				return YES;
			case 0x74: // page up
			case 0x1e: // cmd-]
				[model setPosZ:[model posZ]+increment];
				return YES;
			case 0x79: // page down
			case 0x21: // cmd-[
				[model setPosZ:[model posZ]-increment];
				return YES;
			default:
				return NO;
		}
	}
	
	return NO;
}


@end
