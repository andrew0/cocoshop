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

@interface CSViewController ()
- (void)reloadData:(NSNotification *)notification;
- (void)didSelectSprite:(NSNotification *)notification;
@end

@implementation CSViewController

@synthesize controller = _controller;
@synthesize outlineView = _outlineView;

- (void)dealloc
{
    [_animatingOutlineView release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"addedChild" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectSprite:) name:@"didSelectSprite" object:nil];
    
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
    
    // enable all of the text fields in case they were disabled and never reenabled
    for (TLCollapsibleView *view in [_animatingOutlineView subviews])
        for (NSTextField *text in [[view detailView] subviews])
            [text setEnabled:YES];
}

- (NSDictionary *)addNewTab:(id)sender
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
    
    return dict;
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

//- (IBAction)closeProject:(id)sender
//{
//    // remove selected item
//    NSTabViewItem *item = [_tabView selectedTabViewItem];
//    if (item)
//        [_tabView removeTabViewItem:item];
//    
//    // remove layer if there are no windows left and set controller selection
//    if ( [_tabView numberOfTabViewItems] < 1 )
//    {
//        if ( [[CCDirector sharedDirector].runningScene isKindOfClass:[CSSceneView class]] )
//        {
//            CSSceneView *scene = (CSSceneView *)[CCDirector sharedDirector].runningScene;
//            scene.layer = nil;
//        }
//        
//        [_controller selectDictionary:nil];
//        
//        // change title
//        NSWindow *window = [[[CCDirector sharedDirector] openGLView] window];
//        [window setTitle:@"cocoshop"];
//    }
//    
//    // update OpenGL frame
//    [(CSMacGLView *)[CCDirector sharedDirector].openGLView updateForScreenReshape];
//}
//
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
    NSWindow *window = [[[CCDirector sharedDirector] openGLView] window];
    [openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
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
