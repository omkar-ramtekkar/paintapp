//
//  AppDelegate.m
//  PaintApp
//
//  Created by Om on 20/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.window setFrame:[[NSScreen mainScreen] visibleFrame] display:YES animate:YES];
}

@end
