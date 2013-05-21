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

-(void) awakeFromNib
{
    [self.window setFrame:[[NSScreen mainScreen] visibleFrame] display:YES animate:NO];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    srand((unsigned)time(NULL));
    // Insert code here to initialize your application
}


-(void) dealloc
{
    [[NSColorPanel sharedColorPanel] close];
    [super dealloc];
}

@end
