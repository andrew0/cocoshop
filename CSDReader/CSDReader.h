/*
 * CSDReader.h
 * cocoshop
 *
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CSDElement.h"

/*
 * CSDReader's instances are created from CSD File. After init it can be used to 
 * automatically create CCNode with sprites, or node with sprites for given 
 * CCSpriteBatchNode. 
 *
 * Also it gives public access to an NSDictionary, containing all loaded CSDElement's.
 * User can retain & remove some CSDElement from this Dictionary to use it later,
 * creating Cocos2D Nodes from that CSDElement manually. 
 *
 * CSDelements that are left in Dictionary within CSDReader will be used for next
 * automatic node generation by this CSDReader.
 * CSDReader's dictionary will contain info about background, but it will not 
 * add it in autocreated node, if opacity of the background is zero.
 *
 */
@interface CSDReader : NSObject 
{
	NSMutableDictionary *elements_;
	CSDBackgroundLayer *backgroundElement_;
}

#pragma mark Creation

// Creates reader with path to csd file
// this methods uses CCFileUtils, so it will automatically choose sd and hd file.
// hd file must have CC_RETINA_DISPLAY_FILENAME_SUFFIX 
+ (id) readerWithFile: (NSString *) csdFile;
- (id) initWithFile: (NSString *) csdFile;

#pragma mark Automatic Node Creation

// Creates new node from loaded csd file.
- (CCNode *) newNode;

// Creates new instance of given class(expecting CCNode subclass) from loaded csd file.
- (id) newNodeWithClass: (Class) nodeClass;

// Creates new node from loaded csd file, trying to put all sprites as a child of
// batchNode.
// SpriteFrames with names, that needed by elements must exist before this call
// in CCSpriteFrameCache. Sprites without coresponding SpriteFrame in Cache will
// be created with spriteWithFile: and added as children to returned node.
// The batchNode can have any parent, if it doesn't - it will be added as child 
// to the returned node 
- (CCNode *) newNodeUsingBatchNode: (CCSpriteBatchNode *) batchNode;

// Creates new instance of given class (expecting CCNode subclass) from loaded 
// csd file, trying to put all sprites as a child of batchNode.
// SpriteFrames with names, that needed by elements must exist before this call
// in CCSpriteFrameCache. Sprites without coresponding SpriteFrame in Cache will
// be created with spriteWithFile: and added as children to returned node.
// The batchNode can have any parent, if it doesn't - it will be added as child 
// to the returned node 
- (CCNode *) newNodeWithClass: (Class) nodeClass usingBatchNode: (CCSpriteBatchNode *) batchNode;

#pragma mark Automatic Node Setup

// Creates different CCNode's from loaded csd file and adds them to given node as children
- (void) setupNode: (CCNode *) aNode;

// Creates different CCNode's from loaded csd trying to put all sprites as a child of
// batchNode, that will be added as child to aNode.
// SpriteFrames with names, that needed by elements must exist before this call
// in CCSpriteFrameCache. Sprites without coresponding SpriteFrame in Cache will
// be created with spriteWithFile: and added as children to aNode.
// The batchNode can have any parent, if it doesn't - it will be added as child 
// to the returned node 
- (void) setupNode: (CCNode *) aNode usingBatchNode: (CCSpriteBatchNode *) batchNode;


#pragma mark Elements Access

// Returns dictionary of all elements in CSD.
// Keys are names of the elements.
- (NSDictionary *) elements;

// Creates node from element with given name.
// Returns nil if there's no such element.
- (CCNode *) nodeFromElementWithName: (NSString *) elementName;

// Designated method. Creates node from element with given name & batchNode if possible.
// Returned node will be added to batchNode if it was created with it.
// Returns nil if there's no such element.
- (CCNode *) nodeFromElementWithName: (NSString *) elementName batchNode: (CCSpriteBatchNode *) batchNode;

// Returns background element with size = CSD workspace size
- (CSDBackgroundLayer *) backgroundElement;

// Returns CSDElement with name = elementName.
// If no such element exists - returns nil.
// This will not return any element for "background", use backgroundElement instead.
- (CSDElement *) elementWithName: (NSString *) elementName;

// Removes element from CSDReader, making it's impossible to use it further for autoNode
// within this reader.
// Return value is autoreleased CSDElement, which you can use to manually create
// Cocos2D Nodes.
- (CSDElement *) popElementWithName: (NSString *) elementName;

// Returns tag for node created with CSDElement with name = elementName
// If no such element exists - returns kCCNodeTagInvalid ( -1 )
// Note: background layer always has tag = 0
- (NSInteger) tagForElementWithName: (NSString *) elementName;



@end
