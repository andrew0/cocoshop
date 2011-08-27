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

#import "cocos2d.h"
#import <ChromiumTabs/ChromiumTabs.h>

@class CSColorView;
@class CSViewController;

/**
 * CSBrowserWindowController controls the actual window for cocoshop.
 * Generally, this would be to control multiple windows, but we only
 * use one in our case (hence tab tearing being disabled). We only use
 * one window because we can't have 2 instances of cocos2d running at
 * one time without making it a separate process, which would get
 * complicated.
 */
@interface CSBrowserWindowController : CTBrowserWindowController
{
    NSView *_view;
    CSColorView *_backgroundView;
    CSViewController *_viewController;
}

@property (assign) IBOutlet NSView *view;
@property (assign) IBOutlet CSColorView *backgroundView;
@property (nonatomic, retain) CSViewController *viewController;

- (void)addSprite:(id)sender;
- (void)newProject:(id)sender;

@end
