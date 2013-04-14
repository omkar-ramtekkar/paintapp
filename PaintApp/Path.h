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
}

@property (retain) NSColor* color;

@end
