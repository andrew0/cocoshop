//
//  CSPreferencesWindowController.h
//  cocoshop
//
//  Created by andrew on 10/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"

@interface CSPreferencesWindowController : DBPrefsWindowController
{
    IBOutlet NSView *_general;
    IBOutlet NSView *_advanced;
}

@end
