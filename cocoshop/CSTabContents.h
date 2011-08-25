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

#import <ChromiumTabs/ChromiumTabs.h>

/**
 * Cocoshop is a bit different from a normal application with tabs.
 * Generally, you would have a separate NSView for each tab, which
 * is what CTTabContents is supposed to contain. However, we don't
 * actually draw the contents of the tabs. Instead, whenever we make
 * a tab, we add a value called "dictionary" (or _dictionary), which
 * contains a model and a view. When a different tab is selected,
 * CSBrowserWindowController observes the change and tells the
 * view controller to change the current scene view to the new one.
 */
@interface CSTabContents : CTTabContents
{
    NSDictionary *_dictionary;
}

@property (nonatomic, retain) NSDictionary *dictionary;

- (id)initWithBaseTabContents:(CTTabContents *)baseContents dictionary:(NSDictionary *)dict;

@end
