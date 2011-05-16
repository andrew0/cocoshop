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

#import "CSMacGLView.h"
#import "cocoshopAppDelegate.h"
#import "CSObjectController.h"
#import "CSGestureEventDelegate.h"
#import "DebugLog.h"

@implementation CSMacGLView

@synthesize workspaceSize, zoomFactor, zoomSpeed, zoomFactorMax, zoomFactorMin;

@dynamic projection;

- (void) setProjection:(ccDirectorProjection) newProjection
{
	projection_ = newProjection;
	[self updateProjection];
}

- (ccDirectorProjection) projection
{
	return projection_;
}

- (cocoshopAppDelegate *) appDelegate
{
	return (cocoshopAppDelegate *)[[NSApplication sharedApplication ] delegate];
}


# pragma Init / DeInit

- (void)awakeFromNib
{	
	// register for window resizing notification
	NSWindow *window = [self window];
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(windowDidResizeNotification:) 
												 name: NSWindowDidResizeNotification 
											   object: window ];
	
	// Setup Zoom Settings
	self.zoomSpeed = 0.01f;
	self.zoomFactorMin = 0.1f;
	self.zoomFactorMax = 3.0f;	
	
	// Setup Projection
	projection_ = kCCDirectorProjection2D;
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
	// Size is equal to self.workspaceSize
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

// This methods calculates offset (rect.origin) and width & height aspect (rect.size) 
// of the viewport. 
// Normal center positioning doesnt work for CSMacGLView - we will simulate it with
// projection offset change & view resize. 
- (CGRect) viewportRect
{
	CGSize size = [[CCDirector sharedDirector] winSizeInPixels];
	
	CGRect rect = NSRectToCGRect([self visibleRect]);
	CGPoint offset = CGPointMake( - rect.origin.x, - rect.origin.y );
	float widthAspect = size.width * self.zoomFactor;
	float heightAspect = size.height * self.zoomFactor;
	
	CGSize superViewFrameSize = [[self superview] frame].size;
	
	if ( widthAspect < superViewFrameSize.width )
		offset.x = ( superViewFrameSize.width - widthAspect ) / 2.0f;
	
	if ( heightAspect < superViewFrameSize.height )
		offset.y = ( superViewFrameSize.height - heightAspect ) / 2.0f;
	
	return CGRectMake( offset.x , offset.y, widthAspect, heightAspect );
}

// works just like kCCDirectorProjection2D, but uses visibleRect instead of only size of the window
- (void) updateProjection
{	
	CGRect offsetAspectRect = [self viewportRect];
	CGPoint offset = offsetAspectRect.origin;
	CGSize aspect = offsetAspectRect.size;	
	
	switch (projection_) {
		case kCCDirectorProjection2D:
			glViewport(offset.x, offset.y, aspect.width, aspect.height);
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			ccglOrtho(0, self.workspaceSize.width, 0, self.workspaceSize.height, -1024, 1024);
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			break;
			
		case kCCDirectorProjection3D:
			glViewport(offset.x, offset.y, aspect.width, aspect.height);
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			gluPerspective(60, (GLfloat)aspect.width/aspect.height, 0.1f, 1500.0f);
			
			glMatrixMode(GL_MODELVIEW);	
			glLoadIdentity();
			
			float eyeZ = [[CCDirector sharedDirector] getZEye];
			
			gluLookAt( self.workspaceSize.width/2, self.workspaceSize.height/2, eyeZ,
					  self.workspaceSize.width/2, self.workspaceSize.height/2, 0,
					  0.0f, 1.0f, 0.0f);			
			break;
			
		default:
			DebugLog(@"Unsupported Projection");
			break;
	}
}

// reshape that uses self.workspaceSize instead of self bounds
- (void) reshape
{
	// Set viewport equal to frame size first time, when Cocoshop is started
	static BOOL firstReshape = YES;
	if (firstReshape)
	{
		self.zoomFactor = 1.0f;
		self.workspaceSize = [self frame].size;
	}
	firstReshape = NO;
	
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously when resizing
	CGLLockContext([[self openGLContext] CGLContextObj]);
	
	CCDirector *director = [CCDirector sharedDirector];
	[director reshapeProjection: self.workspaceSize ];
	
	// avoid flicker
	[director drawScene];
	//	[self setNeedsDisplay:YES];
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

// fixes cordinate conversion when zooming, or scrolling or centering is applied
- (NSPoint)convertPoint:(NSPoint)aPoint fromView:(NSView *)aView
{
	NSPoint p = [super convertPoint: aPoint fromView: aView];
	
	// Apply offset only when Centered 
	CGPoint offset = [self viewportRect].origin;
	offset.x = MAX(offset.x, 0);
	offset.y = MAX(offset.y, 0);
	p = ccpSub(p, offset);
	
	// Apply Zooming
	p.x /= self.zoomFactor;
	p.y /= self.zoomFactor;
	
	return p;
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

#pragma mark Zoom

- (void) resetZoom
{
	self.zoomFactor = 1.0f;
	
	// Update Window
	[[NSNotificationCenter defaultCenter] postNotificationName: NSWindowDidResizeNotification object:[self window]];
	[self reshape]; //< without this line there will be no update with zoomFactor < 1
}

- (BOOL) zoomWithEvent:(NSEvent *)theEvent 
{	
	if ( [theEvent modifierFlags] & NSCommandKeyMask )
	{
		self.zoomFactor -= [theEvent deltaY] * self.zoomSpeed;
		
		self.zoomFactor = MAX(self.zoomFactorMin, MIN(self.zoomFactor, self.zoomFactorMax));		
		
		// Update Window Size, to Show Scrollers of NSScrollView
		// (this is the best implementation, that i found within a hour)
		[[NSNotificationCenter defaultCenter] postNotificationName: NSWindowDidResizeNotification object:[self window]];
		[self reshape]; //< without this line there will be no update with zoomFactor < 1, and i DUNNO Y		
		
		return YES;
	}
	
	return NO;
}

#pragma mark Trackpad Gestures & Mouse Support

-(void) scrollWheel:(NSEvent *)theEvent 
{
	// Zoom
	if ([self zoomWithEvent: theEvent])
		return;
	
	// Or Scroll
	[[self enclosingScrollView] scrollWheel: theEvent];	
	[super scrollWheel: theEvent];
}

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
