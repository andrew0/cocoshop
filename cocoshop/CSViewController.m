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

#import "CSViewController.h"
#import "CSObjectController.h"
#import "CSModel.h"
#import "CSLayerView.h"
#import "CSSceneView.h"
#import "CSMacGLView.h"
#import "TLAnimatingOutlineView.h"
#import "TLCollapsibleView.h"
#import "TLDisclosureBar.h"
#import "CSSprite.h"

@interface CSViewController ()
- (void)reloadData:(NSNotification *)notification;
- (void)didSelectNode:(NSNotification *)notification;
- (void)configureView:(TLCollapsibleView *)view;
@end

@implementation CSViewController

@synthesize controller = _controller;
@synthesize outlineView = _outlineView;
@synthesize animatingOutlineView = _animatingOutlineView;

- (void)dealloc
{
    self.animatingOutlineView = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"addedChild" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"updatedChild" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectNode:) name:@"didSelectNode" object:nil];
    
    // add TLAnimatingOutlineView
    NSSize contentSize = [_rightScrollView contentSize];
    self.animatingOutlineView = [[[TLAnimatingOutlineView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)] autorelease];
    [_animatingOutlineView setDelegate:self];
    [_animatingOutlineView setAutoresizingMask:NSViewWidthSizable];
    [_rightScrollView setDocumentView:_animatingOutlineView];
    [self updateOutlineView];
}

- (void)configureView:(TLCollapsibleView *)view
{
    [view setAutoresizingMask:NSViewNotSizable];
    [view.disclosureBar.labelField setFrameOrigin:NSMakePoint(20.0f, [view.disclosureBar.labelField frame].origin.y)];
    view.disclosureBar.drawsHighlight = NO;
    view.disclosureBar.activeFillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.86f alpha:255] endingColor:[NSColor colorWithCalibratedWhite:0.72f alpha:255]] autorelease];
    view.disclosureBar.inactiveFillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95f alpha:255] endingColor:[NSColor colorWithCalibratedWhite:0.85f alpha:255]] autorelease];
    view.disclosureBar.clickedFillGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.78f alpha:255] endingColor:[NSColor colorWithCalibratedWhite:0.64f alpha:255]] autorelease];
    view.disclosureBar.borderColor = [NSColor colorWithCalibratedWhite:0.66f alpha:255.0f];
}

- (void)updateOutlineView
{
    // NSViews have to be removed/modified/created on main thread
    if ( ![NSThread isMainThread] )
    {
        [self performSelectorOnMainThread:@selector(updateOutlineView) withObject:nil waitUntilDone:NO];
        return;
    }
    
    NSMutableArray *subviews = [_animatingOutlineView mutableArrayValueForKey:@"subviews"];
    
    @synchronized (subviews)
    {
        // remove old views
        for (TLCollapsibleView *view in subviews)
            [_animatingOutlineView removeItem:view];
        
        if (_controller.currentModel.selectedNode)
        {
            if ( [_controller.currentModel.selectedNode conformsToProtocol:@protocol(CSNodeProtocol)] )
            {
                TLCollapsibleView *general = [_animatingOutlineView addView:_generalInfo withImage:nil label:@"General Info" expanded:YES];
                [self configureView:general];
                
                TLCollapsibleView *node = [_animatingOutlineView addView:_nodeInfo withImage:nil label:@"CCNode Info" expanded:YES];
                [self configureView:node];
            }
            
            if ( [_controller.currentModel.selectedNode isKindOfClass:[CSSprite class]] )
            {
                TLCollapsibleView *sprite = [_animatingOutlineView addView:_spriteInfo withImage:nil label:@"CCSprite Info" expanded:YES];
                [self configureView:sprite];
            }
        }
        else
        {
            TLCollapsibleView *background = [_animatingOutlineView addView:_backgroundInfo withImage:nil label:@"Background Info" expanded:YES];
            [self configureView:background];
            background.disclosureBar.borderSidesMask = TLMinYEdge;
        }
        
        // enable all of the text fields in case they were disabled and never reenabled
        for (TLCollapsibleView *view in [_animatingOutlineView subviews])
            for (NSTextField *text in [[view detailView] subviews])
                [text setEnabled:YES];
    }
}

#pragma mark -
#pragma mark TLOutlineView Delegation

- (CGFloat)rowSeparation
{
	return 0.0f;
}

- (BOOL)outlineView:(TLAnimatingOutlineView *)outlineView shouldExpandItem:(TLCollapsibleView *)item
{
    // when expanding/collapsing, if there is a focus ring around a text field
    // it doesnt go away, so we just disable it temporarily
    for (NSTextField *view in item.detailView.subviews)
        [view setEnabled:YES];
    
    return YES;
}

- (BOOL)outlineView:(TLAnimatingOutlineView *)outlineView shouldCollapseItem:(TLCollapsibleView *)item
{
    // when expanding/collapsing, if there is a focus ring around a text field
    // it doesnt go away, so we just disable it temporarily
    for (NSTextField *view in item.detailView.subviews)
        [view setEnabled:NO];
    
    return YES;
}

#pragma mark -
#pragma mark NSOutlineView Delegation

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    id item = [_outlineView itemAtRow:[_outlineView selectedRow]];
    if (item && [item isKindOfClass:[CCNode class]] && [item conformsToProtocol:@protocol(CSNodeProtocol)])
        _controller.currentModel.selectedNode = (CCNode<CSNodeProtocol> *)item;
}

#pragma mark -
#pragma mark Notifications

- (void)reloadData:(NSNotification *)notification
{
    if ( ![NSThread isMainThread] )
    {
        [self performSelectorOnMainThread:@selector(reloadData:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    [_outlineView reloadData];
    [self didSelectNode:nil];
}

- (void)didSelectNode:(NSNotification *)notification
{
    // NSViews have to be removed/modified/created on main thread
    // this gets called same thread that notification is made in,
    // which is in the cocos2d thread. we want to run this on main
    // thread
    if ( ![NSThread isMainThread] )
    {
        [self performSelectorOnMainThread:@selector(didSelectNode:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    [self updateOutlineView];
    CCNode<CSNodeProtocol> *item = [_controller.currentModel selectedNode];
    if (item)
        [_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_outlineView rowForItem:item]] byExtendingSelection:NO];
    else
        [_outlineView deselectAll:nil];
}

#pragma mark -
#pragma mark Sprites

- (void)addSpritesWithFiles:(NSArray *)files safely:(BOOL)safely
{
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    for (NSURL *url in files)
    {
        NSString *filename = [url path];
        CSSprite *sprite = [CSSprite spriteWithFile:filename];
        [sprite setName:[_controller uniqueNameFromString:[filename lastPathComponent]]];
        
        // add the node to the layer view
        if (safely)
            [_controller.currentView addChildSafely:sprite];
        else
        {
            [_controller.currentView addChild:sprite];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addedChild" object:sprite];
        }
    }
}

- (NSArray *)allowedFileTypes
{
    return [NSArray arrayWithObjects:@"png", @"gif", @"jpg", @"jpeg", @"tif", @"tiff", @"bmp", @"ccz", @"pvr", nil];
}

@end
