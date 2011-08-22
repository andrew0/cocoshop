//
//  CSSceneView.h
//  cocoshop
//
//  Created by andrew on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@class CSLayerView;

@interface CSSceneView : CCScene
{
    BOOL _shouldUpdateForScreenReshape;
    CCSprite *_backgroundTexture;
    CSLayerView *_layer;
}

@property (nonatomic, retain) CSLayerView *layer;

@end
