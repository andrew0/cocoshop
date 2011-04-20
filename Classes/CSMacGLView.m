//
//  CSMacGLView.m
//  cocoshop
//
//  Created by Stepan Generalov on 20.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CSMacGLView.h"
#import "cocoshopAppDelegate.h"
#import "CSObjectController.h"

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
			
			[controller addSpritesWithFiles: allowedFiles];
			
        }
    }
    return YES;
}

@end
