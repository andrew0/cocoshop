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

@synthesize undoManager = _undoManager;
@synthesize projectName = _projectName;
@synthesize selectedNode = _selectedNode;
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
@synthesize tag = _tag;
@synthesize visible = _visible;
@synthesize relativeAnchor = _relativeAnchor;
@synthesize textureRectX = _textureRectX;
@synthesize textureRectY = _textureRectY;
@synthesize textureRectWidth = _textureRectWidth;
@synthesize textureRectHeight = _textureRectHeight;
@synthesize flipX = _flipX;
@synthesize flipY = _flipY;


- (id)init
{
    self = [super init];
    if (self)
    {
        self.undoManager = [[NSUndoManager alloc] init];
        self.firstTime = YES;
        [self reset];
    }
    
    return self;
}

- (void)dealloc
{
    self.undoManager = nil;
    self.projectName = nil;
    self.color = nil;
    self.selectedNode = nil;
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

- (void)setSelectedNode:(CCNode<CSNodeProtocol> *)selectedNode
{
    if (selectedNode != _selectedNode)
    {
        [_selectedNode setIsSelected:NO];
        [_selectedNode release];
        _selectedNode = [selectedNode retain];
        [_selectedNode setIsSelected:YES];
        
        // update model
        self.posX = _selectedNode.position.x;
        self.posY = _selectedNode.position.y;
        self.anchorX = _selectedNode.anchorPoint.x;
        self.anchorY = _selectedNode.anchorPoint.y;
        self.scaleX = _selectedNode.scaleX;
        self.scaleY = _selectedNode.scaleY;
        self.rotation = _selectedNode.rotation;
        self.zOrder = _selectedNode.zOrder;
        self.tag = _selectedNode.tag;
        self.visible = _selectedNode.visible;
        self.relativeAnchor = _selectedNode.isRelativeAnchorPoint;
        
        if ( [_selectedNode conformsToProtocol:@protocol(CCRGBAProtocol)] )
        {
            ccColor3B c = [(CCNode<CCRGBAProtocol> *)_selectedNode color];
            self.color = [NSColor colorWithDeviceRed:c.r/255.0f green:c.g/255.0f blue:c.b/255.0f alpha:1];
            self.opacity = [(CCNode<CCRGBAProtocol> *)_selectedNode opacity];
        }
        
        if ( [_selectedNode isKindOfClass:[CCSprite class]] )
        {
            self.flipX = [(CCSprite *)_selectedNode flipX];
            self.flipX = [(CCSprite *)_selectedNode flipY];
            
            CGRect r = [(CCSprite *)_selectedNode textureRect];
            self.textureRectX = r.origin.x;
            self.textureRectY = r.origin.y;
            self.textureRectWidth = r.size.width;
            self.textureRectHeight = r.size.height;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectNode" object:selectedNode];
    }
}

@end
