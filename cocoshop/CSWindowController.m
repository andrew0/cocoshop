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

#import "CSWindowController.h"
#import <PSMTabBarControl/PSMTabBarControl.h>
#import "CSObjectController.h"
#import "CSModel.h"
#import "CSLayerView.h"
#import "CSSceneView.h"
#import "CSMacGLView.h"
#import "TLAnimatingOutlineView.h"
#import "TLCollapsibleView.h"
#import "TLDisclosureBar.h"
#import "CSSprite.h"

// colors/gradients defined up here - makes code look cleaner
#define ACTIVE_GRADIENT [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.86f alpha:255] endingColor:[NSColor colorWithCalibratedWhite:0.72f alpha:255]] autorelease]
#define INACTIVE_GRADIENT [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95f alpha:255] endingColor:[NSColor colorWithCalibratedWhite:0.85f alpha:255]] autorelease]
#define CLICKED_GRADIENT [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.78f alpha:255] endingColor:[NSColor colorWithCalibratedWhite:0.64f alpha:255]] autorelease]
#define BORDER_COLOR [NSColor colorWithCalibratedWhite:0.66f alpha:255.0f]
#define CONFIGURE_VIEW(__X__) do {\
    [__X__ setAutoresizingMask:NSViewNotSizable];\
    [__X__.disclosureBar.labelField setFrameOrigin:NSMakePoint(20.0f, [__X__.disclosureBar.labelField frame].origin.y)];\
    __X__.disclosureBar.drawsHighlight = NO;\
    __X__.disclosureBar.activeFillGradient = ACTIVE_GRADIENT;\
    __X__.disclosureBar.inactiveFillGradient = INACTIVE_GRADIENT;\
    __X__.disclosureBar.clickedFillGradient = CLICKED_GRADIENT;\
    __X__.disclosureBar.borderColor = BORDER_COLOR;\
} while (0)


#pragma mark NSClipView

/**
 * This is so that the clip view has a flipped coordinate system
 * i.e. the origin is top left
 */
@implementation NSClipView (Flipped)
- (BOOL)isFlipped
{
    return YES;
}
@end

#pragma mark -
#pragma mark Window Controller

@interface CSWindowController ()
- (void)addNewTab:(id)sender;
- (void)reloadData:(NSNotification *)notification;
- (void)didSelectSprite:(NSNotification *)notification;
@end

@implementation CSWindowController

@synthesize controller = _controller;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        // initialize tab view
        // note: this is never added to view
        _tabView = [[NSTabView alloc] initWithFrame:NSZeroRect];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"addedChild" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectSprite:) name:@"didSelectSprite" object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [_animatingOutlineView release];
    [_tabView release];
    [super dealloc];
}

- (void)awakeFromNib
{
    // add tab view to tab bar
    [_tabView setDelegate:_tabBar];
    [_tabBar setTabView:_tabView];
    
    // set tab bar info
    [_tabBar setStyleNamed:@"Unified"];
    [_tabBar setCanCloseOnlyTab:NO];
    [_tabBar setDisableTabClose:NO];
    [_tabBar setHideForSingleTab:NO];
    [_tabBar setShowAddTabButton:YES];
    [_tabBar setUseOverflowMenu:YES];
    [_tabBar setAutomaticallyAnimates:NO];
    [_tabBar setAllowsScrubbing:NO];
    [_tabBar setCellMinWidth:100];
    [_tabBar setCellMaxWidth:280];
    [_tabBar setCellOptimumWidth:130];
    
    // set action for adding a new tab
    [[_tabBar addTabButton] setTarget:self];
    [[_tabBar addTabButton] setAction:@selector(addNewTab:)];
    
    // add TLAnimatingOutlineView
    NSSize contentSize = [_rightScrollView contentSize];
    _animatingOutlineView = [[TLAnimatingOutlineView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
    [_animatingOutlineView setDelegate:self];
    [_animatingOutlineView setAutoresizingMask:NSViewWidthSizable];
    [_rightScrollView setDocumentView:_animatingOutlineView];
    
    [self updateOutlineView];
}

- (void)updateOutlineView
{
    [_animatingOutlineView setSubviews:[NSArray array]];
    
    if (_controller.selectedNode)
    {
        if ( [_controller.selectedNode conformsToProtocol:@protocol(CSNodeProtocol)] )
        {
            TLCollapsibleView *general = [_animatingOutlineView addView:_generalInfo withImage:nil label:@"General Info" expanded:YES];
            CONFIGURE_VIEW(general);
            
            TLCollapsibleView *node = [_animatingOutlineView addView:_nodeInfo withImage:nil label:@"CCNode Info" expanded:YES];
            CONFIGURE_VIEW(node);
        }
        
        if ( [_controller.selectedNode isKindOfClass:[CSSprite class]] )
        {
            TLCollapsibleView *sprite = [_animatingOutlineView addView:_spriteInfo withImage:nil label:@"CCSprite Info" expanded:YES];
            CONFIGURE_VIEW(sprite);
        }
    }
    else
    {
        TLCollapsibleView *background = [_animatingOutlineView addView:_backgroundInfo withImage:nil label:@"Background Info" expanded:YES];
        CONFIGURE_VIEW(background);
        background.disclosureBar.borderSidesMask = TLMinYEdge;
    }
}

- (void)addNewTab:(id)sender
{
    // create a dictionary of the model and view as an identifier
    CSModel *model = [[CSModel alloc] init];
    CSLayerView *view = [[CSLayerView alloc] initWithController:_controller];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          model, @"model",
                          view, @"view",
                          nil];
    [model release];
    [view release];
    
    // create a new tab
    NSTabViewItem *newItem = [[[NSTabViewItem alloc] init] autorelease];
    [newItem setIdentifier:dict];
    [newItem setLabel:@"Untitled"];
    
    // add to tab view and select
    [_tabView addTabViewItem:newItem];
    [_tabView selectTabViewItem:newItem];
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

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    if (item && [item isKindOfClass:[CCNode class]] && [item conformsToProtocol:@protocol(CSNodeProtocol)])
        _controller.selectedNode = (CCNode<CSNodeProtocol> *)item;
    
    return YES;
}

#pragma mark -
#pragma mark Tab Bar Delegation

- (BOOL)tabView:(NSTabView*)aTabView shouldDragTabViewItem:(NSTabViewItem *)tabViewItem fromTabBar:(PSMTabBarControl *)tabBarControl
{
    // allow drag/dropping tabs if there are >1 tabs
	return ([aTabView numberOfTabViewItems] > 1);
}

- (BOOL)tabView:(NSTabView*)aTabView shouldDropTabViewItem:(NSTabViewItem *)tabViewItem inTabBar:(PSMTabBarControl *)tabBarControl
{
    // allow drag/dropping tabs if there are >1 tabs
	return ([aTabView numberOfTabViewItems] > 1);
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ( [[tabViewItem identifier] isKindOfClass:[NSDictionary class]] )
        [_controller selectDictionary:(NSDictionary *)[tabViewItem identifier]];
    
    // update OpenGL frame
    [(CSMacGLView *)[CCDirector sharedDirector].openGLView updateForScreenReshape];
    
    // change title
    [[self window] setTitle:[NSString stringWithFormat:@"cocoshop - %@", [tabViewItem label]]];
    
    // reload data
    [_outlineView reloadData];
}

#pragma mark -
#pragma mark Notifications

- (void)reloadData:(NSNotification *)notification
{
    [_outlineView reloadData];
}

- (void)didSelectSprite:(NSNotification *)notification
{
    [self updateOutlineView];
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

#pragma mark -
#pragma mark IBActions

- (IBAction)closeProject:(id)sender
{
    // remove selected item
    NSTabViewItem *item = [_tabView selectedTabViewItem];
    if (item)
        [_tabView removeTabViewItem:item];
    
    // remove layer if there are no windows left and set controller selection
    if ( [_tabView numberOfTabViewItems] < 1 )
    {
        if ( [[CCDirector sharedDirector].runningScene isKindOfClass:[CSSceneView class]] )
        {
            CSSceneView *scene = (CSSceneView *)[CCDirector sharedDirector].runningScene;
            scene.layer = nil;
        }
        
        [_controller selectDictionary:nil];
        
        // change title
        [[self window] setTitle:@"cocoshop"];
    }
    
    // update OpenGL frame
    [(CSMacGLView *)[CCDirector sharedDirector].openGLView updateForScreenReshape];
}

- (IBAction)newProject:(id)sender
{
    [self addNewTab:nil];
}

- (IBAction)addNode:(id)sender
{
//    [_outlineView ];
    NSBeep();
}

- (IBAction)addLayer:(id)sender
{
    NSBeep();
}

- (IBAction)addScene:(id)sender
{
    NSBeep();
}

- (IBAction)addSprite:(id)sender
{
    // return if there is no layer
    if ( [[CCDirector sharedDirector].runningScene isKindOfClass:[CSSceneView class]] )
    {
        CSSceneView *scene = (CSSceneView *)[CCDirector sharedDirector].runningScene;
        if (!scene.layer)
        {
            NSBeep();
            return;
        }
    }
    
    // allowed file types
    NSArray *allowedTypes = [self allowedFileTypes];
    
    // initialize panel + set flags
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowedFileTypes:allowedTypes];
    [openPanel setAllowsOtherFileTypes:NO];
    
    // handle the open panel
    [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if(result == NSOKButton)
        {
            NSArray *files = [openPanel URLs];
            [self addSpritesWithFiles:files safely:YES];
        }
    }];
}

- (IBAction)addMenu:(id)sender
{
    NSBeep();
}

- (IBAction)addMenuItem:(id)sender
{
    NSBeep();
}

- (IBAction)addLabelBMFont:(id)sender
{
    NSBeep();
}

@end
