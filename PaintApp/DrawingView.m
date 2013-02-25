//
//  DrawingView.m
//  CustomViewDrawing
//
//  Created by omkar_ramtekkar on 13-01-18.
//  Copyright 2013 Om's MacBook Pro. All rights reserved.
//

#import "DrawingView.h"
#import <Quartz/Quartz.h>
#include <string>
#import "Path.h"

#define CONVERT_POINT_TO_VIEW(point) [self convertPoint:point fromView:nil]

const float FPS = 1.0f/35.0;
BOOL bDrawGradient = FALSE;

@implementation DrawingView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        currentPath = nil;
        paths = [[NSMutableArray alloc] init];

        [NSBezierPath setDefaultFlatness:0.5];
        [NSBezierPath setDefaultLineWidth:30];
        [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
        [NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
		
		
		IPointFilterPtr pMoveExpAvgFilter = new CMovingExpAverageFilter();
        IPointFilterPtr pMoveExpAvgFilter2 = new CMovingExpAverageFilter();
		IPointFilterPtr pMoveExpAvgFilter3 = new CMovingExpAverageFilter();
        IPointFilterPtr pMoveExpAvgFilter4 = new CMovingExpAverageFilter();
		IPointFilterPtr pCollinearFilter = new CCollinearFilter();
        IPointFilterPtr pCollinearFilter2 = new CCollinearFilter();
		IPointFilterPtr pCollinearFilter3 = new CCollinearFilter();
        IPointFilterPtr pCollinearFilter4 = new CCollinearFilter();
		m_pPointFilterChain = new CPointFilterChain();
		m_pPointFilterChain->AppendFilter(pMoveExpAvgFilter);
		m_pPointFilterChain->AppendFilter(pCollinearFilter);
        m_pPointFilterChain->AppendFilter(pMoveExpAvgFilter2);
        m_pPointFilterChain->AppendFilter(pCollinearFilter2);
		m_pPointFilterChain->AppendFilter(pMoveExpAvgFilter3);
		m_pPointFilterChain->AppendFilter(pCollinearFilter3);
        m_pPointFilterChain->AppendFilter(pMoveExpAvgFilter4);
        m_pPointFilterChain->AppendFilter(pCollinearFilter4);
         
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

-(void) drawRect:(NSRect)dirtyRect
{
    //clear everything
    {
        [[NSColor whiteColor] set];
        [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
    }

    if(!currentPath)
        return;
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];

    [[NSColor redColor] set];
    
    CGContextSetShouldAntialias(context, YES);
    
	for(Path* path in paths)
	{
		[self drawPath:path inContext:[NSGraphicsContext currentContext]];
	}
	
}

-(void) drawPath:(Path*) path inContext:(NSGraphicsContext*) context
{
	
	[NSGraphicsContext saveGraphicsState];
	[context setShouldAntialias:YES];
	
    NSColor* color = path.color;
    
	[[color colorWithAlphaComponent:0.7] set];
	
    [path setLineWidth:33];
	[path stroke];
    [path setLineWidth:30];
	
    [[color colorWithAlphaComponent:0.1] set];
	
	NSUInteger count = [path elementCount];
	NSPoint lastPt;
	NSPoint points[3];
	
	CGContextRef cgContext = (CGContextRef)[context graphicsPort];
	CGContextSetBlendMode(cgContext, kCGBlendModeMultiply);
	
    for (int i = 0; i < count; ++i)
    {
		NSBezierPathElement element = [path elementAtIndex:i associatedPoints:points];

		switch (element) {
			case NSMoveToBezierPathElement:
				lastPt = points[0];
				break;
			case NSLineToBezierPathElement:
                [NSBezierPath strokeLineFromPoint:lastPt toPoint:points[0]];
				
				lastPt = points[0];
				break;

			default:
				break;
		}
    }
	
	[NSGraphicsContext restoreGraphicsState];
}

-(void) mouseDown:(NSEvent *)theEvent
{
  
    [currentPath release];
    currentPath = [[Path alloc] init];
    
    NSColor* color = [NSColor colorWithDeviceRed:((float)rand()/(float)RAND_MAX) green: ((float)rand()/(float)RAND_MAX) blue: ((float)rand()/(float)RAND_MAX) alpha:1.0];
    
    currentPath.color = color;
    
    [currentPath setLineWidth:30];
    [currentPath setLineJoinStyle:NSRoundLineJoinStyle];
    [currentPath setLineCapStyle:NSRoundLineCapStyle];
    [currentPath setFlatness:0.8];	
	NSPoint point = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
	m_pPointFilterChain->StartFilter(point.x, point.y);
	m_pPointFilterChain->ClearOutputBuffer();
    
    [paths addObject:currentPath];
    
    [currentPath moveToPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])];
}

-(void) mouseDragged:(NSEvent *)theEvent
{
	if (m_pPointFilterChain)
	{
		NSPoint point = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
		
		m_pPointFilterChain->MoveFilter(point.x, point.y);
		
		std::vector<PointF> &outPts = m_pPointFilterChain->GetOutputBuffer();
		NSPointArray pts = new NSPoint[outPts.size()];
		for (int i=0; i<outPts.size(); ++i)
		{
			NSPoint pt = NSMakePoint(outPts[i].X, outPts[i].Y);
            [currentPath lineToPoint:pt];
			pts[i] = pt;
		}
		
		[self setNeedsDisplayInRect: [self createNSRectFrom:pts withSize:outPts.size()]];
		m_pPointFilterChain->ClearOutputBuffer();
		delete []pts;
	}	
	
	
}

-(void) mouseUp:(NSEvent *)theEvent
{
    NSPoint point = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
    m_pPointFilterChain->EndFilter(point.x, point.y);
    m_pPointFilterChain->ClearOutputBuffer();
}

-(void) dealloc
{
    [currentPath release];
    [paths release];
	delete m_pPointFilterChain;
	m_pPointFilterChain = NULL;
	[super dealloc];
}



-(NSRect) createNSRectFrom:(NSPointArray) pointsArray withSize:(NSUInteger) pointCount
{
    // start by initializing their opposite MIN/MAX values
    CGFloat xmin = CGFLOAT_MAX, xmax = CGFLOAT_MIN,
    ymin = CGFLOAT_MAX, ymax = CGFLOAT_MIN;
    
    for (NSUInteger i = 0; i < pointCount; i++) {
        xmin = MIN(xmin, pointsArray[i].x);
        xmax = MAX(xmax, pointsArray[i].x);
        ymin = MIN(ymin, pointsArray[i].y);
        ymax = MAX(ymax, pointsArray[i].y);
    }
    
    // now create a rect from those points
    NSRect rect = NSMakeRect(xmin-30, ymin-30, xmax - xmin + 50, ymax - ymin + 50);
    
    return rect;
}


@end
