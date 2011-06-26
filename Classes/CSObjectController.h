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

#import <Cocoa/Cocoa.h>
#import "cocos2d.h"

@class CSModel;
@class CSSprite;
@class CSMainLayer;
@class CSTableViewDataSource;
@class CSSideViewController;

@interface CSObjectController : NSObjectController
{
    CSModel *modelObject_;
	CSMainLayer *mainLayer_;
	CSTableViewDataSource *dataSource_;
	NSString *projectFilename_;
		
	// Sprites List View	
	IBOutlet NSTableView *spriteTableView_;
	
	// Menus
	IBOutlet NSMenuItem *showBordersMenuItem_;
	
	IBOutlet CSSideViewController *sideViewController_;
}

@property(assign) IBOutlet CSModel *modelObject;
@property(nonatomic, retain) CSMainLayer *mainLayer;
@property(assign) NSTableView *spriteTableView;
@property(copy) NSString *projectFilename;

#pragma mark Sprites

// Changes aSprite.name to unique if modelObject_ already contains sprite with
// the same name.
- (void) ensureUniqueNameForSprite: (CSSprite *) aSprite;

/**
 * filters array of filenames, leaving only allowed
 * @returns The filtered files
 */
- (NSArray *)allowedFilesWithFiles:(NSArray *)files;

/**
 * adds sprites will filenames taken from array, doesn't do any filtering. executes safely on cocos2d thread
 * @param files Filenames of sprites to add
 */
- (void) addSpritesWithFilesSafely:(NSArray *)files;

- (void)deleteSprite:(CSSprite *)sprite;
- (void)deleteAllSprites;

#pragma mark  Notifications
- (void)spriteTableSelectionDidChange:(NSNotification *)aNotification;
- (void)didChangeSelectedSprite:(NSNotification *)aNotification;

#pragma mark Save/Load
- (NSDictionary *)dictionaryFromLayerForBaseDirPath: (NSString *) baseDirPath;
- (void)saveProjectToFile:(NSString *)filename;

#pragma mark IBActions - Save/Load
- (IBAction)saveProject:(id)sender;
- (IBAction)saveProjectAs:(id)sender;
- (IBAction)newProject:(id)sender;
- (IBAction)openProject:(id)sender;
- (IBAction)revertToSavedProject:(id)sender;

#pragma mark IBActions - Sprites
- (IBAction)addSprite:(id)sender;
- (IBAction)spriteAddButtonClicked:(id)sender;
- (IBAction)spriteDeleteButtonClicked:(id)sender;

#pragma mark IBActions - Zoom
- (IBAction)resetZoom:(id)sender;

#pragma mark IBAction - Menus
- (IBAction) showBordersMenuItemPressed: (id) sender;
- (IBAction) deleteMenuItemPressed: (id) sender;
- (IBAction) cutMenuItemPressed: (id) sender;
- (IBAction) copyMenuItemPressed: (id) sender;
- (IBAction) pasteMenuItemPressed: (id) sender;

@end
