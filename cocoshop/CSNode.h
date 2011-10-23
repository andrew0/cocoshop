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
#import "CSLayerView.h"
#import "CSSceneView.h"
#import "CSModel.h"

#ifndef FLT_EPSILON
#define FLT_EPSILON 0.0000000001f
#endif

@protocol CSNodeProtocol <NSObject>
@required
- (void)updateAnchor;
- (void)updatePositionLabelSafely;
- (void)updatePositionLabel;
- (BOOL)isSelected;
- (void)setIsSelected:(BOOL)selected;
- (NSString *)name;
- (void)setName:(NSString *)name;
- (CSModel *)currentModel;
- (NSUndoManager *)undoManager;
- (NSDictionary *)dictionaryRepresentation;
- (void)setupFromDictionaryRepresentation:(NSDictionary *)dict;
@optional
// subclasses that utilize CSNode can define their own variables to be part
// of dictionary representation by using this method
- (NSDictionary *)_dictionaryRepresentation;
// subclasses can provide their own implementation of setupFromDictionaryRepresentation
// using this method
- (void)_setupFromDictionaryRepresentation:(NSDictionary *)dict;
@end

@interface CCNode (Internal)
- (void)_setZOrder:(NSInteger)z;
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
CCLabelBMFont *_positionLabel;\
BOOL _isScaleXZero;\
BOOL _isScaleYZero;

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
        _anchor.position = self.isRelativeAnchorPoint ? ccp(s.width*anchorPoint_.x, s.height*anchorPoint_.y) : CGPointZero;\
\
    _node.position = (_node.isRelativeAnchorPoint) ? ccp(s.width*_node.anchorPoint.x, s.height*_node.anchorPoint.y) : CGPointZero;\
\
    _anchor.scaleX = 1.0f / self.scaleX;\
    _anchor.scaleY = 1.0f / self.scaleY;\
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
    if (!CGPointEqualToPoint(pos, self.position))\
    {\
        [[self undoManager] beginUndoGrouping];\
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setPosX:self.position.x];\
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setPosY:self.position.y];\
        [[self undoManager] setActionName:@"Reposition node"];\
        [[self undoManager] endUndoGrouping];\
    }\
\
    [super setPosition:pos];\
    [self updatePositionLabelSafely];\
}\
- (void)setAnchorPoint:(CGPoint)anchor\
{\
    if (!CGPointEqualToPoint(anchor, self.anchorPoint))\
    {\
        [[self undoManager] beginUndoGrouping];\
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setAnchorX:self.anchorPoint.x];\
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setAnchorX:self.anchorPoint.y];\
        [[self undoManager] setActionName:@"Reposition node"];\
        [[self undoManager] endUndoGrouping];\
    }\
    [super setAnchorPoint:anchor];\
    [self updateAnchor];\
}\
- (void)setScaleX:(float)sx\
{\
    _isScaleXZero = (sx == 0);\
\
    if (sx == 0)\
        sx = FLT_EPSILON;\
\
    if (sx != self.scaleX)\
    {\
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setScaleX:self.scaleX];\
        [[self undoManager] setActionName:@"Change scale"];\
    }\
\
    [super setScaleX:sx];\
    [self updateAnchor];\
}\
- (void)setScaleY:(float)sy\
{\
    _isScaleYZero = (sy == 0);\
\
    if (sy == 0)\
        sy = FLT_EPSILON;\
\
    if (sy != self.scaleY)\
    {\
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setScaleY:self.scaleY];\
        [[self undoManager] setActionName:@"Change scale"];\
    }\
\
    [super setScaleY:sy];\
    [self updateAnchor];\
}\
- (float)scaleX\
{\
    return _isScaleXZero ? 0.0f : [super scaleX];\
}\
- (float)scaleY\
{\
    return _isScaleYZero ? 0 : [super scaleY];\
}\
- (void)setRotation:(float)rot\
{\
    if (rot != self.rotation)\
    {\
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setRotation:self.rotation];\
        [[self undoManager] setActionName:@"Change rotation"];\
    }\
    [super setRotation:rot];\
    [_anchor setRotation:-rot];\
}\
- (void)setTag:(NSInteger)tag\
{\
    if (tag != self.tag)\
    {\
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setTag:self.tag];\
        [[self undoManager] setActionName:@"Change tag"];\
    }\
\
    [super setTag:tag];\
}\
- (void)setVisible:(BOOL)visible\
{\
    if (visible != self.visible)\
    {\
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setVisible:self.visible];\
        [[self undoManager] setActionName:@"Change visibility"];\
    }\
\
    _node.visible = visible;\
}\
- (BOOL)visible\
{\
    return _node.visible;\
}\
- (void)setIsRelativeAnchorPoint:(BOOL)relative\
{\
    if (relative != self.isRelativeAnchorPoint)\
    {\
        [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setRelativeAnchor:self.isRelativeAnchorPoint];\
        [[self undoManager] setActionName:@"Change relative anchor point"];\
    }\
\
    [super setIsRelativeAnchorPoint:relative];\
    [self updateAnchor];\
}\
- (void)_setZOrder:(NSInteger)z\
{\
    if ( [[self superclass] instancesRespondToSelector:@selector(_setZOrder:)] )\
    {\
        if (z != self.zOrder)\
        {\
            [[[self undoManager] prepareWithInvocationTarget:[self currentModel]] setZOrder:self.zOrder];\
            [[self undoManager] setActionName:@"Change Z order"];\
        }\
\
        [super _setZOrder:z];\
    }\
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
- (CSModel *)currentModel\
{\
    if ( ![[[CCDirector sharedDirector] runningScene] isKindOfClass:[CSSceneView class]] )\
        return nil;\
    \
    return [[(CSSceneView *)[[CCDirector sharedDirector] runningScene] layer] model];\
}\
- (NSUndoManager *)undoManager\
{\
    return [[self currentModel] undoManager];\
}\
- (NSDictionary *)dictionaryRepresentation\
{\
    NSMutableDictionary *dict;\
\
    if ([self respondsToSelector:@selector(_dictionaryRepresentation)])\
        dict = [NSMutableDictionary dictionaryWithDictionary:[self _dictionaryRepresentation]];\
    else\
        [NSMutableDictionary dictionaryWithCapacity:11];\
\
    [dict setValue:self.name forKey:@"name"];\
    [dict setValue:NSStringFromPoint(NSPointFromCGPoint(self.position)) forKey:@"position"];\
    [dict setValue:NSStringFromPoint(NSPointFromCGPoint(self.anchorPoint)) forKey:@"anchorPoint"];\
    [dict setValue:[NSNumber numberWithFloat:self.scaleX] forKey:@"scaleX"];\
    [dict setValue:[NSNumber numberWithFloat:self.scaleY] forKey:@"scaleY"];\
    [dict setValue:NSStringFromSize(NSSizeFromCGSize(self.contentSize)) forKey:@"contentSize"];\
    [dict setValue:[NSNumber numberWithInteger:self.zOrder] forKey:@"zOrder"];\
    [dict setValue:[NSNumber numberWithFloat:self.rotation] forKey:@"rotation"];\
    [dict setValue:[NSNumber numberWithInteger:self.tag] forKey:@"tag"];\
    [dict setValue:[NSNumber numberWithBool:self.visible] forKey:@"visible"];\
    [dict setValue:[NSNumber numberWithBool:self.isRelativeAnchorPoint] forKey:@"isRelativeAnchorPoint"];\
\
    return dict;\
}\
- (void)setupFromDictionaryRepresentation:(NSDictionary *)dict\
{\
    if ([self respondsToSelector:@selector(_setupFromDictionaryRepresentation:)])\
        [self _setupFromDictionaryRepresentation:dict];\
\
    self.name = [dict valueForKey:@"name"];\
    self.position = NSPointToCGPoint(NSPointFromString([dict valueForKey:@"position"]));\
    self.anchorPoint = NSPointToCGPoint(NSPointFromString([dict valueForKey:@"anchorPoint"]));\
    self.scaleX = [[dict valueForKey:@"scaleX"] floatValue];\
    self.scaleY = [[dict valueForKey:@"scaleY"] floatValue];\
    self.contentSize = NSSizeToCGSize(NSSizeFromString([dict valueForKey:@"contentSize"]));\
    self.rotation = [[dict valueForKey:@"rotation"] floatValue];\
    self.tag = [[dict valueForKey:@"tag"] integerValue];\
    self.visible = [[dict valueForKey:@"visible"] boolValue];\
    self.isRelativeAnchorPoint = [[dict valueForKey:@"isRelativeAnchorPoint"] boolValue];\
\
    if ([self respondsToSelector:@selector(_setZOrder:)])\
        [self _setZOrder:[[dict valueForKey:@"zOrder"] integerValue]];\
}

/**
 * This is the basic CSNode without any additional modifications
 */
@interface CSNode : CCNode <CSNodeProtocol>
{
    CSNODE_MEM_VARS
}

@end