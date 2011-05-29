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

@interface CCNode (Internal)

-(void) _setZOrder:(int) z;

@end

@implementation CSSprite

@synthesize node=node_;
@synthesize filename=filename_;
@dynamic isSelected;
@dynamic nodeName;
@dynamic isLocked;
@dynamic fill;
@dynamic anchor;
@dynamic positionLabel;

#pragma mark Init / DeInit

- (id)init
{
	if((self=[super init]))
	{
		self.node = [CSNode node];
		[self addChild:node_];
		
		node_.delegate = self;
		
		self.filename = nil;
	}
	
	return self;
}

- (void)dealloc
{
	self.node = nil;
	self.filename = nil;
	[super dealloc];
}

#pragma mark Properties

- (void)setOpacity:(GLubyte)anOpacity
{
	if(!node_.isLocked)
	{
		[super setOpacity:anOpacity];
	}
}

#pragma mark Message Forwarding

- (void)setPosition:(CGPoint)pos
{
	[node_ setPosition:pos];
	[super setPosition:pos];
}

- (void)setAnchorPoint:(CGPoint)a
{
	[node_ setAnchorPoint:a];
	[super setAnchorPoint:a];
}

- (void)setScaleX:(float)sx
{
	[node_ setScaleX:sx];
	[super setScaleX:sx];
}

- (void)setScaleY:(float)sy
{
	[node_ setScaleY:sy];
	[super setScaleY:sy];
}

- (void)setContentSize:(CGSize)cs
{
	[node_ setContentSize:cs];
	[super setContentSize:cs];
}

- (void)setRotation:(float)rot
{
	[node_ setRotation:rot];
	[super setRotation:rot];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector 
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if(!signature)
	{
		signature = [node_ methodSignatureForSelector:selector];
    } 
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	// try forwarding to CSNode
    if([node_ respondsToSelector:[anInvocation selector]])
	{
        [anInvocation invokeWithTarget:node_];
	}
    else
	{
        [super forwardInvocation:anInvocation];
	}
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	return ([super respondsToSelector:aSelector] || [node_ respondsToSelector:aSelector]);
}

#pragma mark -
#pragma mark Archiving

static NSString *dictRepresentation = @"dictionaryRepresentation";

- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:16];
	
	[dict setValue:[node_ nodeName] forKey:@"name"];			
	[dict setValue:[self filename] forKey:@"filename"];
	[dict setValue:[NSNumber numberWithFloat:[self position].x] forKey:@"posX"];
	[dict setValue:[NSNumber numberWithFloat:[self position].y] forKey:@"posY"];
	[dict setValue:[NSNumber numberWithInteger:[self zOrder]] forKey:@"posZ"];
	[dict setValue:[NSNumber numberWithFloat:[self anchorPoint].x] forKey:@"anchorX"];
	[dict setValue:[NSNumber numberWithFloat:[self anchorPoint].y] forKey:@"anchorY"];
	[dict setValue:[NSNumber numberWithFloat:[self scaleX]] forKey:@"scaleX"];
	[dict setValue:[NSNumber numberWithFloat:[self scaleY]] forKey:@"scaleY"];
	[dict setValue:[NSNumber numberWithBool:[self flipX]] forKey:@"flipX"];
	[dict setValue:[NSNumber numberWithBool:[self flipY]] forKey:@"flipY"];
	[dict setValue:[NSNumber numberWithFloat:[self opacity]] forKey:@"opacity"];
	[dict setValue:[NSNumber numberWithFloat:[self color].r] forKey:@"colorR"];
	[dict setValue:[NSNumber numberWithFloat:[self color].g] forKey:@"colorG"];
	[dict setValue:[NSNumber numberWithFloat:[self color].b] forKey:@"colorB"];
	[dict setValue:[NSNumber numberWithFloat:[self rotation]] forKey:@"rotation"];
	[dict setValue:[NSNumber numberWithBool:[self isRelativeAnchorPoint]] forKey:@"relativeAnchor"];
	
	return dict;
}

- (void) setupFromDictionaryRepresentation: (NSDictionary *) aDict
{
	node_.nodeName = [aDict objectForKey:@"name"];
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