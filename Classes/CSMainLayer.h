/*
 * cocoshop
 *
 * Copyright (c) 2011 Andrew
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

#import "cocos2d.h"
#import "CSGestureEventDelegate.h"
#import "DebugLog.h"

@class CSObjectController;
@class CSSprite;

@interface CSMainLayer : CCLayer <CSGestureEventDelegate>
{
	CSObjectController *controller_;
	
	BOOL shouldToggleVisibility_;
	BOOL shouldDragSprite_;
	CGPoint prevLocation_;
	
	// delayed actions
	BOOL didAddSprite_;
	BOOL shouldUpdateAfterScreenReshape_;
	
	CGSize prevSize_;
	BOOL showBorders_;
}

/**
 * Controller to use for layer
 */
@property(nonatomic, retain) CSObjectController *controller;
/**
 * Whether it should render borderline around self or not
 */
@property(readwrite) BOOL showBorders;

#pragma mark Creation
/**
 * Allocate and init instance of layer from CSObjectController
 * @param aController CSObjectController to use
 * @returns Instance of layer
 */
+ (id)nodeWithController:(CSObjectController *)aController;
/**
 * Init instance of layer from CSObjectController
 * @param aController CSObjectController to use
 * @returns Instance of layer
 */
- (id)initWithController:(CSObjectController *)aController;

#pragma mark Loading CSD Files 
/**
 * Call loadProjectFromDictionary: on cocos2d thread
 * @param dict Dictionary to load from
 */
- (void)loadProjectFromDictionarySafely:(NSDictionary *)dict;
/**
 * Load project to layer from dictionary
 * @param dict Dictionary to load from
 */
- (void)loadProjectFromDictionary:(NSDictionary *)dict;

#pragma mark Children Getters
/**
 * Get sprite based on NSEvent from click
 * @param event Event to check for sprite
 * @returns Sprite located in event
 */
- (CSSprite *)spriteForEvent:(NSEvent *)event;

#pragma mark Notifications
/**
 * Handle adding a sprite
 * @param aNotification Notification
 */
- (void)addedSprite:(NSNotification *)aNotification;
/**
 * Updates background checkerboard if winSize is changed (can be called on any thread)
 * @param aNotification Notification
 */
- (void)updateForScreenReshapeSafely:(NSNotification *)aNotification;

@end
