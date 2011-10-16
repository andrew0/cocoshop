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

#import <Cocoa/Cocoa.h>
#import "TLAnimatingOutlineView.h"
#import "cocos2d.h"

@class CSObjectController;
@class PSMTabBarControl;

/**
 * CSViewController controls an NSView, which contains the OpenGL
 * view and the editing controls (sidebars).
 */
@interface CSViewController : NSViewController <TLAnimatingOutlineViewDelegate, NSOutlineViewDelegate>
{
    CSObjectController *_controller;
    TLAnimatingOutlineView *_animatingOutlineView;
        
    NSOutlineView *_outlineView;
    IBOutlet NSScrollView *_rightScrollView;
    IBOutlet NSView *_nodeInfo;
    IBOutlet NSView *_spriteInfo;
    IBOutlet NSView *_backgroundInfo;
    IBOutlet NSView *_generalInfo;
}

@property (assign) IBOutlet CSObjectController *controller;
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, retain) TLAnimatingOutlineView *animatingOutlineView;

/**
 * Updates the TLOutlineView (i.e. it will add the appropriate views to it)
 */
- (void)updateOutlineView;
- (void)addSpritesWithFiles:(NSArray *)files safely:(BOOL)safely;
- (NSArray *)allowedFileTypes;

@end
