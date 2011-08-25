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
#import "CSSceneView.h"
#import "CSLayerView.h"
#import "CSSprite.h"
#import "CSNode.h"

@implementation CSModel

@synthesize projectName = _projectName;
@synthesize firstTime = _firstTime;
@synthesize nodeProperties = _nodeProperties;
@synthesize workspaceWidth = _workspaceWidth;
@synthesize workspaceHeight = _workspaceHeight;
@synthesize opacity = _opacity;
@synthesize color = _color;
@synthesize name = _name;
@synthesize posX = _posX;
@synthesize posY = _posY;
@synthesize anchorX = _anchorX;
@synthesize anchorY = _anchorY;
@synthesize scaleX = _scaleX;
@synthesize scaleY = _scaleY;
@synthesize rotation = _rotation;
@synthesize zOrder = _zOrder;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.firstTime = YES;
        [self reset];
    }
    
    return self;
}

- (void)dealloc
{
    self.projectName = nil;
    self.color = nil;
    [super dealloc];
}

- (void)reset
{
    // default values
    self.workspaceWidth = 480;
    self.workspaceHeight = 320;
    self.opacity = 0;
    self.color = [NSColor whiteColor];
}

- (CCNode<CSNodeProtocol> *)nodeWithName:(NSString *)name
{
    if ( [[CCDirector sharedDirector].runningScene isKindOfClass:[CSSceneView class]] )
    {
        CSSceneView *scene = (CSSceneView *)[CCDirector sharedDirector].runningScene;
        if (scene.layer)
            for (CCNode<CSNodeProtocol> *node in scene.layer.children)
                if ( [node conformsToProtocol:@protocol(CSNodeProtocol)] && [[node name] isEqualToString:name] )
                    return node;
    }
        
    return nil;
}

@end
