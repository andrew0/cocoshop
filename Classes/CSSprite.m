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

@implementation CSSprite

@synthesize isSelected=isSelected_;
@synthesize key=key_;
@synthesize filename=filename_;
@synthesize name=name_;
@synthesize locked=locked_;

- (id)init
{
	if((self=[super init]))
	{
		[self setKey:nil];
		[self setFilename:nil];
		[self setName:nil];
		locked_ = NO;
		
		fill_ = [[CCLayerColor layerWithColor:ccc4(30,144,255,25.5f)] retain];
		[self addChild:fill_];
		
		anchor_ = [[CCSprite spriteWithFile:@"anchor.png"] retain];
		[anchor_ setOpacity:200];
		[self addChild:anchor_];
		
		NSString *posText = [NSString stringWithFormat:@"%f, %f", [self position].x, [self position].y];
		positionLabel_ = [[CCLabelBMFont labelWithString:posText fntFile:@"arial.fnt"] retain];
		[anchor_ addChild:positionLabel_];
	}
	
	return self;
}

- (void)onEnter
{
	[super onEnter];
	
	CGSize size = contentSize_;
	[fill_ changeWidth:size.width height:size.height];
	[anchor_ setPosition:ccp(size.width*anchorPoint_.x, size.height*anchorPoint_.y)];
	
	CGSize s = [anchor_ contentSize];
	[positionLabel_ setPosition:ccp(s.width/2, -10)];	
}

- (void)setName:(NSString *)aName
{
	if(name_ != aName)
	{
		// make the key alphanumerical + underscore
		NSCharacterSet *charactersToKeep = [NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"];
		aName = [[aName componentsSeparatedByCharactersInSet:[charactersToKeep invertedSet]] componentsJoinedByString:@"_"];		
		
		[name_ release];
		name_ = [aName copy];
	}
}

- (void)setAnchorPoint:(CGPoint)anchor
{
	if(!locked_)
	{
		[super setAnchorPoint:anchor];
		
		// update position of anchor point
		CGSize size = contentSize_;
		
		if( ![self isRelativeAnchorPoint] )
			[anchor_ setPosition:CGPointZero];
		else
			[anchor_ setPosition:ccp(size.width*anchorPoint_.x, size.height*anchorPoint_.y)];
	}
}

- (void)setPosition:(CGPoint)pos
{
	if(!locked_)
	{
		[super setPosition:pos];
		[self updatePositionLabelSafely];
	}
}

- (void)setRotation:(float)rot
{
	if(!locked_)
	{
		[super setRotation:rot];
		[anchor_ setRotation:-rot];
	}
}

- (void)setScaleX:(float)s
{
	if(!locked_)
	{
		[super setScaleX:s];
		[anchor_ setScaleX:(s != 0) ? 1.0f/s : 0];
	}
}

- (void)setScaleY:(float)s
{
	if(!locked_)
	{
		[super setScaleY:s];
		[anchor_ setScaleY:(s != 0) ? 1.0f/s : 0];
	}
}

- (void)setOpacity:(GLubyte)anOpacity
{
	if(!locked_)
	{
		[super setOpacity:anOpacity];
	}
}

- (void)setIsRelativeAnchorPoint:(BOOL)relative
{
	if(!locked_)
	{
		[super setIsRelativeAnchorPoint:relative];
		
		// update position of anchor point
		CGSize size = [self contentSize];
		if( ![self isRelativeAnchorPoint] )
			[anchor_ setPosition:CGPointZero];
		else
			[anchor_ setPosition:ccp(size.width*anchorPoint_.x, size.height*anchorPoint_.y)];
	}
}

- (void)setIsSelected:(BOOL)selected
{
	if(isSelected_ != selected)
	{
		isSelected_ = selected;
		[fill_ setVisible:selected];
		[anchor_ setVisible:selected];
	}
}

// changes position and text of positionLabel
// must be called on Cocos2D thread
- (void)updatePositionLabel
{
	CGSize s = [anchor_ contentSize];
	NSString *posText = [NSString stringWithFormat:@"%g, %g", floorf( [self position].x ), floorf( [self position].y )];
	[positionLabel_ setString:posText];
	[positionLabel_ setPosition:ccp(s.width/2, -10)];
	
	willUpdatePositionLabel_ = NO;
}

- (void)updatePositionLabelSafely
{
	willUpdatePositionLabel_ = YES;
}

- (void)visit
{
	if(willUpdatePositionLabel_)
	{
		[self updatePositionLabel];
	}
	
	[super visit];
}

- (void)draw
{
	[super draw];
	
	// draw the outline when its selected
	if(isSelected_)
	{
		CGSize s = contentSize_;	
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		glLineWidth(1.0f);
		
		CGPoint vertices[] = {
			ccp(0, s.height),
			ccp(s.width, s.height),
			ccp(s.width, 0),
			ccp(0, 0)
		};
		
		ccDrawPoly(vertices, 4, YES);
	}
}

- (void)dealloc
{
	[fill_ release];
	[anchor_ release];
	[positionLabel_ release];
	[self setKey:nil];
	[self setFilename:nil];
	[self setName:nil];
	[super dealloc];
}

@end