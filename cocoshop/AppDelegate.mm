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

#import "AppDelegate.h"
#import "CSMacGLView.h"
#import "CSSceneView.h"
#import <ChromiumTabs/ChromiumTabs.h>
#import "CSBrowserWindowController.h"
#import "CSBrowser.h"
#import "CSLayerView.h"
#import "CSViewController.h"
#import "TLAnimatingOutlineView.h"
#import "CSModel.h"
#import "CSNode.h"

@interface cocoshopAppDelegate ()
@property (nonatomic, readonly) CCNode<CSNodeProtocol> *selectedNode;
@property (nonatomic, readonly) NSUndoManager *undoManager;
@end

@implementation cocoshopAppDelegate
@synthesize view=_view, glView=_glView, viewController=_viewController;
@dynamic selectedNode;
@dynamic undoManager;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[_glView openGLContext] makeCurrentContext];    
    CCDirectorMac *director = (CCDirectorMac*)[CCDirector sharedDirector];
	[director setDisplayFPS:NO];
	[director setOpenGLView:_glView];
    
    // EXPERIMENTAL stuff.
    // 'Effects' don't work correctly when autoscale is turned on.
    // Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_NoScale];
	[director runWithScene:[CSSceneView node]];
    
    [self createNewWindow];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return NO;
}

- (void)dealloc
{
	[[CCDirector sharedDirector] end];
    [_windowController release];
	[super dealloc];
}

- (void)createNewWindow
{
    if (_windowController)
    {
        // we have to close old window since we only have 1 window maximum
        [[_windowController window] close];
        [_windowController release];
    }
    
    // add the window
    NSString *windowNibPath = [CTUtil pathForResource:@"Window" ofType:@"nib"];
    _windowController = [[CSBrowserWindowController alloc] initWithWindowNibPath:windowNibPath browser:[CSBrowser browser]];
    [_view setFrame:[_windowController.view frame]];
    [[_windowController.view superview] replaceSubview:_windowController.view with:_view];
    _windowController.viewController = _viewController;
	[_windowController.window setAcceptsMouseMovedEvents:NO];
    [_windowController.browser addBlankTabInForeground:YES];
    
    // redraw window
    [[NSNotificationCenter defaultCenter] postNotificationName:NSWindowDidResizeNotification object:[_windowController window]];
    [[_windowController window] setViewsNeedDisplay:YES];
    [[_windowController window] display];
    
    // make window active
    [[_windowController window] makeKeyAndOrderFront:nil];
    
    // update the animating outline view
    [_viewController updateOutlineView];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

- (IBAction)newProject:(id)sender
{
    if ( ![_windowController window] )
        [self createNewWindow];
    else
        [_windowController.browser addBlankTabInForeground:YES];
}

- (IBAction)closeProject:(id)sender
{
    if ( [_windowController window] )
        [_windowController.browser closeTab];
}

- (IBAction)openProject:(id)sender
{
    [_windowController openProject:sender];
}

- (IBAction)saveProject:(id)sender
{
    if (!_windowController.window)
        return;
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setCanCreateDirectories:YES];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"csd"]];
    [savePanel beginSheetModalForWindow:_windowController.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton)
            [_windowController saveProjectToURL:[savePanel URL]];
    }];
}

- (NSUndoManager *)undoManager
{
    if ( ![[[CCDirector sharedDirector] runningScene] isKindOfClass:[CSSceneView class]] )
        return nil;
    
    return [[[(CSSceneView *)[[CCDirector sharedDirector] runningScene] layer] model] undoManager];
}

- (IBAction)undo:(id)sender
{
    NSThread *cocosThread = [[CCDirector sharedDirector] runningThread];
    if (!cocosThread)
        return;
    
    if ( ![[NSThread currentThread] isEqualTo:cocosThread] )
    {
        [self performSelector:@selector(undo:) onThread:cocosThread withObject:sender waitUntilDone:NO];
        return;
    }
    
    [[self undoManager] undo];
}

- (IBAction)redo:(id)sender
{
    NSThread *cocosThread = [[CCDirector sharedDirector] runningThread];
    if (!cocosThread)
        return;
    
    if ( ![[NSThread currentThread] isEqualTo:cocosThread] )
    {
        [self performSelector:@selector(redo:) onThread:cocosThread withObject:sender waitUntilDone:NO];
        return;
    }
    
    [[self undoManager] redo];
}

@end
