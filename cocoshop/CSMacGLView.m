/*
 * cocoshop
 *
 * Copyright (c) 2011 Andrew
 * Copyright (c) 2011 Stepan Generalov
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

#import "CSMacGLView.h"
#import "CSLayerView.h"
#import "CSSceneView.h"

@implementation CSMacGLView

- (void)awakeFromNib
{
    // OpenGL view flickers with elastic scrolling
#if defined(__MAC_10_7) && __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_7
    [[self enclosingScrollView] setHorizontalScrollElasticity:NSScrollElasticityNone];
    [[self enclosingScrollView] setVerticalScrollElasticity:NSScrollElasticityNone];
#endif
}

- (NSSize)viewportSize
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGFloat width = winSize.width;
    CGFloat height = winSize.height;
    
    NSSize contentFrameSize = [[[self enclosingScrollView] contentView] frame].size;
    NSSize frameSize;
    
    frameSize.width = MAX(width, contentFrameSize.width);
    frameSize.height = MAX(height, contentFrameSize.height);
    
    if ( [[CCDirector sharedDirector].runningScene isKindOfClass:[CSSceneView class]] )
    {
        CSSceneView *scene = (CSSceneView *)[CCDirector sharedDirector].runningScene;
        if (scene.layer)
        {
            CGSize workspaceSize = scene.layer.adjustedWorkspaceSize;
            frameSize.width = MAX(workspaceSize.width, frameSize.width);
            frameSize.height = MAX(workspaceSize.height, frameSize.height);
        }
    }
    
    return frameSize;
}

- (void)updateForScreenReshape
{
    // BUG: occasionally this causes a crash - no clue why
    [self setFrameSize:[self viewportSize]];
    
    // update frame
    CSSceneView *scene;
    if ( [[CCDirector sharedDirector].runningScene isKindOfClass:[CSSceneView class]] )
    {
        scene = (CSSceneView *)[CCDirector sharedDirector].runningScene;
        if (scene.layer)
        {
            scene.layer.offset = ccp(-[self visibleRect].origin.x, -[self visibleRect].origin.y);
            [scene.layer updateForScreenReshapeSafely:nil];
        }
    }
}

- (void)reshape
{
    // for some reason if we resize while an action is running OpenGL crashes,
    // so only resize if
    // 1. the window was resized (which would also cause the scroll view frame to resize), or
    // 2. there is no running action for the layer
    if ( !CGSizeEqualToSize(_lastSize, [[self enclosingScrollView] frame].size) &&
        [[[CCDirector sharedDirector] runningScene] isKindOfClass:[CSSceneView class]] &&
        [[(CSSceneView *)[[CCDirector sharedDirector] runningScene] layer] numberOfRunningActions] < 1)
        [[CCDirector sharedDirector] drawScene];
    
    if ( !CGSizeEqualToSize([[CCDirector sharedDirector] winSize], [self visibleRect].size) )
    {
        // update cocos2d size
        CGLLockContext([[self openGLContext] CGLContextObj]);
        [[CCDirector sharedDirector] reshapeProjection:[self visibleRect].size];
        CGLUnlockContext([[self openGLContext] CGLContextObj]);
    }
    
    if ( [[[CCDirector sharedDirector] runningScene] isKindOfClass:[CSSceneView class]] && [[(CSSceneView *)[[CCDirector sharedDirector] runningScene] layer] numberOfRunningActions] < 1)
        [[CCDirector sharedDirector] drawScene];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSViewFrameDidChangeNotification object:self];
    [self updateForScreenReshape];
    
    _lastSize = [[self enclosingScrollView] frame].size;
}

#pragma mark User Input

- (void)scrollWheel:(NSEvent *)theEvent
{
    if ( ([theEvent modifierFlags] & NSCommandKeyMask) && [[CCDirector sharedDirector].runningScene isKindOfClass:[CSSceneView class]] )
    {
        CSSceneView *scene = (CSSceneView *)[CCDirector sharedDirector].runningScene;
        if (scene.layer)
            scene.layer.scale = MIN(MAX(scene.layer.scale + [theEvent deltaY] * 0.01f, 0.1f), 3.0f);
    }
    else
    {
        // send scroll events to scroll view
        [[self enclosingScrollView] scrollWheel:theEvent];
    }
}

@end
