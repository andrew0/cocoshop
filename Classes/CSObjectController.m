/*
 * cocoshop
 *
 * Copyright (c) 2011 Andrew
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

#import "CSObjectController.h"
#import "CSModel.h"
#import "CSSprite.h"
#import "CSMainLayer.h"
#import "cocoshopAppDelegate.h"
#import "CSTableViewDataSource.h"
#import "DebugLog.h"
#import "NSString+RelativePath.h"

@implementation CSObjectController

@synthesize modelObject=modelObject_;
@synthesize mainLayer=mainLayer_;
@synthesize spriteTableView=spriteTableView_;
@synthesize spriteInfoView;
@synthesize backgroundInfoView;
@synthesize projectFilename;

#pragma mark Init / DeInit

- (void)awakeFromNib
{
	// add a data source to the table view
	NSMutableArray *spriteArray = [modelObject_ spriteArray];
	
	@synchronized(spriteArray)
	{
		dataSource_ = [[CSTableViewDataSource dataSourceWithArray:spriteArray] retain];
	}
	[spriteTableView_ setDataSource:dataSource_];
	
	// listen to change in table view
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spriteTableSelectionDidChange:) name:NSTableViewSelectionDidChangeNotification object:nil];
	
	// listen to notification when we deselect the sprite
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeSelectedSprite:) name:@"didChangeSelectedSprite" object:nil];

	// Disable Sprite Info for no Sprites at the beginning
	[self didChangeSelectedSprite:nil];
	
	// This will make panels less distracting
	[infoPanel_ setBecomesKeyOnlyIfNeeded: YES];
	[spritesPanel_ setBecomesKeyOnlyIfNeeded: YES];
}

- (void)dealloc
{
	self.projectFilename = nil;
	self.spriteInfoView = nil;
	self.backgroundInfoView = nil;
	
	[self setMainLayer:nil];
	[dataSource_ release];
	[super dealloc];
}

- (void)setMainLayer:(CSMainLayer *)view
{
	// release old view, set the new view to mainLayer_ and
	// set the view's controller to self
	if(view != mainLayer_)
	{
		[view retain];
		[mainLayer_ release];
		mainLayer_ = view;
		[view setController:self];
	}
}

#pragma mark Values Observer

- (void)registerAsObserver
{
	[modelObject_ addObserver:self forKeyPath:@"stageWidth" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"stageHeight" options:NSKeyValueObservingOptionNew context:NULL];
	
	[modelObject_ addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"posX" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"posY" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"posZ" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"anchorX" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"anchorY" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"scaleX" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"scaleY" options:NSKeyValueObservingOptionNew context:NULL];
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
	DebugLog(@"keyPath  = %@", keyPath);
	
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
		else
		{
			CGPoint currentPos = [[modelObject_ backgroundLayer] position];
			currentPos.x = [modelObject_ posX];
			[[modelObject_ backgroundLayer] setPosition:currentPos];
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
		else
		{
			CGPoint currentPos = [[modelObject_ backgroundLayer] position];
			currentPos.y = [modelObject_ posY];
			[[modelObject_ backgroundLayer] setPosition:currentPos];
		}

	}
	else if( [keyPath isEqualToString:@"posZ"] )
	{
		// Reorder Z order
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			CGFloat currentZ = [sprite zOrder];
			currentZ = [modelObject_ posZ];
			[[sprite parent] reorderChild: sprite z: currentZ ];
		}
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
		else
		{
			CGPoint currentAnchor = [[modelObject_ backgroundLayer] anchorPoint];
			currentAnchor.x = [modelObject_ anchorX];
			[[modelObject_ backgroundLayer] setAnchorPoint:currentAnchor];
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
		else
		{
			CGPoint currentAnchor = [[modelObject_ backgroundLayer] anchorPoint];
			currentAnchor.y = [modelObject_ anchorY];
			[[modelObject_ backgroundLayer] setAnchorPoint:currentAnchor];
		}		
	}
	else if( [keyPath isEqualToString:@"scaleX"] )
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			[sprite setScaleX:[modelObject_ scaleX]];
		}
		else
		{
			[[modelObject_ backgroundLayer] setScaleX:[modelObject_ scaleX]];
		}
	}
	else if( [keyPath isEqualToString:@"scaleY"] )
	{
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			[sprite setScaleY:[modelObject_ scaleY]];
		}
		else
		{
			[[modelObject_ backgroundLayer] setScaleY:[modelObject_ scaleY]];
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
			[[modelObject_ backgroundLayer] setOpacity:[modelObject_ opacity]];
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
			[[modelObject_ backgroundLayer] setColor:ccc3(r, g, b)];
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
		else
		{
			NSInteger state = [modelObject_ relativeAnchor];
			if(state == NSOnState)
			{
				[[modelObject_ backgroundLayer] setIsRelativeAnchorPoint:YES];
			}
			else
			{
				[[modelObject_ backgroundLayer] setIsRelativeAnchorPoint:NO];
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
		else
		{
			[[modelObject_ backgroundLayer] setRotation:[modelObject_ rotation]];
		}
	}
	else if( [keyPath isEqualToString:@"stageWidth"] )
	{
		CGSize s = [[CCDirector sharedDirector] winSize];
		s.width = modelObject_.stageWidth;
		[(CSMacGLView *)[[CCDirector sharedDirector] openGLView] setWorkspaceSize: s];
		[(CSMacGLView *)[[CCDirector sharedDirector] openGLView] updateWindow ];
		
		[self.mainLayer updateForScreenReshapeSafely: nil];
		
	}
	else if( [keyPath isEqualToString:@"stageHeight"] )
	{
		CGSize s = [[CCDirector sharedDirector] winSize];
		s.height = modelObject_.stageHeight;
		[(CSMacGLView *)[[CCDirector sharedDirector] openGLView] setWorkspaceSize: s];
		[(CSMacGLView *)[[CCDirector sharedDirector] openGLView] updateWindow ];
		
		[self.mainLayer updateForScreenReshapeSafely: nil];
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark Sprites

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
				[allowedFiles addObject:file];
				break;
			}
		}
	}
	
	return allowedFiles;
}

// adds sprites on cocos thread
// executes immediatly if curThread == cocosThread
- (void)addSpritesWithFilesSafely:(NSArray *)files
{
	NSThread *cocosThread = [[CCDirector sharedDirector] runningThread] ;
	
	[self performSelector:@selector(addSpritesWithFiles:)
				 onThread:cocosThread
			   withObject:files 
			waitUntilDone:([[NSThread currentThread] isEqualTo:cocosThread])];
}

// designated sprites adding method
- (void)addSpritesWithFiles:(NSArray *)files
{
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	for(NSString *filename in files)
	{		
		// create key for the sprite
		NSString *originalName = [filename lastPathComponent];
		NSString *name = [NSString stringWithString:originalName];
		NSUInteger i = 0;
		while( [modelObject_ selectedSprite] != nil )
		{
			NSAssert(i <= NSUIntegerMax, @"Added too many of the same sprite");
			name = [originalName stringByAppendingFormat:@"_%u", i++];
		}
		
		CSSprite *sprite = [CSSprite spriteWithFile:filename];
		[sprite setName:name];
		[sprite setFilename:filename];
		@synchronized( [modelObject_ spriteArray] )
		{
			[[modelObject_ spriteArray] addObject:sprite];
		}
		
		// notify view that we added the sprite
		[[NSNotificationCenter defaultCenter] postNotificationName:@"addedSprite" object:nil];
	}
	
	// reload the table
	[spriteTableView_ reloadData];
}

- (void)deleteAllSprites
{
	// deselect everything
	[modelObject_ setSelectedSprite:nil];
		
	// remove all sprites from main layer
	for (CCNode * sprite in [modelObject_ spriteArray])
	{
		// only remove child if we're the parent
		if( [sprite parent] == mainLayer_ )
			[mainLayer_ removeChild:sprite cleanup:YES];
	}
		
	// remove all sprites from the dictionary
	@synchronized([modelObject_ spriteArray])
	{
		[[modelObject_ spriteArray] removeAllObjects];
	}	
}

- (void)deleteSprite:(CSSprite *)sprite
{
	// delete sprite
	if(sprite)
	{
		// deselect sprite if necessary
		if( [sprite isEqualTo:sprite] )
			[modelObject_ setSelectedSprite:nil];
		
		// only remove child if we're the parent
		if( [sprite parent] == mainLayer_ )
			[mainLayer_ removeChild:sprite cleanup:YES];
		
		// remove the sprite from the dictionary
		@synchronized([modelObject_ spriteArray])
		{
			[[modelObject_ spriteArray] removeObject:sprite];
		}
	}	
}

#pragma mark Notifications

- (void)spriteTableSelectionDidChange:(NSNotification *)aNotification
{
	NSInteger index = [spriteTableView_ selectedRow];
	if(index >= 0)
	{
		CSSprite *sprite = [[modelObject_ spriteArray] objectAtIndex:index];
		[modelObject_ setSelectedSprite:sprite];
	}
	else
	{
		[modelObject_ setSelectedSprite:nil];
	}

}

- (void) setInfoPanelView: (NSView *) aView
{
	//CGRect frame = [infoPanel_ frame];
	//frame.size = [aView frame].size;
	[infoPanel_ setContentView:aView];
	//[infoPanel_ setFrame: frame display: YES];
}

- (void)didChangeSelectedSprite:(NSNotification *)aNotification
{
	if( ![modelObject_ selectedSprite] )
	{
		// Editing Background
		[self setInfoPanelView: self.backgroundInfoView];
		[spriteTableView_ deselectAll:nil];
	}
	else
	{
		// Editing Selected Sprite 
		[self setInfoPanelView: self.spriteInfoView];
		
		// get the index for the sprite
		CSSprite *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			NSArray *array = [modelObject_ spriteArray];
			NSIndexSet *set = [NSIndexSet indexSetWithIndex:[array indexOfObject:sprite]];
			[spriteTableView_ selectRowIndexes:set byExtendingSelection:NO];
		}
	}
}

#pragma mark Save / Load

- (NSDictionary *)dictionaryFromLayerForBaseDirPath: (NSString *) baseDirPath
{
	CCLayerColor *bgLayer = [modelObject_ backgroundLayer];
	
	NSMutableDictionary *bg = [NSMutableDictionary dictionaryWithCapacity:15];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer contentSize].width] forKey:@"stageWidth"];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer contentSize].height] forKey:@"stageHeight"];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer position].x] forKey:@"posX"];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer position].y] forKey:@"posY"];
	[bg setValue:[NSNumber numberWithInteger:[bgLayer zOrder]] forKey:@"posZ"];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer anchorPoint].x] forKey:@"anchorX"];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer anchorPoint].y] forKey:@"anchorY"];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer scaleX]] forKey:@"scaleX"];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer scaleY]] forKey:@"scaleY"];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer opacity]] forKey:@"opacity"];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer color].r] forKey:@"colorR"];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer color].g] forKey:@"colorG"];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer color].b] forKey:@"colorB"];
	[bg setValue:[NSNumber numberWithFloat:[bgLayer rotation]] forKey:@"rotation"];
	[bg setValue:[NSNumber numberWithBool:[bgLayer isRelativeAnchorPoint]] forKey:@"relativeAnchor"];
	
	NSMutableArray *children = [NSMutableArray arrayWithCapacity:[[mainLayer_ children] count]];
	CCNode *child;
	CCARRAY_FOREACH([mainLayer_ children], child)
	{
		if( [child isKindOfClass:[CSSprite class]] )
		{
			CSSprite *sprite = (CSSprite *)child;
			
			// Use relative path if possible
			NSString *relativePath = [[sprite filename] relativePathFromBaseDirPath: baseDirPath ];
			if (relativePath)
				sprite.filename = relativePath;			
			
			// Save Sprite to Dictionary
			NSMutableDictionary *childValues = [NSMutableDictionary dictionaryWithCapacity:16];
			[childValues setValue:[sprite name] forKey:@"name"];			
			[childValues setValue:[sprite filename] forKey:@"filename"];
			[childValues setValue:[NSNumber numberWithFloat:[sprite position].x] forKey:@"posX"];
			[childValues setValue:[NSNumber numberWithFloat:[sprite position].y] forKey:@"posY"];
			[childValues setValue:[NSNumber numberWithInteger:[sprite zOrder]] forKey:@"posZ"];
			[childValues setValue:[NSNumber numberWithFloat:[sprite anchorPoint].x] forKey:@"anchorX"];
			[childValues setValue:[NSNumber numberWithFloat:[sprite anchorPoint].y] forKey:@"anchorY"];
			[childValues setValue:[NSNumber numberWithFloat:[sprite scaleX]] forKey:@"scaleX"];
			[childValues setValue:[NSNumber numberWithFloat:[sprite scaleY]] forKey:@"scaleY"];
			[childValues setValue:[NSNumber numberWithBool:[sprite flipX]] forKey:@"flipX"];
			[childValues setValue:[NSNumber numberWithBool:[sprite flipY]] forKey:@"flipY"];
			[childValues setValue:[NSNumber numberWithFloat:[sprite opacity]] forKey:@"opacity"];
			[childValues setValue:[NSNumber numberWithFloat:[sprite color].r] forKey:@"colorR"];
			[childValues setValue:[NSNumber numberWithFloat:[sprite color].g] forKey:@"colorG"];
			[childValues setValue:[NSNumber numberWithFloat:[sprite color].b] forKey:@"colorB"];
			[childValues setValue:[NSNumber numberWithFloat:[sprite rotation]] forKey:@"rotation"];
			[childValues setValue:[NSNumber numberWithBool:[sprite isRelativeAnchorPoint]] forKey:@"relativeAnchor"];
			[children addObject:childValues];
		}
	}
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
	[dict setValue:bg forKey:@"background"];
	[dict setValue:children forKey:@"children"];
	
	return [NSDictionary dictionaryWithDictionary:dict];
}

- (void)saveProjectToFile:(NSString *)filename
{
	NSDictionary *dict = [self dictionaryFromLayerForBaseDirPath:[filename stringByDeletingLastPathComponent]];
	[dict writeToFile:filename atomically:YES];
}

#pragma mark IBActions - Windows

- (IBAction)openInfoPanel:(id)sender
{
	[infoPanel_ makeKeyAndOrderFront:nil];
	[infoPanel_ setLevel:[[[[CCDirector sharedDirector] openGLView] window] level]+1];
}

- (IBAction) openSpritesPanel: (id) sender
{
	[spritesPanel_ makeKeyAndOrderFront: nil];
	[spritesPanel_ setLevel:[[[[CCDirector sharedDirector] openGLView] window] level]+1];
}

- (IBAction)openMainWindow:(id)sender
{
	[[[[CCDirector sharedDirector] openGLView] window] makeKeyAndOrderFront:nil];
	[infoPanel_ setLevel:NSNormalWindowLevel];
	[spritesPanel_ setLevel:NSNormalWindowLevel];
}

#pragma mark IBActions - Save/Load

// if we're opened a file - we can revert to saved and save without save as
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	// "Save"
	if ([menuItem action] == @selector(saveProject:))
		return YES;
	
	// "Revert to Saved"
	if ([menuItem action] == @selector(saveProject:))
	{
		if (self.projectFilename)
			return YES;
		return NO;
	}
	
	return YES;
}

- (IBAction)saveProject:(id)sender
{
	if (! self.projectFilename) 
	{
		[self saveProjectAs: sender];
		return;
	}
	
	[self saveProjectToFile:self.projectFilename];
}


- (IBAction)saveProjectAs:(id)sender
{	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"csd", @"ccb", nil]];
	
	// handle the save panel
	[savePanel beginSheetModalForWindow:[[[CCDirector sharedDirector] openGLView] window] completionHandler:^(NSInteger result) {
		if(result == NSOKButton)
		{
			NSString *file = [savePanel filename];
			[self saveProjectToFile:file];
		}
	}];
}

- (IBAction)openProject:(id)sender
{
	// initialize panel + set flags
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"csd"]];
	[openPanel setAllowsOtherFileTypes:NO];	
	
	// handle the open panel
	[openPanel beginSheetModalForWindow:[[[CCDirector sharedDirector] openGLView] window] completionHandler:^(NSInteger result) {
		if(result == NSOKButton)
		{
			NSArray *files = [openPanel filenames];
			NSString *file = [files objectAtIndex:0];
			NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];
			
			if(dict)
			{
				[mainLayer_ loadProjectFromDictionarySafely:dict];
				self.projectFilename = file;
			}
		}
	}];
}

- (IBAction)revertToSavedProject:(id)sender
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:self.projectFilename];
	[mainLayer_ loadProjectFromDictionarySafely:dict];
}

#pragma mark IBActions - Sprites

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
	
	// handle the open panel
	[openPanel beginSheetModalForWindow:[[[CCDirector sharedDirector] openGLView] window] completionHandler:^(NSInteger result) {
		if(result == NSOKButton)
		{
			NSArray *files = [openPanel filenames];
			
			[self addSpritesWithFilesSafely: files];
		}
	}];
}

- (IBAction)spriteAddButtonClicked:(id)sender
{
	[self addSprite:sender];
}

- (IBAction)spriteDeleteButtonClicked:(id)sender
{
	NSInteger index =  [spriteTableView_ selectedRow];
	NSArray *values = [modelObject_ spriteArray];
	
	if ( values && (index >= 0) && (index < [values count]) )
	{
		CSSprite *sprite = [values objectAtIndex:index];
		[self deleteSprite:sprite];
	}
}

#pragma mark IBActions - Zoom

- (IBAction)resetZoom:(id)sender
{
	[(CSMacGLView *)[[CCDirector sharedDirector] openGLView] resetZoom];
}

@end
