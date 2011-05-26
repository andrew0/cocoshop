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

#import "CSDReader.h"

@implementation CSDReader

#pragma mark Init / DeInit

+ (id) readerWithFile: (NSString *) csdFile;
{
	return [[[self alloc] initWithFile: csdFile] autorelease];
}

- (id) initWithFile: (NSString *) csdFile
{
	if ( (self = [super init]) )
	{
		NSString *path = [CCFileUtils fullPathFromRelativePath: csdFile];
		NSDictionary *csdDict = [NSDictionary dictionaryWithContentsOfFile: path];
		
		NSArray *children = [csdDict objectForKey:@"children"];
		
		elements_ = [[NSMutableDictionary dictionaryWithCapacity: [children count] ] retain];
		backgroundElement_ = [[CSDElement elementWithDictionary: [csdDict objectForKey: @"background"] tag: 0] retain];
		
		for (NSDictionary *elementDict in children)
		{
			// CSDElement desides instance of which subclass of CSDElement create
			CSDElement *element = [CSDElement elementWithDictionary: elementDict tag: [children indexOfObject: elementDict] + 1];
			[elements_ setObject:element forKey:element.name ];
		}
	}
	
	return self;
}

- (void) dealloc
{
	[elements_ release];
	elements_ = nil;
	
	[backgroundElement_ release];
	backgroundElement_ = nil;
	
	[super dealloc];
}


#pragma mark Automatic Node Creation

- (CCNode *) newNode
{
	return [self newNodeWithClass: [CCNode class] usingBatchNode: nil ];
}

- (id) newNodeWithClass: (Class) nodeClass
{
	return [self newNodeWithClass: nodeClass usingBatchNode: nil ];
}

- (CCNode *) newNodeUsingBatchNode: (CCSpriteBatchNode *) batchNode
{
	return [self newNodeWithClass: [CCNode class] usingBatchNode: batchNode ];
}

// Same as previous, using given class (CCNode subclass expected)
- (CCNode *) newNodeWithClass: (Class) nodeClass usingBatchNode: (CCSpriteBatchNode *) batchNode
{
	// create node
	if (! nodeClass )
		nodeClass = [CCNode class];
	CCNode *node = [nodeClass node];
	
	// And Set it Up
	[self setupNode: node usingBatchNode: batchNode];	
	
	return node;
}

#pragma mark Automatic Node Setup

- (void) setupNode: (CCNode *) aNode
{
	[self setupNode: aNode usingBatchNode: nil ];
}

- (void) setupNode: (CCNode *) aNode usingBatchNode: (CCSpriteBatchNode *) batchNode
{
	// setup node's size
	[aNode setContentSize: [backgroundElement_ contentSize]];
	
	// Add layerColor if it's not fully transparent
	if ([backgroundElement_ opacity]) 
	{
		[aNode addChild: [backgroundElement_ newNode] z: NSIntegerMin];
	}
	
	// add batchNode to aNode if needed
	if (batchNode) 
	{
		if (![batchNode parent])
		{
			[aNode addChild:batchNode];
			batchNode.contentSize = aNode.contentSize;
			batchNode.position = ccp(0,0);
			batchNode.anchorPoint = ccp(0,0);
		}
	}
	
	// create and add elements
	for (NSString *elementKey in elements_) 
	{
		CSDElement *element = [elements_ objectForKey: elementKey];
		
		// element with batchNode
		if ([element canCreateNewNodeWithBatchNode: batchNode])
		{
			CCNode *newElementNode = [element newNodeWithBatchNode: batchNode ];
			if (![newElementNode parent])
				[batchNode addChild: newElementNode z: [newElementNode zOrder] tag: [element tag]];
			continue;
		}
		
		// normal element
		CCNode *newElementNode = [element newNode];
		[aNode addChild:newElementNode z:[newElementNode zOrder] tag: [element tag] ];
		
	}
}


#pragma mark Elements Access

- (CSDBackgroundLayer *) backgroundElement
{
	return backgroundElement_;
}

- (CSDElement *) elementWithName: (NSString *) elementName
{
	return [elements_ objectForKey: elementName];
}

- (CSDElement *) popElementWithName: (NSString *) elementName;
{
	CSDElement *element = [elements_ objectForKey: elementName];
	[[element retain] autorelease];
	
	[elements_ removeObjectForKey: elementName];
	
	return element;
}

- (NSInteger) tagForElementWithName: (NSString *) elementName
{
	// background isn't in elements_ array
	if ([elementName isEqualToString: @"background"]) {
		return 0;
	}
	
	CSDElement *element = [elements_ objectForKey: elementName];
	if (element)
		return [element tag];
	
	return kCCNodeTagInvalid;
}

@end
