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

@interface CCNode (Internal)
- (void)_setZOrder:(int)z;
@end

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
		firstOnEnter_ = YES;
		self.delegate = nil;
		self.nodeName = nil;
		self.isLocked = NO;
		
		self.fill = [[CCLayerColor layerWithColor:ccc4(30,144,255,25.5f)] retain];
		[self addChild:fill_];
		
		self.anchor = [[CCSprite spriteWithFile:@"anchor.png"] retain];
		[anchor_ setOpacity:200];
		[self addChild:anchor_];
		
		NSString *posText = @"0, 0";
		self.positionLabel = [[CCLabelBMFont labelWithString:posText fntFile:@"arial.fnt"] retain];
		[anchor_ addChild:positionLabel_];
		
		
		// resize controls
		resizeControls_ = [[CCNode node] retain];
		[self addChild:resizeControls_];
	}
	
	return self;
}

- (void)dealloc
{
	self.nodeName = nil;
	self.fill = nil;
	self.anchor = nil;
	self.positionLabel = nil;
	[resizeControls_ release];
	[super dealloc];
}

#pragma mark Update 

// changes position and text of positionLabel
// must be called on Cocos2D thread
- (void)updatePositionLabel
{
	CGSize s = anchor_.contentSize;
	CGPoint p = position_;
	NSString *posText = [NSString stringWithFormat:@"%g, %g", floorf( p.x ), floorf( p.y )];
	[positionLabel_ setString:posText];
	[positionLabel_ setPosition:ccp(s.width/2, -10)];
	
	willUpdatePositionLabel_ = NO;
}

- (void)updatePositionLabelSafely
{
	willUpdatePositionLabel_ = YES;
}

- (void)updateAnchor
{
	CGSize size = contentSize_;
	
	if( !isRelativeAnchorPoint_ )
		[anchor_ setPosition:CGPointZero];
	else
		[anchor_ setPosition:ccp(size.width*anchorPoint_.x, size.height*anchorPoint_.y)];	
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
		[super setPosition:pos];
		[self updatePositionLabelSafely];
	}
}

- (void)setAnchorPoint:(CGPoint)anchor
{
	if(!isLocked_)
	{
		[super setAnchorPoint:anchor];
		
		// update position of anchor point
		[self updateAnchor];
	}
}

- (void)setScaleX:(float)sx
{
	if(!isLocked_)
	{
		[super setScaleX:sx];
		
		anchor_.scaleX = (sx != 0) ? 1.0f/sx : 0;
		
		for(CCNode *child in [resizeControls_ children])
		{
			child.scaleX = (sx != 0) ? 1.0f/sx : 0;
		}
	}
}

- (void)setScaleY:(float)sy
{
	if(!isLocked_)
	{
		[super setScaleX:sy];
		
		anchor_.scaleY = (sy != 0) ? 1.0f/sy : 0;
		
		for(CCNode *child in [resizeControls_ children])
		{
			child.scaleY = (sy != 0) ? 1.0f/sy : 0;
		}
	}
}

- (void)setRotation:(float)rot
{
	if(!isLocked_)
	{
		[super setRotation:rot];
		[positionLabel_ setRotation:-rot];
		//TODO: reposition somehow positionLabel_ to be always at the bottom of anchor_
		// if this is necessary
	}
}

- (void)setIsRelativeAnchorPoint:(BOOL)relative
{
	if(!isLocked_)
	{
		[super setIsRelativeAnchorPoint:relative];
		
		// update position of anchor point
		[self updateAnchor];
	}
}

- (void)setIsSelected:(BOOL)selected
{
	if(isSelected_ != selected)
	{
		isSelected_ = selected;
		[fill_ setVisible:selected];
		[anchor_ setVisible:selected];
		[resizeControls_ setVisible:selected];
		[self updateAnchor];
	}
}

#pragma mark CCNode Reimplemented Methods

- (void)onEnter
{
	[super onEnter];
	
	if(firstOnEnter_)
	{
		CGSize s = contentSize_;
		
		CCSprite *tl = [CCSprite spriteWithFile:@"resize.png"];
		CCSprite *tr = [CCSprite spriteWithFile:@"resize.png"];
		CCSprite *bl = [CCSprite spriteWithFile:@"resize.png"];
		CCSprite *br = [CCSprite spriteWithFile:@"resize.png"];
		CCSprite *t = [CCSprite spriteWithFile:@"resize.png"];
		CCSprite *r = [CCSprite spriteWithFile:@"resize.png"];
		CCSprite *b = [CCSprite spriteWithFile:@"resize.png"];
		CCSprite *l = [CCSprite spriteWithFile:@"resize.png"];
		
		tl.position = ccp(0, s.height);
		tr.position = ccp(s.width, s.height);
		bl.position = ccp(0, 0);
		br.position = ccp(s.width, 0);
		t.position = ccp(s.width/2, s.height);
		r.position = ccp(s.width, s.height/2);
		b.position = ccp(s.width/2, 0);
		l.position = ccp(0, s.height/2);
		
		[resizeControls_ addChild:tl];
		[resizeControls_ addChild:tr];
		[resizeControls_ addChild:bl];
		[resizeControls_ addChild:br];
		[resizeControls_ addChild:t];
		[resizeControls_ addChild:r];
		[resizeControls_ addChild:b];
		[resizeControls_ addChild:l];
		
		
		[fill_ changeWidth:s.width height:s.height];
		[anchor_ setPosition:ccp(s.width*delegate_.anchorPoint.x, s.height*delegate_.anchorPoint.y)];
		
		CGSize anchorSize = [anchor_ contentSize];
		[positionLabel_ setPosition:ccp(anchorSize.width/2, -10)];			
		
		firstOnEnter_ = NO;		
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
	if( isSelected_ )
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

#pragma mark -
#pragma mark Archiving

static NSString *const dictRepresentation = @"dictionaryRepresentation";

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:16];
	
	[dict setValue:nodeName_ forKey:@"name"];
	[dict setValue:NSStringFromPoint(NSPointFromCGPoint(position_)) forKey:@"position"];
	[dict setValue:NSStringFromPoint(NSPointFromCGPoint(anchorPoint_)) forKey:@"anchorPoint"];
	[dict setValue:[NSNumber numberWithInteger:zOrder_] forKey:@"zOrder"];
	[dict setValue:[NSNumber numberWithFloat:scaleX_] forKey:@"scaleX"];
	[dict setValue:[NSNumber numberWithFloat:scaleY_] forKey:@"scaleY"];
	[dict setValue:[NSNumber numberWithFloat:rotation_] forKey:@"rotation"];
	[dict setValue:[NSNumber numberWithBool:isRelativeAnchorPoint_] forKey:@"isRelativeAnchorPoint"];
	
	return dict;
}

- (void)setupFromDictionaryRepresentation:(NSDictionary *)aDict
{
	self.nodeName = [aDict objectForKey:@"name"];
	self.position = NSPointToCGPoint( NSPointFromString( [aDict objectForKey:@"position"] ) );
	self.anchorPoint = NSPointToCGPoint( NSPointFromString( [aDict objectForKey:@"anchorPoint"] ) );
	self.scaleX = [[aDict objectForKey:@"scaleX"] floatValue];
	self.scaleY = [[aDict objectForKey:@"scaleY"] floatValue];
	self.rotation = [[aDict objectForKey:@"rotation"] floatValue];
	self.isRelativeAnchorPoint = [[aDict objectForKey:@"isRelativeAnchorPoint"] boolValue];
	[self _setZOrder:[[aDict objectForKey:@"zOrder"] floatValue]];
}

- (id)initWithCoder:(NSCoder *)coder 
{
    if(self = [self init]) 
	{
        NSDictionary *dict = [coder decodeObjectForKey:dictRepresentation]; 
		[self setupFromDictionaryRepresentation:dict];
    }
	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:[self dictionaryRepresentation] forKey:dictRepresentation];
}

#pragma mark NSPasteboardWriting
NSString *const CSNodeUTI = @"org.cocos2d-iphone.cocoshop.CSNode";

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard 
{
    static NSArray *writableTypes = nil;
    
    if(!writableTypes)
	{
        writableTypes = [[NSArray alloc] initWithObjects:CSNodeUTI, nil];
    }
	
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type 
{
    if([type isEqualToString:CSNodeUTI]) 
	{
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
	
    return nil;
}

#pragma mark NSPasteboardReading
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard 
{    
    static NSArray *readableTypes = nil;
    if(!readableTypes) 
	{
        readableTypes = [[NSArray alloc] initWithObjects:CSNodeUTI, nil];
    }
    return readableTypes;
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard 
{
    if([type isEqualToString:CSNodeUTI]) 
	{
		// This means you don't need to implement code for this type in initWithPasteboardPropertyList:ofType: -- initWithCoder: is invoked instead.
        return NSPasteboardReadingAsKeyedArchive;
    }
    return 0;
}

@end
