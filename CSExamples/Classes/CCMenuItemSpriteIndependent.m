//
//  CCMenuItemSpriteIndependent.m
//  CCMenuAdvanced
//
//  Created by Stepan Generalov on 16.11.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import "CCMenuItemSpriteIndependent.h"

@implementation CCMenuItemSpriteIndependent


-(CGRect) rect
{
	return CGRectMake( 0, 0, contentSize_.width, contentSize_.height );	
}

- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint
{
	return [normalImage_ convertToNodeSpace: worldPoint];
}

-(void) setNormalImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != normalImage_ ) {
		//
		[normalImage_ release];
		
		//image.anchorPoint = ccp(0,0);
		image.visible = YES;
		
		//[self removeChild:normalImage_ cleanup:YES];
		//[self addChild:image];
		
		//normalImage_ = image;
		normalImage_ = [image retain];
	}
}

-(void) setSelectedImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != selectedImage_ ) {
		//
		[selectedImage_ release];
		
		//image.anchorPoint = ccp(0,0);
		image.visible = NO;
		
		//[self removeChild:selectedImage_ cleanup:YES];
		//[self addChild:image];
		
		//selectedImage_ = image;
		selectedImage_ = [image retain];
	}
}

-(void) setDisabledImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != disabledImage_ ) {
		//
		[disabledImage_ release];
		
		//image.anchorPoint = ccp(0,0);
		image.visible = NO;
		
		//[self removeChild:disabledImage_ cleanup:YES];
		//[self addChild:image];
		
		//disabledImage_ = image;
		disabledImage_ = [image retain];
	}
}


- (void) dealloc
{
	[normalImage_ release];
	[selectedImage_ release];
	[disabledImage_ release];	
	
	[super dealloc];
}

@end

