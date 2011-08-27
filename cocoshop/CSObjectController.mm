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

#import "CSObjectController.h"
#import "CSModel.h"
#import "CSLayerView.h"
#import "CSSceneView.h"
#import "CSNode.h"
#import "CSNode.h"
#import "CCNode+Additions.h"
#import "CSViewController.h"
#import <ChromiumTabs/ChromiumTabs.h>
#import "CSBrowserWindowController.h"
#import "CSTabContents.h"

@implementation CSObjectController

@synthesize currentModel = _currentModel;
@synthesize currentView = _currentView;
@synthesize selectedNode = _selectedNode;

- (void)awakeFromNib
{
    [[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority:NSIntegerMax];
}

- (void)dealloc
{
    self.currentModel = nil;
    self.currentView = nil;
    self.selectedNode = nil;
    [super dealloc];
}

- (void)selectDictionary:(NSDictionary *)dict
{
    // unbind old contentObject
    [self unbind:@"contentObject"];
        
    CSModel *model = [dict objectForKey:@"model"];
    CSLayerView *view = [dict objectForKey:@"view"];
    
    if (model && view)
    {        
        // bind contentObject to model
        [self bind:@"contentObject" toObject:model withKeyPath:@"self" options:nil];
                
        // set new model and view
        self.currentModel = model;
        self.currentView = view;
        
        // check if it's the first time we're handling model
        if (model.firstTime)
        {
            // we do this so that we'll ge the notifications for the KVO changes
            // to set the default values
            [model reset];
            model.firstTime = NO;
        }
        
        // if necessary, create scene view
        CSSceneView *scene;
        if ( ![[CCDirector sharedDirector].runningScene isKindOfClass:[CSSceneView class]] )
        {
            scene = [CSSceneView node];
            if ( [CCDirector sharedDirector].runningScene == nil)
                [[CCDirector sharedDirector] runWithScene:scene];
            else
                [[CCDirector sharedDirector] replaceScene:scene];
        }
        else
        {
            scene = (CSSceneView *)[CCDirector sharedDirector].runningScene;
        }
        
        // set layer to the current view
        scene.layer = view;
    }
}

- (NSString *)uniqueNameFromString:(NSString *)string
{
    // make the key alphanumerical + underscore
    NSCharacterSet *charactersToKeep = [NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"];
    NSString *name = [[string componentsSeparatedByCharactersInSet:[charactersToKeep invertedSet]] componentsJoinedByString:@"_"];
    
    NSUInteger i = 0;
    NSString *newName = [NSString stringWithString:name];
    while ( [_currentModel nodeWithName:newName] )
    {
        newName = [name stringByAppendingFormat:@"_%lu", (unsigned long)i++];
        
        // if it's maximum number, return nil
        if (i == NSUIntegerMax && [_currentModel nodeWithName:newName])
            return nil;
    }
    
    return newName;
}

#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    // I'm not entirely sure, but I'm guessing that we dont need to register for observing these values
    // since we bound the model to contentObject
    if ( [keyPath isEqualToString:@"projectName"] )
    {
        NSWindow *window = [[[CCDirector sharedDirector] openGLView] window];
        if ( [[window windowController] isKindOfClass:[CSBrowserWindowController class]] )
        {
            CSBrowserWindowController *wc = (CSBrowserWindowController *)window.windowController;
            CTTabContents *contents = [wc selectedTabContents];
            contents.title = _currentModel.projectName;
        }
    }
    else if ( [keyPath isEqualToString:@"workspaceWidth"] || [keyPath isEqualToString:@"workspaceHeight"] )
    {
        _currentView.workspaceSize = CGSizeMake(_currentModel.workspaceWidth, _currentModel.workspaceHeight);
    }
    else if ( [keyPath isEqualToString:@"opacity"] )
    {
        [_currentView.backgroundLayer setOpacity:_currentModel.opacity];
    }
    else if ( [keyPath isEqualToString:@"color"] )
    {
        // grab rgba values
        NSColor *color = [_currentModel.color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
        
        CGFloat r, g, b;
        r = [color redComponent] * 255;
        g = [color greenComponent] * 255;
        b = [color blueComponent] * 255;
        
        [_currentView.backgroundLayer setColor:ccc3(r, g, b)];
    }
    else if ( [keyPath isEqualToString:@"name"] )
    {
        NSString *uniqueName = [self uniqueNameFromString:_currentModel.name];
        [_selectedNode setName:uniqueName];
        [_outlineView reloadData];
    }
    else if ( [keyPath isEqualToString:@"posX"]  )
    {
        _selectedNode.position = ccp(_currentModel.posX, _selectedNode.position.y);
    }
    else if ( [keyPath isEqualToString:@"posY"] )
    {
        _selectedNode.position = ccp(_selectedNode.position.x, _currentModel.posY);
    }
    else if ( [keyPath isEqualToString:@"anchorX"] )
    {
        _selectedNode.anchorPoint = ccp(_currentModel.anchorX, _selectedNode.anchorPoint.y);
    }
    else if ( [keyPath isEqualToString:@"anchorY"] )
    {
        _selectedNode.anchorPoint = ccp(_selectedNode.anchorPoint.x, _currentModel.anchorY);
    }
    else if ( [keyPath isEqualToString:@"scaleX"] )
    {
        _selectedNode.scaleX = _currentModel.scaleX;
    }
    else if ( [keyPath isEqualToString:@"scaleY"] )
    {
        _selectedNode.scaleY = _currentModel.scaleY;
    }
    else if ( [keyPath isEqualToString:@"rotation"] )
    {
        _selectedNode.rotation = _currentModel.rotation;
    }
    else if ( [keyPath isEqualToString:@"zOrder"] )
    {
        [[_selectedNode parent] reorderChild:_selectedNode z:_currentModel.zOrder];
        [_outlineView reloadData];
    }
}

#pragma mark -
#pragma mark Child Getters

- (CCNode<CSNodeProtocol> *)nodeForEvent:(NSEvent *)event
{
    // loop through the the children in reverse since we want to find the
    // nodes with the highest z order first
    if (_currentView)
        for (CCNode *child in [[[_currentView children] getNSArray] reverseObjectEnumerator])
            if ( [child conformsToProtocol:@protocol(CSNodeProtocol)] && [child isEventInRect:event] )
                return (CCNode<CSNodeProtocol> *)child;
    
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
        _currentModel.posX = _selectedNode.position.x;
        _currentModel.posY = _selectedNode.position.y;
        _currentModel.anchorX = _selectedNode.anchorPoint.x;
        _currentModel.anchorY = _selectedNode.anchorPoint.y;
        _currentModel.scaleX = _selectedNode.scaleX;
        _currentModel.scaleY = _selectedNode.scaleY;
        _currentModel.rotation = _selectedNode.rotation;
        _currentModel.zOrder = _selectedNode.zOrder;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectSprite" object:selectedNode];
    }
}

#pragma mark -
#pragma mark Mouse Events

- (BOOL)ccMouseDown:(NSEvent *)event
{
    _willDragNode = NO;
    _willDeselectNode = NO;
    
    CCNode<CSNodeProtocol> *node = [self nodeForEvent:event];
    if (node)
    {
        // if this isn't the selected sprite, select it
        // otherwise, plan on deselecting it (unless it is moved)
        if ( ![node isSelected] )
            self.selectedNode = node;
        else
            _willDeselectNode = YES;
        
        _willDragNode = YES;
    }
    
    if (_selectedNode && ![_selectedNode isEventInRect:event])
        self.selectedNode = nil;
    
    _prevLocation = [[CCDirector sharedDirector] convertEventToGL:event];
    
    return YES;
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
    // don't deselect since we're dragging
    _willDeselectNode = NO;
    
    CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
    if (_willDragNode)
    {
        if (_selectedNode)
        {
            CGPoint delta = ccpSub(location, _prevLocation);
            CGPoint newPos = ccpAdd(_selectedNode.position, delta);
            _currentModel.posX = newPos.x;
            _currentModel.posY = newPos.y;
        }
    }
    _prevLocation = location;
    
    return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
    if (_willDeselectNode)
        self.selectedNode = nil;
    
    _prevLocation = [[CCDirector sharedDirector] convertEventToGL:event];
    
    return YES;
}

@end
