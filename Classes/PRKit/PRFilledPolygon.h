/*
  PRFilledPolygon.h
 
    PRKit:  Precognitive Research additions to Cocos2D.  http://cocos2d-iphone.org
    Contact us if you like it:  http://precognitiveresearch.com
 
  Created by Andy Sinesio on 6/25/10.
  Copyright 2011 Precognitive Research, LLC. All rights reserved.
 
 This class fills a polygon as described by an array of NSValue-encapsulated points with a texture.
 
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

@interface PRFilledPolygon : CCNode {
@private
	int pointCount;
	int areaTrianglePointCount;

	CCTexture2D *texture;
	ccBlendFunc blendFunc;
	
	CGPoint *points;
	CGPoint *areaTrianglePoints;
	CGPoint *textureCoordinates;
}

@property (nonatomic, readonly) CGPoint *points;
@property (nonatomic, readonly) int pointCount;
@property (nonatomic, retain) CCTexture2D *texture;

/**
 Initialize the polygon.  polygonPoints is an NSArray full of NSValues that are the vertexes of the polygon.  The texture will be repeated. 
*/
-(id) initWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture2D *) fillTexture;


@end
