//
//  MainToolbarManager.m
//  PaintApp
//
//  Created by Om on 17/03/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MainToolbarManager.h"

static NSString* ToolbarPenWidthIdentifier = @"ToolbarPenWidthIdentifier";
static NSString* ToolbarClearAllInkIdentifier = @"ToolbarClearAllInkIdentifier";

@implementation MainToolbarManager

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
    return [NSArray arrayWithObjects:
            NSToolbarPrintItemIdentifier,
            NSToolbarShowColorsItemIdentifier,
            NSToolbarShowFontsItemIdentifier,
            NSToolbarCustomizeToolbarItemIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier,
            NSToolbarSpaceItemIdentifier,
            NSToolbarSeparatorItemIdentifier, nil];
}


- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar {
    return [NSArray arrayWithObjects:
            NSToolbarPrintItemIdentifier,
            NSToolbarSeparatorItemIdentifier,
            NSToolbarShowColorsItemIdentifier,
            NSToolbarSeparatorItemIdentifier,
            ToolbarPenWidthIdentifier,
            NSToolbarSeparatorItemIdentifier,
            ToolbarClearAllInkIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier,
            NSToolbarCustomizeToolbarItemIdentifier,
            nil];
}

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar
      itemForItemIdentifier:(NSString *)itemIdentifier
  willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier] autorelease];
    
    if ([itemIdentifier isEqualToString:ToolbarPenWidthIdentifier])
    {
        NSSlider* slider = [[NSSlider alloc] initWithFrame:NSZeroRect];
        [slider setMaxValue:PEN_MAX_WIDTH];
        [slider setMinValue:PEN_MIN_WIDTH];
        [slider setDoubleValue:DEFAULT_PEN_WIDTH];
        [slider setAction:@selector(changePenWidth:)];
        
        
        
        [toolbarItem setMaxSize:NSMakeSize(100, 20)];
        [toolbarItem setMinSize:NSMakeSize(100, 20)];
        [toolbarItem setPaletteLabel:@"Pen Width"];
        [toolbarItem setLabel:@"Pen Width"];
        [toolbarItem setView:slider];
    }
    else if([itemIdentifier isEqualToString:ToolbarClearAllInkIdentifier])
    {
        [toolbarItem setPaletteLabel:@"Clear All"];
        [toolbarItem setLabel:@"Clear All"];
        [toolbarItem setAction:@selector(clear:)];
        [toolbarItem setImage:[NSImage imageNamed:@"ClearInk"]];
    }
    
    return toolbarItem;
}

@end
