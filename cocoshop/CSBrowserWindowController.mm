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

#import "CSBrowserWindowController.h"
#import "CSToolbarController.h"
#import "CSColorView.h"
#import "CSSprite.h"
#import "CSViewController.h"
#import "CSSceneView.h"
#import "CSLayerView.h"
#import "CSObjectController.h"
#import "CSTabContents.h"
#import "CSMacGLView.h"
#import "AppDelegate.h"
#import "CSTabContents.h"

@interface CSBrowserWindowController ()
- (void)updateEditedState:(NSNotification *)notification;
@end

@implementation CSBrowserWindowController

@synthesize view = _view;
@synthesize backgroundView = _backgroundView;
@synthesize viewController = _viewController;

- (void)awakeFromNib
{
    NSWindow *window = [self window];
    
    // set self as delegate for window
    [window setDelegate:self];
    
    [window setMovableByWindowBackground:YES];
    
    // center traffic lights
    for (NSButton *button in [[[window contentView] superview] subviews])
    {
        if ([button isKindOfClass:[NSButton class]])
        {
            NSRect frameViewBounds = [[button superview] bounds];
            NSRect frame = [button frame];
            frame.origin.y = NSHeight(frameViewBounds) - NSHeight(frame)/2 - NSHeight([[self tabStripView] frame])/2;
            [button setFrame:frame];
        }
    }
    
    _backgroundView.backgroundColor = [NSColor colorWithCalibratedRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
    [_backgroundView setNeedsDisplay:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEditedState:) name:NSUndoManagerCheckpointNotification object:nil];
}

- (BOOL)tabTearingAllowed
{
    return NO;
}

- (void)tabSelectedWithContents:(CTTabContents *)newContents previousContents:(CTTabContents *)oldContents atIndex:(NSInteger)index userGesture:(bool)wasUserGesture
{
    if ( [newContents isKindOfClass:[CSTabContents class]] )
    {
        [_viewController.controller selectLayerView:[(CSTabContents *)newContents layerView]];
        
        // update OpenGL frame
        [(CSMacGLView *)[CCDirector sharedDirector].openGLView updateForScreenReshape];
        
        // reload data
        [_viewController.outlineView reloadData];
        
        // change outline view
        [_viewController updateOutlineView];
        
        [self updateEditedState:nil];
    }
}

- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect
{
    if (window == [self window])
    {
        // doesn't do anything now - recommended by Apple since it may do something in the future
        rect.size.height = 0;
        
        // we want the sheet's top left origin to be the bottom of the toolbar
        rect.origin.y = NSMinY( [[toolbarController_ view] frame] );
    }
    
    return rect;
}

#pragma mark -

- (void)addSpritesWithFiles:(NSArray *)files safely:(BOOL)safely
{
    NSAssert(_viewController != nil, @"CSBrowserWindowController#You must set viewController");
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    for (NSURL *url in files)
    {
        NSString *filename = [url path];
        CSSprite *sprite = [CSSprite spriteWithFile:filename];
        sprite.path = filename;
        sprite.name = [_viewController.controller uniqueNameFromString:[filename lastPathComponent]];
        
        // add the node to the layer view
        if (safely)
            [_viewController.controller.currentView addChildSafely:sprite];
        else
        {
            [_viewController.controller.currentView addChild:sprite];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addedChild" object:sprite];
        }
    }
}

- (NSArray *)allowedFileTypes
{
    return [NSArray arrayWithObjects:@"png", @"gif", @"jpg", @"jpeg", @"tif", @"tiff", @"bmp", @"ccz", @"pvr", nil];
}

#pragma mark -
#pragma mark Actions

- (void)addSprite:(id)sender
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
    NSWindow *window = [self window];
    [openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if(result == NSOKButton)
        {
            NSArray *files = [openPanel URLs];
            [self addSpritesWithFiles:files safely:YES];
        }
    }];
}

- (void)newProject:(id)sender
{
    [[self window] makeKeyAndOrderFront:nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
    self.window = nil;
}

- (void)saveProjectToURL:(NSURL *)url
{
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:[_viewController.controller.currentView.children count]];
    for (CCNode<CSNodeProtocol> *child in _viewController.controller.currentView.children)
        if ( [child conformsToProtocol:@protocol(CSNodeProtocol)] )
            [children addObject:[child dictionaryRepresentation]];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:children forKey:@"children"];
    [dict writeToURL:url atomically:YES];
}

- (void)openProject:(id)sender
{
    // allowed file types
    NSArray *allowedTypes = [NSArray arrayWithObject:@"csd"];
    
    // initialize panel + set flags
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowedFileTypes:allowedTypes];
    [openPanel setAllowsOtherFileTypes:NO];
        
    // handle the open panel
    void (^openProjectBlock)(NSInteger result) = ^(NSInteger result) {
        if(result == NSOKButton)
        {
            NSArray *files = [openPanel URLs];
            for (NSURL *url in files)
            {
                // TODO: once undo/redo support is added, check if there is anything that can be undone
                // to the current project. If there isn't, that means that nothing has been done to the
                // project and we don't have to open a new tab
                if (![self window])
                    [(cocoshopAppDelegate *)[NSApp delegate] createNewWindow];
                else
                    [self.browser addBlankTabInForeground:YES];
                
                NSString *path = [url path];
                NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
                
                NSArray *children = [dict valueForKey:@"children"];
                for (NSDictionary *child in children)
                {
                    CSSprite *sprite = [CSSprite node];
                    [sprite setupFromDictionaryRepresentation:child];
                    [_viewController.controller.currentView addChildSafely:sprite];
                }
            }
        }
    };
    
    NSWindow *window = [self window];
    if (window)
        [openPanel beginSheetModalForWindow:window completionHandler:openProjectBlock];
    else
        [openPanel beginWithCompletionHandler:openProjectBlock];
}

- (void)updateEditedState:(NSNotification *)notification;
{
    BOOL edited = NO;
    for (CSTabContents *contents in [self.browser allTabContents])
    {
        CSModel *model = contents.layerView.model;
        if ([model.undoManager canUndo])
        {
            edited = YES;
            break;
        }
    }
    
    [self.window setDocumentEdited:edited];
}

@end
