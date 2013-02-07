//
//  DrawingView.h
//  CustomViewDrawing
//
//  Created by omkar_ramtekkar on 13-01-18.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "PointFilter.h"


@interface DrawingView : NSView {
    NSBezierPath* currentPath;
    BOOL bClearDisplay;
    
    NSMutableArray* paths;
    
    NSMutableArray* points;
    
    NSTimer* timer;
	
	CPointFilterChainPtr m_pPointFilterChain;


}


-(NSRect) createNSRectFrom:(NSPointArray) pointsArray withSize:(NSUInteger) pointCount;

@end
