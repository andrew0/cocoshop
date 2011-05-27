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

#import "CSSideViewController.h"
#import "CSTabView.h"

@implementation CSSideViewController

@synthesize generalPropertiesTab=generalPropertiesTab_;
@synthesize generalPropertiesView=generalPropertiesView_;
@synthesize nodePropertiesTab=nodePropertiesTab_;
@synthesize nodePropertiesView=nodePropertiesView_;
@synthesize spritePropertiesTab=spritePropertiesTab_;
@synthesize spritePropertiesView=spritePropertiesView_;
@synthesize backgroundPropertiesTab=backgroundPropertiesTab_;
@synthesize backgroundPropertiesView=backgroundPropertiesView_;

- (void)awakeFromNib
{
	[self alignItems:
	 [NSArray arrayWithObjects:generalPropertiesTab_, generalPropertiesView_, nil],
	 [NSArray arrayWithObjects:nodePropertiesTab_, nodePropertiesView_, nil],
	 [NSArray arrayWithObjects:spritePropertiesTab_, spritePropertiesView_, nil],
	 nil];
}

// array should have tab at index 0, view at index 1
- (void)alignItems:(NSArray *)item, ...
{
	// clear current views
	[rightSideView_ setSubviews:[NSArray array]];
	
	// keep track of overall height, we'll need to resize the side view
	CGFloat totalHeight = 0;
	
	// get the tab and view from first item
	NSView *tab = [item objectAtIndex:0];
	NSView *view = [item objectAtIndex:1];
	
	// find the rect of the scroll view document
	NSRect r = [rightSideView_ frame];
	
	// calculate the tab and view positions
	[tab setFrameOrigin:NSMakePoint(0, NSHeight(r)-NSHeight([tab frame]))];
	[view setFrameOrigin:NSMakePoint(0, NSHeight(r)-NSHeight([tab frame])-NSHeight([view frame]))];
	
	totalHeight += NSHeight([tab frame]) + NSHeight([view frame]);
	
	// add the first tab and view
	[rightSideView_ addSubview:tab];
	[rightSideView_ addSubview:view];
	
	// loop through rest of items
	va_list args;
	va_start(args, item);
	
	// i is the current array in the loop
	NSArray *i;
	// keep track of our last tab so we can find its position
	NSView *lastTab = tab;
	// keep track of our last view so we can find its position
	NSView *lastView = view;
	do
	{
		i = va_arg(args, NSArray*);
		
		if(i != nil)
		{
			NSAssert([i count] == 2, @"Invalid array passed to alignItems:");
			
			NSView *tab = [i objectAtIndex:0];
			NSView *view = [i objectAtIndex:1];
			
			[tab setFrameOrigin:NSMakePoint(0, [lastView frame].origin.y-NSHeight( [tab frame] ))];
			[view setFrameOrigin:NSMakePoint(0, [tab frame].origin.y-NSHeight( [view frame] ))];
			
			totalHeight += NSHeight([tab frame]) + NSHeight([view frame]);
			
			// and tab + view
			[rightSideView_ addSubview:tab];
			[rightSideView_ addSubview:view];
			
			// set last tab and last view
			lastTab = tab;
			lastView = view;
		}
	} while(i != nil);
	
	va_end(args);
	
	NSRect frame = [rightSideView_ frame];
	[rightSideView_ setFrameSize:NSMakeSize(NSWidth(frame), totalHeight)];
}

@end