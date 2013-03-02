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

#define MIN_REFRESH_RATE 25
#define CONVERT_POINT_TO_VIEW(point) [self convertPoint:point fromView:nil]
#define INFLATION 3


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
    
    [NSBezierPath setDefaultLineWidth: defaultWidth];
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
    
    
    NSValue* value = [NSValue valueWithRect:NSMakeRect(xmin, ymin, xmax, ymax)];
    NSLog(@"%@", value);
    
    // now create a rect from those points
    NSRect rect = NSMakeRect(xmin-penWidth/2-INFLATION , ymin-penWidth/2-INFLATION, xmax - xmin + penWidth + INFLATION, ymax - ymin + penWidth + INFLATION);
    
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

        [NSBezierPath setDefaultFlatness:1.0];
        [NSBezierPath setDefaultLineWidth:30];
        [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
        [NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
		
		
		m_pPointFilterChain = new CPointFilterChain();
		m_pPointFilterChain->AppendFilter(new CMovingExpAverageFilter());
		m_pPointFilterChain->AppendFilter(new CCollinearFilter());
        m_pPointFilterChain->AppendFilter(new CMovingExpAverageFilter());
        m_pPointFilterChain->AppendFilter(new CCollinearFilter());
		m_pPointFilterChain->AppendFilter(new CMovingExpAverageFilter());
		m_pPointFilterChain->AppendFilter(new CCollinearFilter());
        m_pPointFilterChain->AppendFilter(new CMovingExpAverageFilter());
        m_pPointFilterChain->AppendFilter(new CCollinearFilter());
        m_pPointFilterChain->AppendFilter(new CMovingExpAverageFilter());
        m_pPointFilterChain->AppendFilter(new CCollinearFilter());
        
        
        invalidateRect = frame;
        penWidth = 30;

        std::srand((unsigned)time(0));

        NSTimeInterval rate = [self getMainScreenRefreshRate];
        [[NSTimer scheduledTimerWithTimeInterval:1/rate target:self selector:@selector(redraw) userInfo:nil repeats:YES] fire]; 
        
    }
    return self;
}
    
#pragma mark Responder API

-(BOOL) acceptsFirstResponder
{
	return YES;
}

-(BOOL) resignFirstResponder
{
	return YES;
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

-(void) drawPath:(Path*) path inContext:(NSGraphicsContext*) context
{
	
	[context setShouldAntialias:YES];
	
    CGContextRef cgContext = (CGContextRef)[context graphicsPort];
	CGContextSetBlendMode(cgContext, kCGBlendModeMultiply);

    [path setFlatness:1];
    [path setLineWidth:33];
	
	[[path.color colorWithAlphaComponent:0.6] set];
	[path setFlatness:1];
    [path setLineWidth:33];
	[path stroke];
    [path setLineWidth:30];

    [[path.color colorWithAlphaComponent:0.2] set];
	
	CGContextSetBlendMode(cgContext, kCGBlendModeSourceAtop);

    [path setLineWidth:30];
	[self _strokePathPoints:path];
}

#pragma mark Event API

-(void) mouseDown:(NSEvent *)theEvent
{
    [currentPath release];
    currentPath = [[Path alloc] init];
    
    currentPath.color = [[NSColor getRandomColor] retain];
    
    [currentPath setLineWidth:30];
    [currentPath setLineJoinStyle:NSRoundLineJoinStyle];
    [currentPath setLineCapStyle:NSRoundLineCapStyle];
    [currentPath setFlatness:1.0];
	NSPoint point = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
	m_pPointFilterChain->StartFilter(point.x, point.y);
	m_pPointFilterChain->ClearOutputBuffer();
    
    [paths addObject:currentPath];
    
    [currentPath moveToPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])];
	[currentPath lineToPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])];
    
    invalidateRect = NSUnionRect(invalidateRect, NSMakeRect(point.x - [currentPath lineWidth], point.y - [currentPath lineWidth], [currentPath lineWidth]*1.5, [currentPath lineWidth]*1.5 ));
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
        
        invalidateRect = NSUnionRect(invalidateRect, [self createNSRectFromPointArray:pts count:outPts.size()]);
		
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


-(void)clear:(id)sender
{
    [paths removeAllObjects];
    [self display];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
	[NSMenu popUpContextMenu:contextMenu withEvent:theEvent forView:self];
}

@end


