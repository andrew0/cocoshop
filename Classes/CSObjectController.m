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

#import "CSObjectController.h"
#import "CSModel.h"
#import "CSSprite.h"
#import "HelloWorldLayer.h"

@implementation CSObjectController

@synthesize modelObject=modelObject_;
@synthesize cocosView=cocosView_;

- (void)awakeFromNib
{
}

- (void)setCocosView:(HelloWorldLayer *)view
{
	// release old view, set the new view to cocosView_ and
	// set the view's controller to self
	if(view != cocosView_)
	{
		[view retain];
		[cocosView_ release];
		cocosView_ = view;
		[view setController:self];
	}
}

- (void)registerAsObserver
{
	[modelObject_ addObserver:self forKeyPath:@"selectedSpriteKey" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"posX" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"posY" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"posZ" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"anchorX" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"anchorY" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"scale" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"flipX" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"flipY" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"opacity" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"color" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"relativeAnchor" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)unregisterForChangeNotification
{
//	[modelObject_ removeObserver:self forKeyPath:@"name"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// handle changes in the panel
	if( [keyPath isEqualToString:@"selectedSpriteKey"] )
	{
		NSLog(@"hiya");
		// if there is no selected sprite...
		if( ![modelObject_ selectedSpriteKey] )
		{
			[nameField_ setEnabled:NO];
			[posXField_ setEnabled:NO];
			[posXStepper_ setEnabled:NO];
			[posYField_ setEnabled:NO];
			[posYStepper_ setEnabled:NO];
			[posZField_ setEnabled:NO];
			[posZStepper_ setEnabled:NO];
			[anchorXField_ setEnabled:NO];
			[anchorXStepper_ setEnabled:NO];
			[anchorYField_ setEnabled:NO];
			[anchorYStepper_ setEnabled:NO];
			[scaleField_ setEnabled:NO];
			[flipXButton_ setEnabled:NO];
			[flipYButton_ setEnabled:NO];
			[opacityField_ setEnabled:NO];
			[opacitySlider_ setEnabled:NO];
			[relativeAnchorButton_ setEnabled:NO];
		}
		else
		{
			[nameField_ setEnabled:YES];
			[posXField_ setEnabled:YES];
			[posXStepper_ setEnabled:YES];
			[posYField_ setEnabled:YES];
			[posYStepper_ setEnabled:YES];
			[posZField_ setEnabled:YES];
			[posZStepper_ setEnabled:YES];
			[anchorXField_ setEnabled:YES];
			[anchorXStepper_ setEnabled:YES];
			[anchorYField_ setEnabled:YES];
			[anchorYStepper_ setEnabled:YES];
			[scaleField_ setEnabled:YES];
			[flipXButton_ setEnabled:YES];
			[flipYButton_ setEnabled:YES];
			[opacityField_ setEnabled:YES];
			[opacitySlider_ setEnabled:YES];
			[relativeAnchorButton_ setEnabled:YES];			
		}

	}
	else if([keyPath isEqualToString:@"name"])
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			NSString *currentName = [sprite name];
			NSString *newName = [modelObject_ name];
			if( ![currentName isEqualToString:newName] )
			{
				[sprite setName:newName];
				[nameField_ setStringValue:[sprite name]];
			}
		}
	}
	else if([keyPath isEqualToString:@"posX"])
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			CGPoint currentPos = [sprite position];
			currentPos.x = [modelObject_ posX];
			[sprite setPosition:currentPos];
		}
	}
	else if([keyPath isEqualToString:@"posY"])
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			CGPoint currentPos = [sprite position];
			currentPos.y = [modelObject_ posY];
			[sprite setPosition:currentPos];
		}
	}
	else if([keyPath isEqualToString:@"posZ"])
	{
		
	}
	else if([keyPath isEqualToString:@"anchorX"])
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			CGPoint currentAnchor = [sprite anchorPoint];
			currentAnchor.x = [modelObject_ anchorX];
			[sprite setAnchorPoint:currentAnchor];
		}
	}
	else if([keyPath isEqualToString:@"anchorY"])
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			CGPoint currentAnchor = [sprite anchorPoint];
			currentAnchor.y = [modelObject_ anchorY];
			[sprite setAnchorPoint:currentAnchor];
		}
	}
	else if([keyPath isEqualToString:@"scale"])
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			[sprite setScale:[modelObject_ scale]];
		}
	}
	else if([keyPath isEqualToString:@"flipX"])
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			NSInteger state = [modelObject_ flipX];
			if(state == NSOnState)
			{
				[sprite setFlipX:YES];
			}
			else
			{
				[sprite setFlipX:NO];
			}
		}
	}
	else if([keyPath isEqualToString:@"flipY"])
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			NSInteger state = [modelObject_ flipY];
			if(state == NSOnState)
			{
				[sprite setFlipY:YES];
			}
			else
			{
				[sprite setFlipY:NO];
			}
		}
	}
	else if([keyPath isEqualToString:@"opacity"])
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			[sprite setOpacity:[modelObject_ opacity]];
		}
	}
	else if( [keyPath isEqualToString:@"color"] )
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			// grab rgba values
			NSColor *color = [[modelObject_ color] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
			
			CGFloat r, g, b, a;			
			a = [color alphaComponent];
			r = [color redComponent] * a *255;
			g = [color greenComponent] * a * 255;
			b = [color blueComponent] * a * 255;						
			[sprite setColor:ccc3(r, g, b)];
		}
	}
	else if([keyPath isEqualToString:@"relativeAnchor"])
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			NSInteger state = [modelObject_ relativeAnchor];
			if(state == NSOnState)
			{
				[sprite setIsRelativeAnchorPoint:YES];
			}
			else
			{
				[sprite setIsRelativeAnchorPoint:NO];
			}
		}
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)dealloc
{
	[self setCocosView:nil];
	[super dealloc];
}

- (NSArray *) allowedFileTypes
{
	return [NSArray arrayWithObjects:@"png", @"gif", @"jpg", @"jpeg", @"tif", @"tiff", @"bmp", nil];
}

- (void) addSpritesWithFiles: (NSArray *) files
{
	for(NSString *filename in files)
	{		
		// create key for the sprite
		NSString *originalKey = [filename lastPathComponent];
		NSString *key = [NSString stringWithString:originalKey];
		NSUInteger i = 0;
		while([[modelObject_ spriteDictionary] valueForKey:originalKey] != nil)
		{
			NSAssert(i <= NSUIntegerMax, @"Added too many of the same sprite");
			key = [originalKey stringByAppendingFormat:@"_%u", i++];
		}
		
		CSSprite *sprite = [CSSprite spriteWithFile:filename];
		[sprite setKey:key];
		[sprite setName:key];
		[sprite setFilename:[filename lastPathComponent]];
		[[modelObject_ spriteDictionary] setValue:sprite forKey:key];
		
		// notify view that we added the sprite
		[[NSNotificationCenter defaultCenter] postNotificationName:@"addedSprite" object:nil];
	}
}

#pragma mark IBActions

- (IBAction)addSprite:(id)sender
{
	// allowed file types
	NSArray *allowedTypes = [self allowedFileTypes];
	
	// initialize panel + set flags
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowedFileTypes:allowedTypes];
	[openPanel setAllowsOtherFileTypes:NO];
		
	// run the panel
	if([openPanel runModalForDirectory:nil file:nil types:allowedTypes] == NSOKButton)
	{
		NSArray *files = [openPanel filenames];
		[self addSpritesWithFiles: files];
	}	
}

- (IBAction)openInfoPanel:(id)sender
{
	[infoPanel_ makeKeyAndOrderFront:nil];
}

@end
