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

@implementation CSMacGLView

- (cocoshopAppDelegate *) CSAppDelegate
{
	return (cocoshopAppDelegate *)[[NSApplication sharedApplication ] delegate];
}

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
			CSObjectController *controller = [self CSAppDelegate].controller;
			
			NSArray *allowedFiles = [controller allowedFilesWithFiles: files];
			
			[controller addSpritesSafelyWithFiles: allowedFiles];
			
        }
    }
    return YES;
}

#pragma mark Trackpad Gestures

- (void)magnifyWithEvent:(NSEvent *)event
{
	// try to send magnification gesture to view
	CSObjectController *controller = [[self CSAppDelegate] controller];
	
	if ( [controller cocosView] && [[controller cocosView] respondsToSelector:@selector(csMagnifyWithEvent:)] )
	{
		[[controller cocosView] csMagnifyWithEvent:event];
	}
}

- (void)rotateWithEvent:(NSEvent *)event
{
	// try to send rotation gesture to view
	CSObjectController *controller = [[self CSAppDelegate] controller];
	
	if ( [controller cocosView] && [[controller cocosView] respondsToSelector:@selector(csRotateWithEvent:)] )
	{
		[[controller cocosView] csRotateWithEvent:event];
	}
}

- (void)swipeWithEvent:(NSEvent *)event
{
	// try to send swipe gesture to view
	CSObjectController *controller = [[self CSAppDelegate] controller];
	
	if ( [controller cocosView] && [[controller cocosView] respondsToSelector:@selector(csSwipeWithEvent:)] )
	{
		[[controller cocosView] csSwipeWithEvent:event];
	}
}

@end
