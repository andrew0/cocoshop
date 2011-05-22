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

#import "CSModel.h"
#import "CSSprite.h"

@implementation CSModel

@synthesize selectedSprite=selectedSprite_;
@synthesize backgroundLayer=backgroundLayer_;
@synthesize spriteArray=spriteArray_;
@synthesize name=name_;
@synthesize posX=posX_;
@synthesize posY=posY_;
@synthesize posZ=posZ_;
@synthesize anchorX=anchorX_;
@synthesize anchorY=anchorY_;
@synthesize scaleX=scaleX_;
@synthesize scaleY=scaleY_;
@synthesize flipX=flipX_;
@synthesize flipY=flipY_;
@synthesize opacity=opacity_;
@synthesize color=color_;
@synthesize relativeAnchor=relativeAnchor_;
@synthesize rotation=rotation_;
@synthesize stageWidth = stageWidth_;
@synthesize stageHeight = stageHeight_;

#pragma mark Init / DeInit

- (id)init
{
	if((self=[super init]))
	{
		[self setSpriteArray:[NSMutableArray array]];
		
		CCLayerColor *bgLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 0)];
		[bgLayer setPosition:CGPointZero];
		[bgLayer setAnchorPoint:CGPointZero];
		[self setBackgroundLayer:bgLayer];
	}
	return self;
}

- (void)awakeFromNib
{
}

- (void)dealloc
{
	[self setSpriteArray:nil];
	[self setColor:nil];
	[self setBackgroundLayer:nil];
	[super dealloc];
}

#pragma mark Sprite Access 

- (void)setSelectedSprite:(CSSprite *)aSprite
{
	// make sure that sprites aren't same key or both nil
	if( ![selectedSprite_ isEqualTo:aSprite] )
	{
		// deselect old sprite
		if(selectedSprite_)
		{
			[selectedSprite_ setIsSelected:NO];
		}
		
		selectedSprite_ = aSprite;
		
		// select new sprite
		CSSprite *new = selectedSprite_;
		if(new)
		{
			CGPoint pos = [new position];
			CGPoint anchor = [new anchorPoint];
			NSColor *col = [NSColor colorWithDeviceRed:[new color].r/255.0f green:[new color].g/255.0f blue:[new color].b/255.0f alpha:255];
			
			[new setIsSelected:YES];
			[self setName:[new name]];
			[self setPosX:pos.x];
			[self setPosY:pos.y];
			[self setPosZ: [new zOrder]];
			[self setAnchorX:anchor.x];
			[self setAnchorY:anchor.y];
			[self setFlipX:([new flipX]) ? NSOnState : NSOffState];
			[self setFlipY:([new flipY]) ? NSOnState : NSOffState];
			[self setRotation:[new rotation]];
			[self setScaleX:[new scaleX]];
			[self setScaleY:[new scaleY]];
			[self setOpacity:[new opacity]];
			[self setColor:col];
			[self setRelativeAnchor:([new isRelativeAnchorPoint]) ? NSOnState : NSOffState];
		}
		else
		{
			CGPoint pos = [backgroundLayer_ position];
			CGPoint anchor = [backgroundLayer_ anchorPoint];
			NSColor *col = [NSColor colorWithDeviceRed:[backgroundLayer_ color].r/255.0f green:[backgroundLayer_ color].g/255.0f blue:[backgroundLayer_ color].b/255.0f alpha:255];
			
			// sync with actual bg layer properties
			[self setName:@"Background Layer"];
			[self setPosX:pos.x];
			[self setPosY:pos.y];
			[self setAnchorX:anchor.x];
			[self setAnchorY:anchor.y];
			[self setFlipX:NSOffState];
			[self setFlipY:NSOffState];
			[self setRotation:[backgroundLayer_ rotation]];
			[self setScaleX:[backgroundLayer_ scaleX]];
			[self setScaleY:[backgroundLayer_ scaleY]];
			[self setOpacity:[backgroundLayer_ opacity]];
			[self setColor:col];
			[self setRelativeAnchor:([backgroundLayer_ isRelativeAnchorPoint]) ? NSOnState : NSOffState];
			self.stageWidth = [[CCDirector sharedDirector] winSize].width;
			self.stageHeight = [[CCDirector sharedDirector] winSize].height;
		}
		
		// tell controller we changed the selected sprite
		[[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeSelectedSprite" object:nil];
	}
}

- (CSSprite *)spriteWithName: (NSString *) name
{
	for (CSSprite *sprite in spriteArray_)
	{
		if ([sprite.name isEqualToString: name]) {
			return sprite;
		}
	}
	
	return nil;
}

@end
