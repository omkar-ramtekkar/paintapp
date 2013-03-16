
//
//  Path.m
//  PaintApp
//
//  Created by Om on 26/02/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Path.h"

@implementation Path

@synthesize color;

- (void)lineToPoint:(NSPoint)point
{
    [super lineToPoint:point];
}

-(void) dealloc
{
    [self.color release];
    [super dealloc];
}
@end
