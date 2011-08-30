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

@protocol CSNodeProtocol <NSObject>
@required
- (void)updateAnchor;
- (void)updatePositionLabelSafely;
- (void)updatePositionLabel;
- (NSDictionary *)dictionaryRepresentation;
- (BOOL)isSelected;
- (void)setIsSelected:(BOOL)selected;
- (NSString *)name;
- (void)setName:(NSString *)name;
@end

/*
 Objective-C does not support multiple inheritance, so we cannot have
 objects inherit both their superclass and our own custom CSNode
 (e.g. CSSprite can't inherit CCSprite and CSNode). There are a couple
 of solutions to this. The easiest way to do this would be to do something
 like this:
    Class CSSprite = [CCSprite class];
    class_setSuperclass(CSSprite, [CSNode class]);
    CCSprite *sprite = [CSSprite spriteWithFile:@"file.png"];
 What this does is it makes a Class that's the same as CCSprite, but changes
 the inheritance from:
    NSObject -> CCNode -> CCSprite
 to:
    NSObject -> CCNode -> CSNode -> CCSprite
 This works, but Apple advises aginst the use of class_setSuperclass since
 it can cause issues. It's also a little too hacky for my liking. So, the best
 solution is to do something similar to what SpaceManager does for their
 custom classes, which is to #define everything for our custom node, and
 to reference those definitions from everything we want to be a CSNode.
    -andrew0
 */
// CSNode member variables
#define CSNODE_MEM_VARS \
CCNode *_node;\
NSString *_name;\
BOOL _willUpdatePositionLabel;\
BOOL _isSelected;\
CCLayerColor *_fill;\
CCSprite *_anchor;\
CCLabelBMFont *_positionLabel;

// initialize the CSNode variables
#define CSNODE_MEM_VARS_INIT \
_fill = [[CCLayerColor layerWithColor:ccc4(30,144,255,25.5f)] retain];\
[self addChild:_fill z:NSIntegerMax-1];\
_anchor = [[CCSprite spriteWithFile:@"anchor.png"] retain];\
_anchor.opacity = 200;\
[self addChild:_anchor z:NSIntegerMax];\
_positionLabel = [[CCLabelBMFont labelWithString:@"0, 0" fntFile:@"arial.fnt"] retain];\
[_anchor addChild:_positionLabel];\
_isSelected = NO;\
_fill.visible = NO;\
_anchor.visible = NO;

// deallocate CSNode variables
#define CSNODE_MEM_VARS_DEALLOC \
[_fill release];\
[_anchor release];\
[_positionLabel release];

// CSNode methods
#define CSNODE_FUNC_SRC \
- (void)onEnter\
{\
    [super onEnter];\
    [self updateAnchor];\
}\
- (void)updateAnchor\
{\
    CGSize s = [_node boundingBox].size;\
    if (!isRelativeAnchorPoint_)\
        [_anchor setPosition:CGPointZero];\
    else\
        [_anchor setPosition:ccp(s.width*anchorPoint_.x, s.height*anchorPoint_.y)];\
\
    _node.position = (_node.isRelativeAnchorPoint) ? ccp(s.width*_node.anchorPoint.x, s.height*_node.anchorPoint.y) : CGPointZero;\
}\
- (void)updatePositionLabelSafely\
{\
    _willUpdatePositionLabel = YES;\
}\
- (void)updatePositionLabel\
{\
/*    NSAssert([[NSThread currentThread] isEqualTo:[[CCDirector sharedDirector] runningThread]], @"updatePositionLabel##must be called from cocos2d thread");*/\
\
    CGSize s = _anchor.contentSize;\
    CGPoint p = position_;\
    NSString *posText = [NSString stringWithFormat:@"%g, %g", floorf( p.x ), floorf( p.y )];\
    [_positionLabel setString:posText];\
    [_positionLabel setPosition:ccp(s.width/2, -10)];\
    _willUpdatePositionLabel = NO;\
}\
- (void)visit\
{\
    if (_willUpdatePositionLabel)\
        [self updatePositionLabel];\
\
    CGSize s = [_node boundingBox].size;\
    if ( !CGSizeEqualToSize(_fill.contentSize, s) )\
        [_fill changeWidth:s.width height:s.height];\
\
    if ( !CGSizeEqualToSize(contentSize_, _node.contentSize) )\
        self.contentSize = _node.contentSize;\
\
    [super visit];\
}\
- (void)draw\
{\
    [super draw];\
\
    if (_isSelected)\
    {\
        CGSize s = [_node boundingBox].size;\
        glColor4f(1.0f, 1.0f, 1.0f, 1.0f);\
        glLineWidth(1.0f);\
\
        CGPoint vertices[] = {\
            ccp(0, s.height),\
            ccp(s.width, s.height),\
            ccp(s.width, 0),\
            ccp(0, 0)\
        };\
\
        ccDrawPoly(vertices, 4, YES);\
    }\
}\
- (void)setPosition:(CGPoint)pos\
{\
    [super setPosition:pos];\
    [self updatePositionLabelSafely];\
}\
- (void)setAnchorPoint:(CGPoint)anchor\
{\
    [super setAnchorPoint:anchor];\
    [self updateAnchor];\
}\
- (void)setScaleX:(float)sx\
{\
    _node.scaleX = sx;\
    [self updateAnchor];\
}\
- (void)setScaleY:(float)sy\
{\
    _node.scaleY = sy;\
    [self updateAnchor];\
}\
- (void)setRotation:(float)rot\
{\
    [super setRotation:rot];\
    [_anchor setRotation:-rot];\
}\
- (void)setIsRelativeAnchorPoint:(BOOL)relative\
{\
    [super setIsRelativeAnchorPoint:relative];\
}\
- (NSDictionary *)dictionaryRepresentation\
{\
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];\
    [dict setValue:self forKey:[self name]];\
\
    /* only add children if there is at least 1 child */\
    if ([children_ count] > 0)\
    {\
        /* get dictionary representation for all children */\
        NSMutableDictionary *children = [NSMutableDictionary dictionary];\
        for (CCNode<CSNodeProtocol> *child in children_)\
            [children setObject:[child dictionaryRepresentation] forKey:[child name]];\
\
        /* add children to dictionary */\
        [dict setValue:children forKey:@"children"];\
    }\
\
    return dict;\
}\
- (BOOL)isSelected\
{\
return _isSelected;\
}\
- (void)setIsSelected:(BOOL)selected\
{\
    if (_isSelected != selected)\
    {\
        _isSelected = selected;\
        _fill.visible = selected;\
        _anchor.visible = selected;\
        [self updateAnchor];\
    }\
}\
- (NSString *)name\
{\
    return _name;\
}\
- (void)setName:(NSString *)name\
{\
    if (_name != name)\
    {\
        [_name release];\
        _name = [name copy];\
    }\
}\

/**
 * This is the basic CSNode without any additional modifications
 */
@interface CSNode : CCNode <CSNodeProtocol>
{
    CSNODE_MEM_VARS
}

@end