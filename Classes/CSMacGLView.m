/*
 * cocoshop
 *
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

#import "CSMacGLView.h"
#import "cocoshopAppDelegate.h"
#import "CSObjectController.h"
#import "CSGestureEventDelegate.h"
#import "DebugLog.h"

//TODO: Fix CCDirector convertToUI/convertToGL 
// Looks like it is broken with scrolling, zooming or else

@implementation CSMacGLView

@synthesize viewportSize, zoomFactor;

- (cocoshopAppDelegate *) appDelegate
{
	return (cocoshopAppDelegate *)[[NSApplication sharedApplication ] delegate];
}


# pragma Init / DeInit

- (void)awakeFromNib
{
	DebugLog(@"awaken, %@, window =  %@, frame = {%d, %d, %d, %d}", 
			 self, 
			 [self window], 
			 [self frame].origin.x, 
			 [self frame].origin.y, 
			 [self frame].size.width, 
			 [self frame].size.height);
	
	// register for window resizing notification
	NSWindow *window = [self window];
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(windowDidResizeNotification:) 
												 name: NSWindowDidResizeNotification 
											   object: window ];
	
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[super dealloc];
}

#pragma mark  Own Projection 

// Resizes the View for Centering the Workspace in Window
// This is needed cause it's impossible to set the position of contentNode of
// NSScrollView
- (void) windowDidResizeNotification: (NSNotification *) aNotification
{
	DebugLog(@"window did resize, viewPortSize = {%d, %d}", (int)self.viewportSize.width, (int)self.viewportSize.height);
	
	// Size is equal to self.viewportSize
	CGSize size = [[CCDirector sharedDirector] winSizeInPixels];
	
	// Get the Real Size of Workspace in Pixels
	float widthAspect = size.width * self.zoomFactor;
	float heightAspect = size.height * self.zoomFactor;
	
	// Resize self frame if Real Size of Workspace is less than available space in the Window
	CGSize superViewFrameSize = [[self superview] frame].size;
	
	CGSize frameSize = [self frame].size;
	
	if ( widthAspect < superViewFrameSize.width )
		frameSize.width = superViewFrameSize.width;
	else 
		frameSize.width = widthAspect;
		
	
	if ( heightAspect < superViewFrameSize.height )
		frameSize.height = superViewFrameSize.height;
	else 
		frameSize.height = heightAspect;
	
	[self setFrameSize: frameSize ];
		
}

// works just like kCCDirectorProjection2D, but uses visibleRect instead of only size of the window
- (void) updateProjection
{	
	CGSize size = [[CCDirector sharedDirector] winSizeInPixels];
	
	CGRect rect = NSRectToCGRect([self visibleRect]);
	CGPoint offset = CGPointMake( - rect.origin.x, - rect.origin.y ) ;
	float widthAspect = size.width * self.zoomFactor;
	float heightAspect = size.height * self.zoomFactor;
	
	//normal center positioning doesnt work for CSMacGLView - simulate it 
	// with projection change	
	CGSize superViewFrameSize = [[self superview] frame].size;
	
	if ( widthAspect < superViewFrameSize.width )
		offset.x = ( superViewFrameSize.width - widthAspect ) / 2.0f;
		
	if ( heightAspect < superViewFrameSize.height )
		offset.y = ( superViewFrameSize.height - heightAspect ) / 2.0f;
	
	//case kCCDirectorProjection2D:
	glViewport(offset.x, offset.y, widthAspect, heightAspect);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	ccglOrtho(0, size.width, 0, size.height, -1024, 1024);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	//TODO: enable 3d projection choice
}

// reshape that uses self.viewportSize instead of self bounds
- (void) reshape
{
	// Set viewport equal to frame size first time, when Cocoshop is started
	static BOOL firstReshape = YES;
	if (firstReshape)
	{
		self.zoomFactor = 1.0f;
		self.viewportSize = [self frame].size;
	}
	firstReshape = NO;
	
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously when resizing
	CGLLockContext([[self openGLContext] CGLContextObj]);
	
	CCDirector *director = [CCDirector sharedDirector];
	[director reshapeProjection: self.viewportSize ];
	
	// avoid flicker
	[director drawScene];
	//	[self setNeedsDisplay:YES];
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}


#pragma mark Drag & Drop Support

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{	
	NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) 
	{
        if (sourceDragMask & NSDragOperationLink) 
		{
            return NSDragOperationLink;
		}
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender 
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		
        if (sourceDragMask & NSDragOperationLink) 
		{			
			CSObjectController *controller = [self appDelegate].controller;
			
			NSArray *allowedFiles = [controller allowedFilesWithFiles: files];
			
			[controller addSpritesWithFilesSafely: allowedFiles];
			
        }
    }
    return YES;
}

#pragma mark Trackpad Gestures

- (void)magnifyWithEvent:(NSEvent *)event
{
	// try to send magnification gesture to view
	CSObjectController *controller = [[self appDelegate] controller];
	
	if ( [controller cocosView] && [[controller cocosView] respondsToSelector:@selector(csMagnifyWithEvent:)] )
	{
		[[controller cocosView] csMagnifyWithEvent:event];
	}
}

- (void)rotateWithEvent:(NSEvent *)event
{
	// try to send rotation gesture to view
	CSObjectController *controller = [[self appDelegate] controller];
	
	if ( [controller cocosView] && [[controller cocosView] respondsToSelector:@selector(csRotateWithEvent:)] )
	{
		[[controller cocosView] csRotateWithEvent:event];
	}
}

- (void)swipeWithEvent:(NSEvent *)event
{
	// try to send swipe gesture to view
	CSObjectController *controller = [[self appDelegate] controller];
	
	if ( [controller cocosView] && [[controller cocosView] respondsToSelector:@selector(csSwipeWithEvent:)] )
	{
		[[controller cocosView] csSwipeWithEvent:event];
	}
}

@end
