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
    if ( ![sender isKindOfClass:[NSSegmentedControl class]] )
        return;
    
    if ( [[CCDirector sharedDirector].runningScene isKindOfClass:[CSSceneView class]] )
    {
        CSSceneView *scene = (CSSceneView *)[CCDirector sharedDirector].runningScene;
        
        float scaleTo;
        switch ([(NSSegmentedControl *)sender selectedSegment])
        {
            case 0:
                scaleTo = MIN(MAX(scene.layer.scale - 0.25f, 0.1f), 3.0f);
                break;
            case 1:
                scaleTo = 1;
                break;
            case 2:
                scaleTo = MIN(MAX(scene.layer.scale + 0.25f, 0.1f), 3.0f);
                break;
            default:
                scaleTo = scene.layer.scale;
                break;
        }
        
        if (scene.layer)
            [scene.layer runAction:[CCScaleTo actionWithDuration:0.15f scale:scaleTo]];
    }
}

@end
