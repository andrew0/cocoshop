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

@implementation CSNode

@synthesize delegate=delegate_;
@synthesize isSelected=isSelected_;
@synthesize nodeName=nodeName_;
@synthesize isLocked=isLocked_;
@synthesize fill=fill_;
@synthesize anchor=anchor_;
@synthesize positionLabel=positionLabel_;

#pragma mark Init / DeInit

- (id)init
{
	if((self=[super init]))
	{
		self.delegate = nil;
		self.nodeName = nil;
		self.isLocked = NO;
		
		self.isRelativeAnchorPoint = NO;
		
		self.fill = [[CCLayerColor layerWithColor:ccc4(30,144,255,25.5f)] retain];
		[self addChild:fill_];
		
		self.anchor = [[CCSprite spriteWithFile:@"anchor.png"] retain];
		[anchor_ setOpacity:200];
		[self addChild:anchor_];
		
		NSString *posText = @"0, 0";
		self.positionLabel = [[CCLabelBMFont labelWithString:posText fntFile:@"arial.fnt"] retain];
		[anchor_ addChild:positionLabel_];
	}
	
	return self;
}

- (void)dealloc
{
	self.delegate = nil;
	self.nodeName = nil;
	self.fill = nil;
	self.anchor = nil;
	self.positionLabel = nil;
	[super dealloc];
}

#pragma mark Update 

// changes position and text of positionLabel
// must be called on Cocos2D thread
- (void)updatePositionLabel
{
	CGSize s = anchor_.contentSize;
	CGPoint p = delegate_.position;
	NSString *posText = [NSString stringWithFormat:@"%g, %g", floorf( p.x ), floorf( p.y )];
	[positionLabel_ setString:posText];
	[positionLabel_ setPosition:ccp(s.width/2, -10)];
	
	willUpdatePositionLabel_ = NO;
}

- (void)updatePositionLabelSafely
{
	willUpdatePositionLabel_ = YES;
}

#pragma mark Properties

- (void)setNodeName:(NSString *)aName
{
	if(nodeName_ != aName)
	{
		// make the key alphanumerical + underscore
		NSCharacterSet *charactersToKeep = [NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"];
		aName = [[aName componentsSeparatedByCharactersInSet:[charactersToKeep invertedSet]] componentsJoinedByString:@"_"];		
		
		[nodeName_ release];
		nodeName_ = [aName copy];
	}
}

- (void)setPosition:(CGPoint)pos
{
	if(!isLocked_)
	{
		[self updatePositionLabelSafely];
	}
}

- (void)setAnchorPoint:(CGPoint)anchor
{
	if(!isLocked_)
	{
		// update position of anchor point
		CGSize size = delegate_.contentSize;
		
		if( !delegate_.isRelativeAnchorPoint )
			[anchor_ setPosition:CGPointZero];
		else
			[anchor_ setPosition:ccp(size.width*anchor.x, size.height*anchor.y)];
	}
}

- (void)setScaleX:(float)s
{
	if(!isLocked_)
	{
		[anchor_ setScaleX:(s != 0) ? 1.0f/s : 0];
	}
}

- (void)setScaleY:(float)s
{
	if(!isLocked_)
	{
		[anchor_ setScaleY:(s != 0) ? 1.0f/s : 0];
	}
}

- (void)setRotation:(float)rot
{
	if(!isLocked_)
	{
		[positionLabel_ setRotation:-rot];
		//TODO: reposition somehow positionLabel_ to be always at the bottom of anchor_
		// if this is necessary
	}
}

- (void)setIsRelativeAnchorPoint:(BOOL)relative
{
	if(!isLocked_)
	{
		[delegate_ setIsRelativeAnchorPoint:relative];
		
		// update position of anchor point
		CGSize size = delegate_.contentSize;
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

#pragma mark CCNode Reimplemented Methods

- (void)onEnter
{
	[super onEnter];
	
	if( [delegate_ respondsToSelector:@selector(contentSize)] )
	{
		CGSize size = [delegate_ contentSize];
		[fill_ changeWidth:size.width height:size.height];
		[anchor_ setPosition:ccp(size.width*anchorPoint_.x, size.height*anchorPoint_.y)];
		
		CGSize s = [anchor_ contentSize];
		[positionLabel_ setPosition:ccp(s.width/2, -10)];
	}
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
	CGSize s = [delegate_ contentSize];	
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

@end
