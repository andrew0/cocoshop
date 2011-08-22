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

@class CSObjectController;

/**
 * This is the view that will represent a project
 */
@interface CSLayerView : CCLayer
{
    /**
     * Object controller
     */
    CSObjectController *_controller;
    
    /**
     * The background checkerboard to signify transparency
     */
    CCSprite *_checkerboard;
    
    /**
     * The scrolling offset position
     */
    CGPoint _offset;
    
    /**
     * Whether or not the screen should reshape next visit
     */
    BOOL _shouldUpdateForScreenReshape;
    
    /**
     * The size of the project workspace
     */
    CGSize _workspaceSize;
    
    /**
     * 
     */
    CCLayerColor *_backgroundLayer;
    
    /**
     * An array of children that will be added next visit
     */
    NSMutableArray *_childrenToAdd;
    
    /**
     * Whether or not we should check for new children to add next visit
     */
    BOOL _shouldAddChildren;
}

@property (nonatomic, assign) CGPoint offest;
@property (nonatomic, assign) CGSize workspaceSize;
@property (nonatomic, retain) CCLayerColor *backgroundLayer;

- (void)addChildSafely:(CCNode *)node z:(NSInteger)z tag:(NSInteger)tag;
- (void)addChildSafely:(CCNode *)node z:(NSInteger)z;
- (void)addChildSafely:(CCNode *)node;
- (id)initWithController:(CSObjectController *)controller;
- (void)updateForScreenReshapeSafely:(NSNotification *)notification;
- (void)updateForScreenReshape;

@end
