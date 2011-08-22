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

#import "CSOutlineViewDataSource.h"
#import "CSLayerView.h"
#import "CSSceneView.h"
#import "CSNode.h"

@implementation CSOutlineViewDataSource

@dynamic layer;

- (CSLayerView *)layer
{
    if ([[CCDirector sharedDirector].runningScene isKindOfClass:[CSSceneView class]])
    {
        CSSceneView *scene = (CSSceneView *)[CCDirector sharedDirector].runningScene;
        return scene.layer;
    }
    
    return nil;
}

- (NSUInteger)numberOfChildrenForNode:(CCNode *)node
{
    NSUInteger count = 0;
    for (CCNode *child in [node children])
        if ([child conformsToProtocol:@protocol(CSNodeProtocol)])
            count++;
    
    return count;
}

- (NSArray *)sortChildrenByZ:(CCNode *)node
{
    /*
    // put into a dictionary with a key for the node, and a key for the zOrder
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:node.children.count];
    for (CCNode *child in node.children)
    {
        if ([child conformsToProtocol:@protocol(CSNodeProtocol)])
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
            [dict setValue:child forKey:@"node"];
            [dict setValue:[NSNumber numberWithInteger:child.zOrder] forKey:@"zOrder"];
            [array addObject:dict];
        }
    }
    
    // sort array by the zOrder value in the dictionary in descending order
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"zOrder" ascending:NO selector:@selector(compare:)];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    // now that there is an array with dictionaries in it,
    // make a new array with just the node
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[sortedArray count]];
    for (NSDictionary *dict in sortedArray)
        [ret addObject:[dict objectForKey:@"node"]];
     */
    
    CCArray *children = [[self layer] children];
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[children count]];
    for (CCNode *child in [[children getNSArray] reverseObjectEnumerator])
        if ([child conformsToProtocol:@protocol(CSNodeProtocol)])
            [ret addObject:child];
    
    return ret;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    return (item == nil) ? [self numberOfChildrenForNode:[self layer]] : [self numberOfChildrenForNode:item];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    CCNode *node;
    if (item && [item isKindOfClass:[CCNode class]])
        node = item;
    else
        node = [self layer];
    
    NSArray *sorted = [self sortChildrenByZ:node];
    if (sorted && [sorted count] > index)
        return [sorted objectAtIndex:index];
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return (item == nil) ? ([self numberOfChildrenForNode:[self layer]] > 0) : ([self numberOfChildrenForNode:item] > 0);
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return (item == nil) ? @"null" : [(CCNode<CSNodeProtocol> *)item name];
}

@end
