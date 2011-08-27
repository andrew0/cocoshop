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

#import "CSToolbarController.h"
#import "CSBrowser.h"
#import "CSBrowserWindowController.h"
#import "CSSceneView.h"
#import "CSLayerView.h"

@implementation CSToolbarController

- (void)awakeFromNib
{
    [_addSegment setMenu:_menu forSegment:0];
}

- (IBAction)addSprite:(id)sender
{    
    if ( [browser_.windowController isKindOfClass:[CSBrowserWindowController class]] )
    {
        CSBrowserWindowController *controller = (CSBrowserWindowController *)browser_.windowController;
        [controller addSprite:sender];
    }
}

- (IBAction)zoom:(id)sender
{
    CGFloat toAdd;
    if ( [sender isKindOfClass:[NSSegmentedControl class]] )
        toAdd = ( [(NSSegmentedControl *)sender selectedSegment] == 0 ) ? -0.25f : 0.25f;
    else
        return;
    
    if ( [[CCDirector sharedDirector].runningScene isKindOfClass:[CSSceneView class]] )
    {
        CSSceneView *scene = (CSSceneView *)[CCDirector sharedDirector].runningScene;
        if (scene.layer)
            scene.layer.scale = MIN(MAX(scene.layer.scale + toAdd, 0.1f), 3.0f);
    }
}

@end
