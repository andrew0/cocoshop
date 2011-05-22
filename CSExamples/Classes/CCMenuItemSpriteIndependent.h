//
//  CCMenuItemSpriteIndependent.h
//  CCMenuAdvanced
//
//  Created by Stepan Generalov on 16.11.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// CCMenuItemSprite is CCMenuItemSprite that doesn't add normal, selected
// and disabled images as children. Instead of that its just retain them.
// So you can place images anyhow you want.
// 
// Note: content size will be set from normalImage_ on init in CCMenuItemSprite
//		CCMenuItemSpriteIndependent changes only the way of holding images
@interface CCMenuItemSpriteIndependent : CCMenuItemSprite
{}

@end







