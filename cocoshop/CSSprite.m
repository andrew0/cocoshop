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

static inline NSString *NSStringFromColor(ccColor3B color)
{
    return [NSString stringWithFormat:@"{%u, %u, %u}", color.r, color.g, color.b];
}

static inline ccColor3B ColorFromNSString(NSString *string)
{
    ccColor3B color;
    sscanf([string cStringUsingEncoding:NSUTF8StringEncoding], "{%u, %u, %u}", &color.r, &color.g, &color.b);
    return color;
}

@implementation CSSprite

@synthesize path = _path;

- (id)initWithTexture:(CCTexture2D *)texture rect:(CGRect)rect
{
    // note that we dont call super initWithTexture:rect:
    self = [self init];
    if (self)
    {
        _node = [[CCSprite alloc] initWithTexture:texture rect:rect];
        [self addChild:_node z:NSIntegerMin];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        CSNODE_MEM_VARS_INIT
    }
    
    return self;
}

- (void)dealloc
{
    self.path = nil;
    if (_node)
        [_node release];
    CSNODE_MEM_VARS_DEALLOC
    [super dealloc];
}

- (void)setOpacity:(GLubyte)opacity
{
    if (opacity != self.opacity)
    {
        [(CSModel *)[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setOpacity:self.opacity];
        [[self undoManager] setActionName:@"Change opacity"];
    }
    
    if (_node && [_node isKindOfClass:[CCSprite class]])
        [(CCSprite *)_node setOpacity:opacity];
}

- (GLubyte)opacity
{
    if (_node && [_node isKindOfClass:[CCSprite class]])
        return [(CCSprite *)_node opacity];
    
    return [super opacity];
}

- (void)setColor:(ccColor3B)color
{
    if (color.r != self.color.r || color.g != self.color.g || color.b != self.color.b)
    {
        NSColor *c = [NSColor colorWithDeviceRed:self.color.r/255.0f green:self.color.g/255.0f blue:self.color.b/255.0f alpha:1];
        [(CSModel *)[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setColor:c];
        [[self undoManager] setActionName:@"Change color"];
    }
    
    if (_node && [_node isKindOfClass:[CCSprite class]])
        [(CCSprite *)_node setColor:color];
}

- (ccColor3B)color
{
    if (_node && [_node isKindOfClass:[CCSprite class]])
        return [(CCSprite *)_node color];
    
    return [super color];
}

- (void)setFlipX:(BOOL)flipX
{
    if (flipX != self.flipX)
    {
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setFlipX:self.flipX];
        [[self undoManager] setActionName:@"Change flip Y"];
    }
    
    if (_node && [_node isKindOfClass:[CCSprite class]])
        [(CCSprite *)_node setFlipX:flipX];
}

- (BOOL)flipX
{
    if (_node && [_node isKindOfClass:[CCSprite class]])
        return [(CCSprite *)_node flipX];
    
    return [super flipX];
}

- (void)setFlipY:(BOOL)flipY
{
    if (flipY != self.flipY)
    {
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setFlipY:self.flipY];
        [[self undoManager] setActionName:@"Change flip Y"];
    }
    
    if (_node && [_node isKindOfClass:[CCSprite class]])
        [(CCSprite *)_node setFlipY:flipY];
}

- (BOOL)flipY
{
    if (_node && [_node isKindOfClass:[CCSprite class]])
        return [(CCSprite *)_node flipY];
    
    return [super flipY];
}

- (void)setTextureRect:(CGRect)rect
{
    if (!CGRectEqualToRect(rect, self.textureRect))
    {
        [[self undoManager] beginUndoGrouping];
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setTextureRectX:self.textureRect.origin.x];
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setTextureRectY:self.textureRect.origin.y];
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setTextureRectWidth:self.textureRect.size.width];
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setTextureRectHeight:self.textureRect.size.height];
        [[self undoManager] setActionName:@"Change texture rect"];
        [[self undoManager] endUndoGrouping];
    }
    
    if (_node && [_node isKindOfClass:[CCSprite class]])
        [(CCSprite *)_node setTextureRect:rect];
}

- (CGRect)textureRect
{
    if (_node && [_node isKindOfClass:[CCSprite class]])
        return [(CCSprite *)_node textureRect];
    
    return [super textureRect];
}

- (NSDictionary *)_dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:11];
    
    [dict setValue:self.path forKey:@"path"];
    [dict setValue:NSStringFromRect(NSRectFromCGRect(self.textureRect)) forKey:@"textureRect"];
    [dict setValue:[NSNumber numberWithUnsignedChar:self.opacity] forKey:@"opacity"];
    [dict setValue:NSStringFromColor(self.color) forKey:@"color"];
    [dict setValue:[NSNumber numberWithBool:self.flipX] forKey:@"flipX"];
    [dict setValue:[NSNumber numberWithBool:self.flipY] forKey:@"flipY"];
    
    return dict;
}

- (void)_setupFromDictionaryRepresentation:(NSDictionary *)dict
{
    self.path = [dict valueForKey:@"path"];
    _node = [[CCSprite alloc] initWithFile:self.path];
    [self addChild:_node z:NSIntegerMin];
    
    CGRect textureRect = NSRectToCGRect(NSRectFromString([dict valueForKey:@"textureRect"]));
    self.textureRect = textureRect;
    self.opacity = [[dict valueForKey:@"opacity"] unsignedCharValue];
    self.color = ColorFromNSString([dict valueForKey:@"color"]);
    self.flipX = [[dict valueForKey:@"flipX"] boolValue];
    self.flipY = [[dict valueForKey:@"flipY"] boolValue];
}

CSNODE_FUNC_SRC

@end
