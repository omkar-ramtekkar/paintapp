//
//  DrawingView.h
//  CustomViewDrawing
//
//  Created by omkar_ramtekkar on 13-01-18.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DrawingView : NSView {
    NSBezierPath* currentPath;
    NSPoint lastPoint;
    BOOL bClearDisplay;
    
    NSMutableArray* paths;
    


}

@end
