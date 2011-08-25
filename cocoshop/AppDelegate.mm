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

@implementation cocoshopAppDelegate
@synthesize view=_view, glView=_glView, viewController=_viewController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[_glView openGLContext] makeCurrentContext];    
    CCDirectorMac *director = (CCDirectorMac*)[CCDirector sharedDirector];
	[director setDisplayFPS:YES];
	[director setOpenGLView:_glView];
    
    // EXPERIMENTAL stuff.
    // 'Effects' don't work correctly when autoscale is turned on.
    // Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_NoScale];
	[director runWithScene:[CSSceneView node]];
    
    NSString *windowNibPath = [CTUtil pathForResource:@"Window" ofType:@"nib"];
    _windowController = [[CSBrowserWindowController alloc] initWithWindowNibPath:windowNibPath browser:[CSBrowser browser]];
    [_view setFrame:[_windowController.view frame]];
    [[_windowController.view superview] replaceSubview:_windowController.view with:_view];
    _windowController.viewController = _viewController;
    
    // Enable "moving" mouse event. Default no.
	[_windowController.window setAcceptsMouseMovedEvents:NO];
    
    _firstActive = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    // the first time we become active we should add a new blank tab
    if (_firstActive)
        [_windowController.browser addBlankTabInForeground:YES];
    _firstActive = NO;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (void)dealloc
{
	[[CCDirector sharedDirector] end];
    [_windowController release];
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
