/*
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

#import <Cocoa/Cocoa.h>
#import "cocos2d.h"


@interface CSMacGLView : MacGLView <CCProjectionProtocol>
{
	ccDirectorProjection projection_;
}

/* Size of the viewport, this property sets CCDirector#winSize and
 * is used in Cocoshop for setting workspace size
 *
 * Due to NSGLView restrictions and zoom functionalty of the CSMacGLView
 * this value isn't always equal to view's frame size. */
@property (readwrite) CGSize workspaceSize;

/* Since CSMacGLView uses custom projection
 * we need a method, that will allow us to choose between 2D/3D projections
 * without cancelling custom projection.
 * Use this property to set kCCDirectorProjection3D || kCCDirectorProjection2D
 * Do not set projection with CCDirector#setProjection: while using CSMacGLView !
 * Custom projection isn't supported, but you can easily add it by implementing
 * delegate property and copypasting some code from MacGLView
 */
@property (readwrite) ccDirectorProjection projection;


#pragma mark Zoom
/* Zoom factor just like in Gimp or other Graphics Editors
 Zoomes the node with changing glViewport
 1.0f is for 100% Scale
 */
@property (readwrite) CGFloat zoomFactor;

@property (readwrite) CGFloat zoomSpeed; //< default is 0.1f
@property (readwrite) CGFloat zoomFactorMax; //< default is 3.0f
@property (readwrite) CGFloat zoomFactorMin; //< default is 0.1f

- (void) resetZoom;

@end
