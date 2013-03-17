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
#import "PenContext.h"


#define CONVERT_POINT_TO_VIEW(point) [self convertPoint:point fromView:nil]

@implementation DrawingView(Private)

-(double) getMainScreenRefreshRate
{
    double refreshRate = MIN_REFRESH_RATE; // Assume LCD screen
    
    CGDirectDisplayID displayID = CGMainDisplayID();
    CGDisplayModeRef display = CGDisplayCopyDisplayMode(displayID);
    refreshRate = CGDisplayModeGetRefreshRate(display);
    CGDisplayModeRelease(display);
    return refreshRate ? refreshRate : MIN_REFRESH_RATE;
}


-(void) _strokePathPoints:(NSBezierPath*) path
{	
    NSUInteger count = [path elementCount];
	NSPoint lastPt;
	NSPoint points[3];
    
    double defaultWidth = [NSBezierPath defaultLineWidth];
    [NSBezierPath setDefaultLineWidth:[path lineWidth]];
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetLineWidth(context, [path lineWidth]);
    //NSPoint pts[2];
    
    for (int i = 0; i < count; ++i)
    {
        
		NSBezierPathElement element = [path elementAtIndex:i associatedPoints:points];
        
		switch (element) {
			case NSMoveToBezierPathElement:
				lastPt = points[0];
				break;
			case NSLineToBezierPathElement:
                [NSBezierPath strokeLineFromPoint:lastPt toPoint:points[0]];
//                pts[0] = lastPt;
//                pts[1] = points[0];
//                CGContextStrokeLineSegments(context, pts, 2);
				lastPt = points[0];
				break;
                
			default:
				break;
		}
    }
    
    [NSBezierPath setDefaultLineWidth: defaultWidth];
    CGContextSetLineWidth(context, defaultWidth);
}


-(void) _strokeLineFromPoint:(NSPoint) pt1 to:(NSPoint)pt2 withContext:(CGContextRef) context
{
    NSPoint pts[2];
    pts[0] = pt1;
    pts[1] = pt2;
    CGContextStrokeLineSegments(context, pts, 2);
}



-(NSRect) createNSRectFromPointArray:(NSPointArray) pointsArray count:(NSUInteger) pointCount
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
    NSRect rect = NSMakeRect(xmin-penContext.penWidth/2-INFLATION , ymin-penContext.penWidth/2-INFLATION, xmax - xmin + penContext.penWidth + INFLATION, ymax - ymin + penContext.penWidth + INFLATION);
    
    return rect;
}


@end



@implementation NSColor(Helper)

-(NSColor*) getDarkerColorByPercent:(CGFloat) fPercent
{
    double fRed = [self redComponent] * fPercent;
    double fGreen = [self greenComponent] * fPercent;
    double fBlue = [self blueComponent] * fPercent;
    double fAlpha = [self alphaComponent];
    
    return [NSColor colorWithDeviceRed:fRed green:fGreen blue:fBlue alpha:fAlpha];
}


-(NSColor*) getLighterColorByPercent:(CGFloat) fPercent
{
    double fRed = [self redComponent] * (1 + fPercent);
    double fGreen = [self greenComponent] * (1 + fPercent);
    double fBlue = [self blueComponent] * (1 + fPercent);
    double fAlpha = [self alphaComponent];
    
    return [NSColor colorWithDeviceRed:fRed green:fGreen blue:fBlue alpha:fAlpha];
}

+(NSColor*) getRandomColor
{
    NSColor* color = [NSColor colorWithDeviceRed:((float)rand()/(float)RAND_MAX) green: ((float)rand()/(float)RAND_MAX) blue: ((float)rand()/(float)RAND_MAX) alpha:1.0];
    return color;
}


@end



@implementation DrawingView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        currentPath = nil;
        paths = [[NSMutableArray alloc] init];
        penContext = [[PenContext alloc] init];

        [NSBezierPath setDefaultFlatness:0.2];
        [NSBezierPath setDefaultLineWidth: penContext.penWidth];
        [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
        [NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
        
		m_pPointFilterChain.reset(new CPointFilterChain());
		m_pPointFilterChain->AppendFilter(new CMovingExpAverageFilter());
		m_pPointFilterChain->AppendFilter(new CCollinearFilter());
        m_pPointFilterChain->AppendFilter(new CMovingExpAverageFilter());
        m_pPointFilterChain->AppendFilter(new CCollinearFilter());
		m_pPointFilterChain->AppendFilter(new CMovingExpAverageFilter());
		m_pPointFilterChain->AppendFilter(new CCollinearFilter());
        m_pPointFilterChain->AppendFilter(new CMovingExpAverageFilter());
        m_pPointFilterChain->AppendFilter(new CCollinearFilter());
//        m_pPointFilterChain->AppendFilter(new CMovingExpAverageFilter());
//        m_pPointFilterChain->AppendFilter(new CCollinearFilter());
        
        m_pStartEndCapFilter.reset(new CPointFilterChain());
		m_pStartEndCapFilter->AppendFilter(new CMovingExpAverageFilter());
		m_pStartEndCapFilter->AppendFilter(new CCollinearFilter()); 
        
        
        invalidateRect = frame;

        std::srand((unsigned)time(0));

        NSTimeInterval rate = [self getMainScreenRefreshRate];
        [[NSTimer scheduledTimerWithTimeInterval:1/rate target:self selector:@selector(redraw) userInfo:nil repeats:YES] fire]; 
        
    }
    return self;
}

-(void) awakeFromNib
{
    penContext.penWidth = DEFAULT_PEN_WIDTH;
    penContext.color = DEFAULT_PEN_COLOR;
}
    
#pragma mark Responder API

-(BOOL) acceptsFirstResponder
{
	return YES;
}

-(BOOL) acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

-(BOOL) resignFirstResponder
{
	return YES;
}


- (void)changeColor:(id)sender
{
    penContext.color = [sender color];
}


-(void)changePenWidth:(id)sender
{
    penContext.penWidth = [sender doubleValue];
}

#pragma mark Drawing API


-(void) redraw
{
    [self setNeedsDisplayInRect:invalidateRect];
    invalidateRect = NSZeroRect;
}


-(void) drawRect:(NSRect)dirtyRect
{
    NSRectClip(dirtyRect);
    
    //clear everything
    {
        [[NSColor whiteColor] set];
        NSRectFill(dirtyRect);
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


#if 0
-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    NSGraphicsContext* nsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
    
    [nsContext setShouldAntialias:NO];
    
    [NSGraphicsContext setCurrentContext:nsContext];
    //clear everything
    {
        [[NSColor whiteColor] set];
        NSRectFill(self.frame);
    }
    
    
    [[NSColor redColor] set];
    
    
	for(Path* path in paths)
	{
		[self drawPath:path inContext:[NSGraphicsContext currentContext]];
	}
}
#endif

-(void) drawPath:(Path*) path inContext:(NSGraphicsContext*) context
{
	
	[context setShouldAntialias:YES];
	
    CGContextRef cgContext = (CGContextRef)[context graphicsPort];

    CGContextSetBlendMode(cgContext, kCGBlendModeMultiply);
	[[path.color colorWithAlphaComponent:0.7] set];
    CGFloat fPenWidth = [path lineWidth];
    [path setLineWidth: fPenWidth+3];
	[path stroke];
    
    [path setLineWidth: fPenWidth];

    [[path.color colorWithAlphaComponent:0.2] set];
	
	CGContextSetBlendMode(cgContext, kCGBlendModeSourceAtop);

	[self _strokePathPoints:path];
}

#pragma mark Event API

-(void) mouseDown:(NSEvent *)theEvent
{
    [currentPath release];
    currentPath = [[Path alloc] init];
    
    currentPath.color = penContext.color; //[NSColor getRandomColor];
    
    [currentPath setLineWidth: penContext.penWidth];
    [currentPath setLineJoinStyle:NSRoundLineJoinStyle];
    [currentPath setLineCapStyle:NSRoundLineCapStyle];
    [currentPath setFlatness:0.2];
	NSPoint point = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
	m_pPointFilterChain->StartFilter(point.x, point.y);
	m_pPointFilterChain->ClearOutputBuffer();

    m_pStartEndCapFilter->StartFilter(point.x, point.y);
	m_pStartEndCapFilter->ClearOutputBuffer();
    
    [paths addObject:currentPath];
    
    [currentPath moveToPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])];
	[currentPath lineToPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])];
    
    invalidateRect = NSUnionRect(invalidateRect, NSMakeRect(point.x - [currentPath lineWidth]/2 - INFLATION, point.y - [currentPath lineWidth]/2 - INFLATION, [currentPath lineWidth] * 2 + INFLATION, [currentPath lineWidth] * 2 + INFLATION ));
}


-(void) mouseDragged:(NSEvent *)theEvent
{
	if (m_pPointFilterChain.get() && m_pStartEndCapFilter.get())
	{
		NSPoint point = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
		
		m_pPointFilterChain->MoveFilter(point.x, point.y);
        m_pStartEndCapFilter->MoveFilter(point.x, point.y);
		
        std::vector<PointF> &outPts = m_pPointFilterChain->GetOutputBuffer();
        NSPointArray pts = NULL;
        
        pts = new NSPoint[outPts.size()];
        for (int i=0; i<outPts.size(); ++i)
        {
            NSPoint pt = NSMakePoint(outPts[i].X, outPts[i].Y);
            [currentPath lineToPoint:pt];
            pts[i] = pt;
        }
		
        invalidateRect = NSUnionRect(invalidateRect, [self createNSRectFromPointArray:pts count:outPts.size()]);
		m_pPointFilterChain->ClearOutputBuffer();
        m_pStartEndCapFilter->ClearOutputBuffer();
		delete []pts;
	}	
}


-(void) mouseUp:(NSEvent *)theEvent
{
    NSPoint point = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
    
    m_pPointFilterChain->EndFilter(point.x, point.y);
    m_pPointFilterChain->ClearOutputBuffer();
    
    m_pPointFilterChain->EndFilter(point.x, point.y);
    m_pPointFilterChain->ClearOutputBuffer();
}


-(void) dealloc
{
    [currentPath release];
    [paths release];
    [penContext release];
    m_pStartEndCapFilter.reset();
	m_pPointFilterChain.reset();
	[super dealloc];
}


-(void)clear:(id)sender
{
    [paths removeAllObjects];
    [self setNeedsDisplay:YES];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
	[NSMenu popUpContextMenu:contextMenu withEvent:theEvent forView:self];
}

@end


