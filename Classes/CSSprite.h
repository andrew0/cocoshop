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

#define kCSSpriteStrokeSize 1

@class CSObjectController;

@interface CSSprite : CCSprite
{
	CCSprite *sprite_;
	CCLayerColor *fill_;
	CCNode *border_;
	CCSprite *anchor_;
	CCLabelBMFont *positionLabel_;
	
	/**
	 * The key that is used for the dictionary
	 */
	NSString *key_;
	
	/**
	 * The filename
	 */
	NSString *filename_;
	
	/**
	 * The name to use for the variable when the code is generated
	 */
	NSString *name_;
	BOOL locked_;
}

@property(nonatomic, readonly) CCNode *border;
@property(nonatomic, copy) NSString *key;
@property(nonatomic, copy) NSString *filename;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) BOOL locked;

@end
