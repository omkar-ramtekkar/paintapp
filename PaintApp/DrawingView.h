//
//  DrawingView.h
//  CustomViewDrawing
//
//  Created by omkar_ramtekkar on 13-01-18.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "PointFilter.h"

@class Path;

@interface DrawingView : NSView {
    Path* currentPath;  
    NSMutableArray* paths;
    IBOutlet NSMenu* contextMenu;
    IBOutlet NSTableView* colorView;
    
    NSRect invalidateRect;
    float penWidth;
    NSColor* penColor;
    
	CPointFilterChainPtr m_pPointFilterChain;
}

-(void) drawPath: (Path*) path inContext:(NSGraphicsContext*) context;

@end
