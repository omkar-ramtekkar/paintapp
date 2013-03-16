//
//  Path.h
//  PaintApp
//
//  Created by Om on 26/02/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface Path : NSBezierPath
{
    NSColor* color;
    Path* effectPath;
}

@property (retain) NSColor* color;

@end
