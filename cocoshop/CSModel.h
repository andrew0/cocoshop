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
#import "cocos2d.h"

@class CSLayerView;
@protocol CSNodeProtocol;

/**
 * CSModel is a model for a CSNode/views. Some of the properties, such
 * as workspaceWidth and workspaceHeight, are general properties for
 * the entire project. Others, such as opacity, color, posX, posY, etc
 * are for the currently selected node (if there is one).
 */
@interface CSModel : NSObject
{
    NSString *_projectName;
    
    CCNode<CSNodeProtocol> *_selectedNode;
    
    BOOL _firstTime;
    NSDictionary *_nodeProperties;
    
    CGFloat _workspaceWidth;
    CGFloat _workspaceHeight;
    float _opacity;
    NSColor *_color;
    NSString *_name;
    CGFloat _posX;
    CGFloat _posY;
    CGFloat _anchorX;
    CGFloat _anchorY;
    float _scaleX;
    float _scaleY;
    float _rotation;
    NSInteger _zOrder;
    BOOL _visible;
    BOOL _relativeAnchor;
    CGFloat _textureRectX;
    CGFloat _textureRectY;
    CGFloat _textureRectWidth;
    CGFloat _textureRectHeight;
    BOOL _flipX;
    BOOL _flipY;
}

@property (nonatomic, copy) NSString *projectName;
@property (nonatomic, retain) CCNode<CSNodeProtocol> *selectedNode;
@property (nonatomic, assign) BOOL firstTime;
@property (nonatomic, retain) NSDictionary *nodeProperties;
@property (nonatomic, assign) CGFloat workspaceWidth;
@property (nonatomic, assign) CGFloat workspaceHeight;
@property (nonatomic, assign) float opacity;
@property (nonatomic, copy) NSColor *color;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGFloat posX;
@property (nonatomic, assign) CGFloat posY;
@property (nonatomic, assign) CGFloat anchorX;
@property (nonatomic, assign) CGFloat anchorY;
@property (nonatomic, assign) float scaleX;
@property (nonatomic, assign) float scaleY;
@property (nonatomic, assign) float rotation;
@property (nonatomic, assign) NSInteger zOrder;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) BOOL relativeAnchor;
@property (nonatomic, assign) CGFloat textureRectX;
@property (nonatomic, assign) CGFloat textureRectY;
@property (nonatomic, assign) CGFloat textureRectWidth;
@property (nonatomic, assign) CGFloat textureRectHeight;
@property (nonatomic, assign) BOOL flipX;
@property (nonatomic, assign) BOOL flipY;

/**
 * Reset all the properties to their default values
 */
- (void)reset;
- (CCNode<CSNodeProtocol> *)nodeWithName:(NSString *)name;

@end
