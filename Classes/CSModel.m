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

#import "CSModel.h"
#import "CSSprite.h"

@implementation CSModel

@synthesize spriteDictionary=spriteDictionary_;
@synthesize selectedSpriteKey=selectedSpriteKey_;
@synthesize name=name_;
@synthesize posX=posX_;
@synthesize posY=posY_;
@synthesize posZ=posZ_;
@synthesize anchorX=anchorX_;
@synthesize anchorY=anchorY_;
@synthesize scale=scale_;
@synthesize flipX=flipX_;
@synthesize flipY=flipY_;
@synthesize opacity=opacity_;
@synthesize color=color_;
@synthesize relativeAnchor=relativeAnchor_;
@synthesize rotation=rotation_;

- (id)init
{
	if((self=[super init]))
	{
		[self setSpriteDictionary:[NSMutableDictionary dictionary]];
		[self setSelectedSpriteKey:nil];
	}
	return self;
}

- (void)awakeFromNib
{
}

- (CSSprite *)selectedSprite
{
	CSSprite *sprite = nil;
	
	@synchronized ( spriteDictionary_ )
	{
		sprite = [spriteDictionary_ objectForKey:selectedSpriteKey_];
	}
	
	return sprite;
}

#pragma mark Custom Accessors

- (void)setSelectedSpriteKey:(NSString *)aKey
{
	if( ![selectedSpriteKey_ isEqualToString:aKey] )
	{
		// deselect old sprite
		CSSprite *old = [self selectedSprite];
		if(old)
		{
			[old setIsSelected:NO];
		}
		
		[selectedSpriteKey_ release];
		selectedSpriteKey_ = [aKey copy];
		
		// select new sprite
		CSSprite *new = [self selectedSprite];
		if(new)
		{
			CGPoint pos = [new position];
			CGPoint anchor = [new anchorPoint];
			NSColor *col = [NSColor colorWithDeviceRed:[new color].r/255.0f green:[new color].g/255.0f blue:[new color].b/255.0f alpha:255];
			
			[new setIsSelected:YES];
			[self setName:[new name]];
			[self setPosX:pos.x];
			[self setPosY:pos.y];
			[self setAnchorX:anchor.x];
			[self setAnchorY:anchor.y];
			[self setFlipX:([new flipX]) ? NSOnState : NSOffState];
			[self setFlipY:([new flipY]) ? NSOnState : NSOffState];
			[self setScale:[new scale]];
			[self setOpacity:[new opacity]];
			[self setColor:col];
			[self setRelativeAnchor:([new isRelativeAnchorPoint]) ? NSOnState : NSOffState];
		}
		else
		{
			// TODO: sync with actual bg layer properties
			[self setName:@"Background Layer"];
			[self setPosX:0];
			[self setPosY:0];
			[self setAnchorX:0];
			[self setAnchorY:0];
			[self setFlipX:NSOffState];
			[self setFlipY:NSOffState];
			[self setScale:0];
			[self setOpacity:0];
			[self setRelativeAnchor:NSOffState];
		}

		
		// tell controller we changed the selected sprite
		[[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeSelectedSprite" object:nil];
	}
}

- (void)dealloc
{
	[self setSpriteDictionary:nil];
	[self setSelectedSpriteKey:nil];
	[self setSelectedSpriteKey:nil];
	[self setColor:nil];
	[super dealloc];
}

@end
