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

#import "CSBrowser.h"
#import "CSToolbarController.h"
#import "CSTabContents.h"
#import "CSModel.h"
#import "CSLayerView.h"

@implementation CSBrowser

- (CTTabContents *)createBlankTabBasedOn:(CTTabContents *)baseContents
{    
    // create our tab
    CSModel *model = [[CSModel alloc] init];
    CSLayerView *view = [[CSLayerView alloc] initWithModel:model];
    
    CTTabContents *contents = [[[CSTabContents alloc] initWithBaseTabContents:baseContents view:view] autorelease];
    
    static NSUInteger num = 1;
    contents.title = num != 1 ? [NSString stringWithFormat:@"untitled %lu", (unsigned long)num] : @"untitled";
    num++;
    
    [model release];
    [view release];
    
    return contents;
}

- (CTToolbarController *)createToolbarController
{
    NSBundle *bundle = [CTUtil bundleForResource:@"Toolbar" ofType:@"nib"];
    return [[[CSToolbarController alloc] initWithNibName:@"Toolbar"
                                                  bundle:bundle
                                                 browser:self] autorelease];
}

@end
