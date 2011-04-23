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
@class HelloWorldLayer;
@class CSTableViewDataSource;

@interface CSObjectController : NSObjectController
{
    CSModel *modelObject_;
	HelloWorldLayer *cocosView_;
	CSTableViewDataSource *dataSource_;
	
	IBOutlet NSPanel *infoPanel_;
	IBOutlet NSPanel *spritesPanel_;
	IBOutlet NSTextField *nameField_;
	IBOutlet NSTextField *posXField_;
	IBOutlet NSStepper *posXStepper_;
	IBOutlet NSTextField *posYField_;
	IBOutlet NSStepper *posYStepper_;
	IBOutlet NSTextField *posZField_;
	IBOutlet NSStepper *posZStepper_;
	IBOutlet NSTextField *anchorXField_;
	IBOutlet NSStepper *anchorXStepper_;
	IBOutlet NSTextField *anchorYField_;
	IBOutlet NSStepper *anchorYStepper_;
	IBOutlet NSTextField *scaleField_;
	IBOutlet NSStepper *scaleStepper_;
	IBOutlet NSButton *flipXButton_;
	IBOutlet NSButton *flipYButton_;
	IBOutlet NSTextField *opacityField_;
	IBOutlet NSSlider *opacitySlider_;
	IBOutlet NSColorWell *colorWell_;
	IBOutlet NSButton *relativeAnchorButton_;
	IBOutlet NSTextField *rotationField_;
	IBOutlet NSSlider *rotationSlider_;
	IBOutlet NSTableView *spriteTableView_;
}

@property(assign) IBOutlet CSModel *modelObject;
@property(nonatomic, retain) HelloWorldLayer *cocosView;

// filters array of filenames, leaving only allowed
- (NSArray *) allowedFilesWithFiles: (NSArray *) files;

// adds sprites will filenames taken from array, doesn't do any filtering
// executes safely on cocos2d thread
- (void) addSpritesSafelyWithFiles: (NSArray *) files;

#pragma mark IBActions
- (void)deleteSpriteWithKey:(NSString *)key;
- (void)spriteTableSelectionDidChange:(NSNotification *)aNotification;
- (void)didChangeSelectedSprite:(NSNotification *)aNotification;


- (IBAction)addSprite:(id)sender;
- (IBAction)openInfoPanel:(id)sender;
- (IBAction) openSpritesPanel: (id) sender;
- (IBAction)spriteAddButtonClicked:(id)sender;
- (IBAction)spriteDeleteButtonClicked:(id)sender;

@end
