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

#import "CSSceneView.h"
#import "CSLayerView.h"

@interface CSSceneView ()
- (void)updateForScreenReshapeSafely:(NSNotification *)notification;
- (void)updateForScreenReshape;
@end

@implementation CSSceneView

@synthesize layer = _layer;

- (id)init
{
    self = [super init];
    if (self)
    {
        // notify us when screen is resized
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateForScreenReshapeSafely:) name:NSViewFrameDidChangeNotification object:[CCDirector sharedDirector].openGLView];
        
        // add texture
        _backgroundTexture = [[CCSprite spriteWithFile:@"background_texture.png"] retain];
        ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
        [_backgroundTexture.texture setTexParameters:&params];
        _backgroundTexture.position = _backgroundTexture.anchorPoint = CGPointZero;
        [self addChild:_backgroundTexture z:NSIntegerMin];
        [self updateForScreenReshapeSafely:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.layer = nil;
    [_backgroundTexture release];
    [super dealloc];
}

- (void)setLayer:(CSLayerView *)layer
{
    if (layer != _layer)
    {
        // remove child if necessary
        if (_layer.parent)
            [_layer.parent removeChild:_layer cleanup:YES];
        [_layer release];
        
        // set new layer
        _layer = [layer retain];
        if (_layer)
            [self addChild:_layer z:NSIntegerMax];
    }
}

- (void)updateForScreenReshapeSafely:(NSNotification *)notification
{
    _shouldUpdateForScreenReshape = YES;
}

- (void)updateForScreenReshape
{    
    // update checkerboard size to fit winSize
    CGSize s = [CCDirector sharedDirector].winSize;
    [_backgroundTexture setTextureRect:CGRectMake(0, 0, s.width, s.height)];
}

- (void)visit
{
    if (_shouldUpdateForScreenReshape)
    {
        [self updateForScreenReshape];
        _shouldUpdateForScreenReshape = NO;
    }
    
    [super visit];
}

@end
