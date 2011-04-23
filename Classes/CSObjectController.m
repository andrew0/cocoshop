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
#import "cocoshopAppDelegate.h"
#import "CSTableViewDataSource.h"

@implementation CSObjectController

@synthesize modelObject=modelObject_;
@synthesize cocosView=cocosView_;

- (void)awakeFromNib
{
	// add a data source to the table view
	NSMutableDictionary *dict = [modelObject_ spriteDictionary];
	
	@synchronized (dict)
	{
		dataSource_ = [[CSTableViewDataSource dataSourceWithDictionary:dict] retain];
	}
	[spriteTableView_ setDataSource:dataSource_];
	
	// listen to change in table view
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spriteTableSelectionDidChange:) name:NSTableViewSelectionDidChangeNotification object:nil];
	
	// listen to notification when we deselect the sprite
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeSelectedSprite:) name:@"didChangeSelectedSprite" object:nil];

	// Disable Sprite Info for no Sprites at the beginning
	[self didChangeSelectedSprite: nil];
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
	[modelObject_ addObserver:self forKeyPath:@"rotation" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)unregisterForChangeNotification
{
//	[modelObject_ removeObserver:self forKeyPath:@"name"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if( [keyPath isEqualToString:@"name"] )
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
	else if( [keyPath isEqualToString:@"posX"] )
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			CGPoint currentPos = [sprite position];
			currentPos.x = [modelObject_ posX];
			[sprite setPosition:currentPos];
		}
	}
	else if( [keyPath isEqualToString:@"posY"] )
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			CGPoint currentPos = [sprite position];
			currentPos.y = [modelObject_ posY];
			[sprite setPosition:currentPos];
		}
	}
	else if( [keyPath isEqualToString:@"posZ"] )
	{
		
	}
	else if( [keyPath isEqualToString:@"anchorX"] )
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			CGPoint currentAnchor = [sprite anchorPoint];
			currentAnchor.x = [modelObject_ anchorX];
			[sprite setAnchorPoint:currentAnchor];
		}
	}
	else if( [keyPath isEqualToString:@"anchorY"] )
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			CGPoint currentAnchor = [sprite anchorPoint];
			currentAnchor.y = [modelObject_ anchorY];
			[sprite setAnchorPoint:currentAnchor];
		}
	}
	else if( [keyPath isEqualToString:@"scale"] )
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			[sprite setScale:[modelObject_ scale]];
		}
	}
	else if( [keyPath isEqualToString:@"flipX"] )
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
	else if( [keyPath isEqualToString:@"flipY"] )
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
	else if( [keyPath isEqualToString:@"opacity"] )
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			[sprite setOpacity:[modelObject_ opacity]];
		}
		else 
		{
			// Changing Opacity of the Background
			cocosView_.backgroundOpacity = [modelObject_ opacity];
		}

	}
	else if( [keyPath isEqualToString:@"color"] )
	{
		// grab rgba values
		NSColor *color = [[modelObject_ color] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		
		CGFloat r, g, b, a;			
		a = [color alphaComponent];
		r = [color redComponent] * a * 255;
		g = [color greenComponent] * a * 255;
		b = [color blueComponent] * a * 255;
		
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			[sprite setColor:ccc3(r, g, b)];
		}
		else
		{
			// Changing Color of the Background
			cocosView_.backgroundColor = ccc3(r,g,b );
		}
	}
	else if( [keyPath isEqualToString:@"relativeAnchor"] )
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
	else if( [keyPath isEqualToString:@"rotation"] )
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			[sprite setRotation:[modelObject_ rotation]];
		}
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)dealloc
{
	[self setCocosView:nil];
	[dataSource_ release];
	[super dealloc];
}

- (NSArray *) allowedFileTypes
{
	return [NSArray arrayWithObjects:@"png", @"gif", @"jpg", @"jpeg", @"tif", @"tiff", @"bmp", @"ccz", @"pvr", nil];
}

- (NSArray *) allowedFilesWithFiles: (NSArray *) files
{
	if (!files)
		return nil;
	
	NSMutableArray *allowedFiles = [NSMutableArray arrayWithCapacity:[files count]];
	
	for (NSString *file in files)
	{
		if ( ![file isKindOfClass:[NSString class]] )
			continue;
		
		NSString *curFileExtension = [file pathExtension];
		
		for (NSString *fileType in [self allowedFileTypes] )
		{
			if ([fileType isEqualToString: curFileExtension])
			{
				[allowedFiles addObject: file];
				break;
			}
		}
	}
	
	return allowedFiles;
}

// adds sprites on cocos thread
// executes immediatly if curThread == cocosThread
- (void) addSpritesSafelyWithFiles: (NSArray *) files
{
	NSThread *cocosThread = [[CCDirector sharedDirector] runningThread] ;
	
	[self performSelector: @selector(addSpritesWithFiles:)
				 onThread: cocosThread
			   withObject: files 
			waitUntilDone: ([[NSThread currentThread] isEqualTo:cocosThread]) ];
}

// designated sprites adding method
- (void) addSpritesWithFiles: (NSArray *) files
{
	for(NSString *filename in files)
	{		
		// create key for the sprite
		NSString *originalKey = [filename lastPathComponent];
		NSString *key = [NSString stringWithString:originalKey];
		NSUInteger i = 0;
		while([[modelObject_ spriteDictionary] objectForKey:key] != nil)
		{
			NSAssert(i <= NSUIntegerMax, @"Added too many of the same sprite");
			key = [originalKey stringByAppendingFormat:@"_%u", i++];
		}
		
		CSSprite *sprite = [CSSprite spriteWithFile:filename];
		[sprite setKey:key];
		[sprite setName:key];
		[sprite setFilename:[filename lastPathComponent]];
		@synchronized ([modelObject_ spriteDictionary])
		{
			[[modelObject_ spriteDictionary] setValue:sprite forKey:key];
		}
		
		// notify view that we added the sprite
		[[NSNotificationCenter defaultCenter] postNotificationName:@"addedSprite" object:nil];
	}
	
	// reload the table
	[spriteTableView_ reloadData];
}

- (void)deleteSpriteWithKey:(NSString *)key
{
	// delete sprite
	CSSprite *sprite = [[modelObject_ spriteDictionary] objectForKey:key];
	if(sprite)
	{
		// deselect sprite if necessary
		if( [key isEqualToString:[modelObject_ selectedSpriteKey]] )
			[modelObject_ setSelectedSpriteKey:nil];
		
		// only remove child if we're the parent
		if( [sprite parent] == cocosView_ )
			[cocosView_ removeChild:sprite cleanup:YES];
		
		// remove the sprite from the dictionary
		@synchronized( [modelObject_ spriteDictionary])
		{
			[[modelObject_ spriteDictionary] removeObjectForKey:[sprite key]];
		}
		
		// update the table
		[spriteTableView_ reloadData];
	}	
}

- (void)spriteTableSelectionDidChange:(NSNotification *)aNotification
{
	NSInteger index = [spriteTableView_ selectedRow];
	if(index >= 0)
	{
		NSArray *values = nil;
		@synchronized ([modelObject_ spriteDictionary])
		{
			values = [[modelObject_ spriteDictionary] allValues];
		}
		CSSprite *sprite = [values objectAtIndex:index];
		[modelObject_ setSelectedSpriteKey:[sprite key]];
	}
	else
	{
		[modelObject_ setSelectedSpriteKey:nil];
	}

}

- (void)didChangeSelectedSprite:(NSNotification *)aNotification
{
	if( ![modelObject_ selectedSpriteKey] )
	{
		// Editing Background
		[nameField_ setStringValue:@"Background Layer"];
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
		[opacityField_ setEnabled:YES];
		[opacitySlider_ setEnabled:YES];
		[colorWell_ setEnabled:YES];
		[relativeAnchorButton_ setEnabled:NO];
		[rotationField_ setEnabled:NO];
		[rotationSlider_ setEnabled:NO];
		
		//TODO: Set Info to Background's Properties
	}
	else
	{
		// Editing Selected Sprite 
		[nameField_ setStringValue:[modelObject_ selectedSpriteKey]];
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
		[colorWell_ setEnabled:YES];
		[relativeAnchorButton_ setEnabled:YES];
		[rotationField_ setEnabled:YES];
		[rotationSlider_ setEnabled:YES];
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
	if( [[NSDocumentController sharedDocumentController] runModalOpenPanel:openPanel forTypes:allowedTypes] == NSOKButton )
	{
		NSArray *files = [openPanel filenames];
		
		[self addSpritesSafelyWithFiles: files];
	}	
}

- (IBAction)openInfoPanel:(id)sender
{
	[infoPanel_ makeKeyAndOrderFront:nil];
}

- (IBAction)spriteAddButtonClicked:(id)sender
{
	[self addSprite:sender];
}

- (IBAction)spriteDeleteButtonClicked:(id)sender
{
	NSInteger index =  [spriteTableView_ selectedRow];
	NSArray *values = nil;
	
	@synchronized ( [modelObject_ spriteDictionary])
	{
		values = [[modelObject_ spriteDictionary] allValues];
	}
	CSSprite *sprite = [values objectAtIndex:index];
	[self deleteSpriteWithKey:[sprite key]];
}

@end
