//
//  CSPreferencesWindowController.m
//  cocoshop
//
//  Created by andrew on 10/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CSPreferencesWindowController.h"

@implementation CSPreferencesWindowController

- (void)setupToolbar
{
    [self addView:_general label:@"General" image:[NSImage imageNamed:NSImageNamePreferencesGeneral]];
    [self addView:_advanced label:@"Advanced" image:[NSImage imageNamed:NSImageNameAdvanced]];
    
    [self setCrossFade:NO];
    [self setShiftSlowsAnimation:NO];
}

@end
