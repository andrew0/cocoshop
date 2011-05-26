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

/*
	CSSprite is a CCSprite subclass, that is used in cocoshop to display sprites
 on the workspace.
	It can be selected - in that state it is highlighted with a rectangle around
 its contents, shows anchorPoint and position.
	Also it supports NSCoding and provides methods to load & save self to/from 
 NSDictionary.
	TODO: Refactor it to the CSNode, for support of other CCNodes in Cocoshop.
 */
@interface CSSprite : CCSprite <NSCoding,NSPasteboardReading, NSPasteboardWriting>
{
	BOOL isSelected_;
	
	CCLayerColor *fill_;
	CCSprite *anchor_;
	CCLabelBMFont *positionLabel_;
	
	NSString *filename_;
	NSString *name_;
	BOOL locked_;
	
	BOOL willUpdatePositionLabel_;
}

@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic, copy) NSString *filename;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) BOOL locked;

// changes position and text of positionLabel
// must be called on Cocos2D thread
- (void)updatePositionLabel;

// marks that updatePositionLabel must be called once at next visit
- (void)updatePositionLabelSafely;

#pragma mark NSCoding Support

/* 
    Creates NSDictionary that contains info about node.
 Currently it supports only CCSprite & saves its properties into dictionary root
 But it should be better to have this format:
 
 Dictionary Root
 |
 + "ClassName" => "CCSprite"
 |
 + "CCNode" => NSDictionary
               |
               + "position" => NSStringFromCGPoint
               |
               + "anchor point" => NSStringFromCGPoint
               |
               + "contentSize" => NSStringFromCGRect
               |
               ...
 |
 + "CCSprite" => NSDictionary
               |
               + "filename" => "foo.png"
               |
               + "color" => NSDictionary
                            |
                            + "r" = 255
							|
                            + "g" = 255
							|
							...
               |
               ...
 
 That format should be easy to use with NSCoding, and Cocos2D-X
 
 Subclassing any CCNode you will code like this:
 
 - (NSDictionary *) dictionaryRepresentation
 {
	NSDictionary *dict = [super dictionaryRepresentation];
	NSDictionary *selfPropDict = [self customPropertiesDictionaryRepresentation];
    [dict setObject: selfPropDict forKey: @"MyCustomCCNodeSubclass" ];
    return dict;
 }
 
 */
- (NSDictionary *) dictionaryRepresentation;

/* Setups self from given NSDictionary 
 * Uses [super setupFromDictionaryRepresentation: aDict] before setting self properties
 */
- (void) setupFromDictionaryRepresentation: (NSDictionary *) aDict;

@end
