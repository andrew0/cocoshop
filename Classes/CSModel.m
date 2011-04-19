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

- (void)awakeFromNib
{
	[self setSpriteDictionary:[NSMutableDictionary dictionary]];
	[self setSelectedSpriteKey:nil];
}

- (CSSprite *)selectedSprite
{
	return [spriteDictionary_ objectForKey:selectedSpriteKey_];
}

#pragma mark Custom Accessors

- (void)setSelectedSpriteKey:(NSString *)aKey
{
	if(selectedSpriteKey_ != aKey)
	{
		// deselect old sprite
		CSSprite *old = [self selectedSprite];
		if(old)
		{
			[[old border] setVisible:NO];
		}
		
		[selectedSpriteKey_ release];
		selectedSpriteKey_ = [aKey copy];
		
		// select new sprite
		CSSprite *new = [self selectedSprite];
		if(new)
		{
			NSString *name = [new name];
			CGPoint pos = [new position];
			CGPoint anchor = [new anchorPoint];
			float opacity = [new opacity];
			NSInteger relAnchor = ( [new isRelativeAnchorPoint] ) ? NSOnState : NSOffState;
			
			[[new border] setVisible:YES];
			[self setName:name];
			[self setPosX:pos.x];
			[self setPosY:pos.y];
			[self setAnchorX:anchor.x];
			[self setAnchorY:anchor.y];
			[self setOpacity:opacity];
			[self setRelativeAnchor:relAnchor];
		}
	}
}

- (void)setOpacity:(float)anOpacity
{
	opacity_ = floorf(anOpacity);
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
