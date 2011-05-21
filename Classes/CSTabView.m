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

#import "CSTabView.h"

@implementation CSTabView

@synthesize disclosure=disclosure_;
@synthesize isSelected=isSelected_;

- (id)initWithFrame:(NSRect)frame
{
	if(self=[super initWithFrame:frame])
	{
		NSColor *onStartingColor = [NSColor colorWithDeviceRed:210/255.0f green:210/255.0f blue:210/255.0f alpha:1.0f];
		NSColor *onEndingColor = [NSColor colorWithDeviceRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f];
		onGradient_ = [[NSGradient alloc] initWithStartingColor:onStartingColor endingColor:onEndingColor];
		
		NSColor *offStartingColor = [NSColor colorWithDeviceRed:228/255.0f green:228/255.0f blue:228/255.0f alpha:1.0f];
		NSColor *offEndingColor = [NSColor colorWithDeviceRed:202/255.0f green:202/255.0f blue:202/255.0f alpha:1.0f];
		offGradient_ = [[NSGradient alloc] initWithStartingColor:offStartingColor endingColor:offEndingColor];		
		
		gradient_ = offGradient_;
		
		[self setIsSelected:NO];
	}
	
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[gradient_ drawInRect:[self bounds] angle:270];
}

- (void)setIsSelected:(BOOL)selected
{
	if(selected != isSelected_)
	{
		isSelected_ = selected;
		
		// change color depending on if it's selected or not
		if(isSelected_)
		{
			gradient_ = onGradient_;
		}
		else
		{
			gradient_ = offGradient_;
		}
		
		// redraw
		[self display];
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[self setIsSelected:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[self setIsSelected:NO];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	// select it if the point is in the view
	// deselect if it isn't
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	[self setIsSelected:NSPointInRect(point, [self bounds])];
}

- (void)dealloc
{
	gradient_ = nil;
	[onGradient_ release];
	[offGradient_ release];
}

@end
