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
 * CSToolbarController, a subclass of CTToolbarController, controls
 * the custom toolbar made by Chromium Tabs. This is really just
 * a special NSView that is positioned to look as if it's an
 * NSToolbar, so it doesn't have benefits like customization of the
 * icon locations. The toolbar controller handles input from toolbar
 * icons, such as adding new nodes.
 */
@interface CSToolbarController : CTToolbarController
{
    IBOutlet NSMenu *_menu;
    IBOutlet NSSegmentedControl *_addSegment;
}

- (IBAction)addSprite:(id)sender;
- (IBAction)zoom:(id)sender;
- (IBAction)undoRedo:(id)sender;

@end
