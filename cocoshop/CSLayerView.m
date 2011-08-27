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

#import "CSLayerView.h"
#import "CSModel.h"
#import "CSNode.h"

@implementation CSLayerView

@synthesize model = _model;
@synthesize selectedNode = _selectedNode;
@synthesize offest = _offset;
@synthesize workspaceSize = _workspaceSize;
@synthesize backgroundLayer = _backgroundLayer;
@dynamic adjustedWorkspaceSize;

#pragma mark Initialization

- (id)initWithModel:(CSModel *)model
{
    self = [super init];
    if (self)
    {
        self.model = model;
        
        // register for screen resize notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateForScreenReshapeSafely:) name:NSViewFrameDidChangeNotification object:[CCDirector sharedDirector].openGLView];
        
        // add a checkerboard repeating background to represent transparency
        _checkerboard = [CCSprite spriteWithFile:@"checkerboard.png"];
        ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
        [_checkerboard.texture setTexParameters:&params];
        _checkerboard.position = _checkerboard.anchorPoint = CGPointZero;
        [self addChild:_checkerboard z:NSIntegerMin];
        [self updateForScreenReshapeSafely:nil];
        
        // background layer
        self.backgroundLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
        [self addChild:_backgroundLayer z:NSIntegerMin+1];
        
        // children to add
        _childrenToAdd = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_childrenToAdd release];
    self.backgroundLayer = nil;
    self.model = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Add Children

- (void)addChildSafely:(CCNode *)node z:(NSInteger)z tag:(NSInteger)tag
{
    NSMutableDictionary *childToAdd = [NSMutableDictionary dictionaryWithCapacity:3];
    [childToAdd setValue:node forKey:@"node"];
    [childToAdd setValue:[NSNumber numberWithInteger:z] forKey:@"z"];
    [childToAdd setValue:[NSNumber numberWithInteger:tag] forKey:@"tag"];
    [_childrenToAdd addObject:childToAdd];
}

- (void)addChildSafely:(CCNode *)node z:(NSInteger)z
{
    [self addChildSafely:node z:z tag:node.tag];
}

- (void)addChildSafely:(CCNode *)node
{
    [self addChildSafely:node z:node.zOrder tag:node.tag];
}

#pragma mark -
#pragma mark Custom Accessors

- (void)setWorkspaceSize:(CGSize)s
{
    if ( !CGSizeEqualToSize(_workspaceSize, s) )
    {
        _workspaceSize = s;
        self.contentSizeInPixels = _workspaceSize;
        [[[CCDirector sharedDirector] openGLView] reshape];
        [self updateForScreenReshapeSafely:nil];
    }
}

- (void)setScale:(float)scale
{
    [super setScale:scale];
    [[[CCDirector sharedDirector] openGLView] reshape];
}

- (void)setScaleX:(float)sx
{
    [super setScaleX:sx];
    [[[CCDirector sharedDirector] openGLView] reshape];
}

- (void)setScaleY:(float)sy
{
    [super setScaleY:sy];
    [[[CCDirector sharedDirector] openGLView] reshape];
}

- (CGSize)adjustedWorkspaceSize
{
    CGSize adjustedWorkspaceSize = _workspaceSize;
    adjustedWorkspaceSize.width *= scaleX_;
    adjustedWorkspaceSize.height *= scaleY_;
    return adjustedWorkspaceSize;
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
        _model.posX = _selectedNode.position.x;
        _model.posY = _selectedNode.position.y;
        _model.anchorX = _selectedNode.anchorPoint.x;
        _model.anchorY = _selectedNode.anchorPoint.y;
        _model.scaleX = _selectedNode.scaleX;
        _model.scaleY = _selectedNode.scaleY;
        _model.rotation = _selectedNode.rotation;
        _model.zOrder = _selectedNode.zOrder;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectSprite" object:selectedNode];
    }
}

#pragma mark -
#pragma mark Screen Resize

- (void)updateForScreenReshapeSafely:(NSNotification *)notification
{
    _shouldUpdateForScreenReshape = YES;
}

- (void)updateForScreenReshape
{    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGSize adjustedWorkspaceSize = [self adjustedWorkspaceSize];
    
    // calculate centered position
    self.isRelativeAnchorPoint = YES;
    CGPoint centerPos = ccp(winSize.width/2, winSize.height/2);
    
    // clamp new position
    centerPos.x = MAX(adjustedWorkspaceSize.width/2, centerPos.x);
    centerPos.y = MAX(adjustedWorkspaceSize.height/2, centerPos.y);
    
    // apply offset
    self.position = ccpAdd(centerPos, _offset);
    
    // resize checkerboard
    [_checkerboard setTextureRect:CGRectMake(0, 0, _workspaceSize.width, _workspaceSize.height)];
    
    // resize background layer
    [_backgroundLayer changeWidth:_workspaceSize.width height:_workspaceSize.height];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSWindowDidResizeNotification object:[[[CCDirector sharedDirector] openGLView] window]];
}

- (void)visit
{
    if (_shouldUpdateForScreenReshape)
    {
        [self updateForScreenReshape];
        _shouldUpdateForScreenReshape = NO;
    }
    
    // we have to make a copy of the array in case another child is added to it
    // in another thread. we could do the whole loop in an @synchronized lock,
    // but it'll avoid possible lag if we just do it this way
    NSArray *childrenToAdd;
    @synchronized (_childrenToAdd)
    {
        childrenToAdd = [[_childrenToAdd copy] autorelease];
        [_childrenToAdd removeAllObjects];
    }
    
    // loop through each of the children to add
    // it should contain NSDictionaries with a
    // node, z order, and tag
    for (NSDictionary *childToAdd in childrenToAdd)
    {
        CCNode *child = [childToAdd objectForKey:@"node"];
        NSNumber *z = [childToAdd objectForKey:@"z"];
        NSNumber *tag = [childToAdd objectForKey:@"tag"];
        if (child && z && tag)
        {
            [self addChild:child z:[z integerValue] tag:[tag integerValue]];
            
            // tell the window controller that the child has been added
            // the window controller will reload the outline view data
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addedChild" object:child];
        }
    }
    
    [super visit];
}

- (void)draw
{
    // draw outline of the workspace
    CGPoint verts[] = {
        ccp(0,0),
        ccp(_workspaceSize.width,0),
        ccp(_workspaceSize.width,_workspaceSize.height),
        ccp(0,_workspaceSize.height)
    };
    ccDrawPoly(verts, 4, YES);
}

@end
