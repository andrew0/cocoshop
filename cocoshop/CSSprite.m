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

@implementation CSSprite

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
    if (_node)
        [_node release];
    CSNODE_MEM_VARS_DEALLOC
    [super dealloc];
}

- (void)setOpacity:(GLubyte)opacity
{
    if (_node && [_node isKindOfClass:[CCSprite class]])
        [(CCSprite *)_node setOpacity:opacity];
}

- (void)setColor:(ccColor3B)color
{
    if (_node && [_node isKindOfClass:[CCSprite class]])
        [(CCSprite *)_node setColor:color];
}

- (void)setFlipX:(BOOL)flipX
{
    if (_node && [_node isKindOfClass:[CCSprite class]])
        [(CCSprite *)_node setFlipX:flipX];
}

- (void)setFlipY:(BOOL)flipY
{
    if (_node && [_node isKindOfClass:[CCSprite class]])
        [(CCSprite *)_node setFlipY:flipY];
}

CSNODE_FUNC_SRC

@end
