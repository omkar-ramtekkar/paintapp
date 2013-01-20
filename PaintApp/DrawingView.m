//
//  DrawingView.m
//  CustomViewDrawing
//
//  Created by omkar_ramtekkar on 13-01-18.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "DrawingView.h"
#import <Quartz/Quartz.h>

#define CONVERT_POINT_TO_VIEW(point) [self convertPoint:point fromView:nil]

const float FPS = 1.0f/50.0;

@implementation DrawingView


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        currentPath = nil;
        paths = [[NSMutableArray alloc] init];
        bClearDisplay = YES;
        
        [NSTimer scheduledTimerWithTimeInterval:FPS target:self selector:@selector(redraw) userInfo:nil repeats:YES];
    }
    return self;
}
         
-(void) redraw
{
    [self setNeedsDisplay:YES];
}
        
-(BOOL) acceptsFirstResponder
{
	return YES;
}

-(BOOL) resignFirstResponder
{
	return YES;
}



- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	
	//clear everything
  //  if(bClearDisplay)
    {
        [[NSColor whiteColor] set];
        [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
    }
	
	
	//if(currentPath)
	{
		CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
		CGContextSetAllowsAntialiasing(context, NO);
		CGContextSetAlpha(context, 0.7f);
		[[NSColor greenColor] set];
		for (NSBezierPath* aPath in paths)
        {
            [aPath stroke];
        }
		
	}	
}



-(void) mouseDown:(NSEvent *)theEvent
{
    assert(currentPath == nil);
    currentPath = [[NSBezierPath alloc] init];
    
    [currentPath setLineWidth:27];
    [currentPath setLineJoinStyle:NSRoundLineJoinStyle];
    [currentPath setLineCapStyle:NSRoundLineCapStyle];
    [currentPath setFlatness:0.2];	
    
    [paths addObject:currentPath];
    bClearDisplay = YES;
    
    lastPoint = [theEvent locationInWindow];

    [currentPath moveToPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])];
}

-(void) mouseDragged:(NSEvent *)theEvent
{
    bClearDisplay = NO;
	//if(points)
	{
		//[points addObject:[NSValue valueWithPoint:[theEvent locationInWindow]]];
        [currentPath lineToPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])];
        lastPoint = [theEvent locationInWindow];
	}
	
}

-(void) mouseUp:(NSEvent *)theEvent
{
	//if(points)
	{
		//[points addObject:[NSValue valueWithPoint:[theEvent locationInWindow]]];
        [currentPath lineToPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])];
        [currentPath release];
        currentPath = nil;
        lastPoint = [theEvent locationInWindow];
	}
}

-(void) dealloc
{
    [currentPath release];
    [paths release];
	[super dealloc];
}

@end
