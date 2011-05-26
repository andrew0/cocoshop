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

@implementation CSSprite

@synthesize isSelected=isSelected_;
@synthesize filename=filename_;
@synthesize name=name_;
@synthesize locked=locked_;

#pragma mark Init / DeInit

- (id)init
{
	if((self=[super init]))
	{
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

- (void)dealloc
{
	[fill_ release];
	[anchor_ release];
	[positionLabel_ release];
	[self setFilename:nil];
	[self setName:nil];
	[super dealloc];
}

#pragma mark Update 

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

#pragma mark Properties

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
		[positionLabel_ setRotation:-rot];
		//TODO: reposition somehow positionLabel_ to be always at the bottom of anchor_
		// if this is necessary 
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


#pragma mark CCNode Reimplemented Methods

- (void)onEnter
{
	[super onEnter];
	
	CGSize size = contentSize_;
	[fill_ changeWidth:size.width height:size.height];
	[anchor_ setPosition:ccp(size.width*anchorPoint_.x, size.height*anchorPoint_.y)];
	
	CGSize s = [anchor_ contentSize];
	[positionLabel_ setPosition:ccp(s.width/2, -10)];	
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

#pragma mark -
#pragma mark Archiving

static NSString *dictRepresentation = @"dictionaryRepresentation";

- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:16];
	
	[childValues setValue:[self name] forKey:@"name"];			
	[childValues setValue:[self filename] forKey:@"filename"];
	[childValues setValue:[NSNumber numberWithFloat:[self position].x] forKey:@"posX"];
	[childValues setValue:[NSNumber numberWithFloat:[self position].y] forKey:@"posY"];
	[childValues setValue:[NSNumber numberWithInteger:[self zOrder]] forKey:@"posZ"];
	[childValues setValue:[NSNumber numberWithFloat:[self anchorPoint].x] forKey:@"anchorX"];
	[childValues setValue:[NSNumber numberWithFloat:[self anchorPoint].y] forKey:@"anchorY"];
	[childValues setValue:[NSNumber numberWithFloat:[self scaleX]] forKey:@"scaleX"];
	[childValues setValue:[NSNumber numberWithFloat:[self scaleY]] forKey:@"scaleY"];
	[childValues setValue:[NSNumber numberWithBool:[self flipX]] forKey:@"flipX"];
	[childValues setValue:[NSNumber numberWithBool:[self flipY]] forKey:@"flipY"];
	[childValues setValue:[NSNumber numberWithFloat:[self opacity]] forKey:@"opacity"];
	[childValues setValue:[NSNumber numberWithFloat:[self color].r] forKey:@"colorR"];
	[childValues setValue:[NSNumber numberWithFloat:[self color].g] forKey:@"colorG"];
	[childValues setValue:[NSNumber numberWithFloat:[self color].b] forKey:@"colorB"];
	[childValues setValue:[NSNumber numberWithFloat:[self rotation]] forKey:@"rotation"];
	[childValues setValue:[NSNumber numberWithBool:[self isRelativeAnchorPoint]] forKey:@"relativeAnchor"];
	
	return dict;
}

- (void) setupFromDictionaryRepresentation: (NSDictionary *) aDict
{
	self.name = [aDict objectForKey:@"name"];
	self.filename = [aDict objectForKey:@"filename"];
	
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: self.filename];
	if (!texture)
	{
		//TODO: implement spriteSetupFailed notification listener in CSObjectController & show error message
		[[NSNotificationCenter defaultCenter] postNotificationName:@"spriteSetupFailed" object: aDict];
		return;		
	}
	
	// Set Texture & TextureRect
	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	[self setTexture:texture];
	[self setTextureRect:rect];
	
	// Set Other Properties for CCSprite
	CGPoint childPos = ccp([[aDict objectForKey:@"posX"] floatValue], [[aDict objectForKey:@"posY"] floatValue]);
	[self setPosition:childPos];
	
	CGPoint childAnchor = ccp([[aDict objectForKey:@"anchorX"] floatValue], [[aDict objectForKey:@"anchorY"] floatValue]);
	[self setAnchorPoint:childAnchor];
	
	CGFloat childScaleX = [[aDict objectForKey:@"scaleX"] floatValue];
	CGFloat childScaleY = [[aDict objectForKey:@"scaleY"] floatValue];
	[self setScaleX:childScaleX];
	[self setScaleY:childScaleY];
	
	BOOL childFlipX = [[aDict objectForKey:@"flipX"] boolValue];
	BOOL childFlipY = [[aDict objectForKey:@"flipX"] boolValue];
	[self setFlipX:childFlipX];
	[self setFlipY:childFlipY];
	
	CGFloat childOpacity = [[aDict objectForKey:@"opacity"] floatValue];
	[self setOpacity:childOpacity];
	
	ccColor3B childColor = ccc3([[aDict objectForKey:@"colorR"] floatValue], [[aDict objectForKey:@"colorG"] floatValue], [[aDict objectForKey:@"colorB"] floatValue]);
	[self setColor:childColor];
	
	CGFloat childRotation = [[aDict objectForKey:@"rotation"] floatValue];
	[self setRotation:childRotation];
	
	BOOL childRelativeAnchor = [[aDict objectForKey:@"relativeAnchor"] boolValue];
	[self setIsRelativeAnchorPoint:childRelativeAnchor];
	
	[self _setZOrder:  [[aDict objectForKey:@"posZ"] floatValue]];
}

- (id)initWithCoder:(NSCoder *)coder 
{
    if (self = [super init]) 
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
NSString *CSSpriteUTI = @"org.cocos2d-iphone.cocoshop.CSSprite";

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard 
{
    static NSArray *writableTypes = nil;
    
    if (!writableTypes) {
        writableTypes = [[NSArray alloc] initWithObjects:CSSpriteUTI, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type 
{
    if ([type isEqualToString:CSSpriteUTI]) 
	{
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
	
    return nil;
}

#pragma mark NSPasteboardReading
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard 
{    
    static NSArray *readableTypes = nil;
    if (!readableTypes) 
	{
        readableTypes = [[NSArray alloc] initWithObjects:CSSpriteUTI, nil];
    }
    return readableTypes;
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard 
{
    if ([type isEqualToString:CSSpriteUTI]) 
	{
        /*
         This means you don't need to implement code for this type in initWithPasteboardPropertyList:ofType: -- initWithCoder: is invoked instead.
         */
        return NSPasteboardReadingAsKeyedArchive;
    }
    return 0;
}

@end