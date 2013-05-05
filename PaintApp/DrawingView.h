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
@class PenContext;
@class PatternGenerator;


@interface DrawingView : NSView {
    
    IBOutlet NSMenu* contextMenu;
    NSRect invalidateRect;
    PenContext* penContext;
    
#if _UseLayers
    CGImageRef penMask;
    CALayer* rootLayer;
    PatternGenerator* pattern;
    //CGMutablePathRef cgCurrentPath;
#else
    Path* currentPath;  
    NSMutableArray* paths;
#endif
    
	CPointFilterChainPtr m_pPointFilterChain;
    CPointFilterChainPtr m_pStartEndCapFilter;
}

-(void) drawOilPaintPaths:(NSArray*) oilPaintPaths inContext:(NSGraphicsContext*) pContext;
-(void) drawPath: (Path*) path inContext:(NSGraphicsContext*) context;
- (CGImageRef) createMaskImage;

@end
