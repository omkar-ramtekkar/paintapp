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

#define CONVERT_POINT_TO_VIEW(point) [self convertPoint:point fromView:nil]

const float FPS = 1.0f/25.0;
BOOL bDrawGradient = FALSE;

static NSImage* anImage = nil ;

@implementation DrawingView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        currentPath = nil;
        paths = [[NSMutableArray alloc] init];
        bClearDisplay = YES;
        anImage = [NSImage imageNamed:@"myimage2.png"];
        points = nil;
        
    
        NSArray *properties = [CIFilter filterNamesInCategory:
                               kCICategoryBuiltIn];
        NSLog(@"%@", properties);
        for (NSString *filterName in properties) {
            CIFilter *fltr = [CIFilter filterWithName:filterName];
            NSLog(@"%@", [fltr attributes]);
        }
        
        timer = nil;
        [NSBezierPath setDefaultFlatness:0.5];
        [NSBezierPath setDefaultLineWidth:30];
        [NSBezierPath setDefaultLineJoinStyle:NSSquareLineCapStyle];
        [NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
		
		
		IPointFilterPtr pMoveExpAvgFilter = new CMovingExpAverageFilter();
        IPointFilterPtr pMoveExpAvgFilter2 = new CMovingExpAverageFilter();
		IPointFilterPtr pCollinearFilter = new CCollinearFilter();
        IPointFilterPtr pCollinearFilter2 = new CCollinearFilter();
		m_pPointFilterChain = new CPointFilterChain();
		m_pPointFilterChain->AppendFilter(pMoveExpAvgFilter);
        m_pPointFilterChain->AppendFilter(pMoveExpAvgFilter2);
		m_pPointFilterChain->AppendFilter(pCollinearFilter);
        m_pPointFilterChain->AppendFilter(pCollinearFilter2);
		
         
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
    
    if(!currentPath)
        return;
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];

    CGContextSaveGState(context);
    //clear everything
    {
        [[NSColor whiteColor] set];
        [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
    }

    
    CGContextClipToRect(context, dirtyRect);

    
    double lineWidth = [currentPath lineWidth];
    NSRect rect = [currentPath bounds];
    rect.origin.x -= lineWidth;
    rect.origin.y -= lineWidth;
    rect.size.width += 2 * lineWidth;
    rect.size.height += 2 * lineWidth;
    
   // NSImage* pathImage = [[NSImage alloc] initWithSize:rect.size];
    
    //[pathImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    
    [[NSColor clearColor] set];
    [[NSBezierPath bezierPathWithRect:rect] fill];
    
    [[NSColor redColor] set];
    
    

   // CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-rect.origin.x , -rect.origin.y ));
   
    //[currentPath stroke];

    CGContextSetShouldAntialias(context, NO);

    int i = 0;
    NSPoint lastPoint;
    for (NSValue* value in points)
    {
        if(i == 0)
        {
            lastPoint = [value pointValue];
        }
        else
        {
			//CGContextSaveGState(context);
			CGContextSetAlpha(context, 0.1);
            NSPoint currentPoint = [value pointValue];
			[NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
			[NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
			[NSBezierPath setDefaultLineWidth:30];
            [NSBezierPath strokeLineFromPoint:lastPoint toPoint:currentPoint];
			
			[NSBezierPath setDefaultLineCapStyle:NSSquareLineCapStyle];
			[NSBezierPath setDefaultLineWidth:20];
			[NSBezierPath strokeLineFromPoint:lastPoint toPoint:currentPoint];
			
			CGContextSetAlpha(context, 0.1);
			
			[NSBezierPath setDefaultLineWidth:15];
			[NSBezierPath setDefaultLineCapStyle:NSButtLineCapStyle];
			[NSBezierPath strokeLineFromPoint:lastPoint toPoint:currentPoint];
			
			[NSBezierPath setDefaultLineCapStyle:NSSquareLineCapStyle];
			[NSBezierPath setDefaultLineWidth:10];
			[NSBezierPath strokeLineFromPoint:lastPoint toPoint:currentPoint];
			//CGContextRestoreGState(context);
			
			//CGContextSaveGState(context);
			CGContextSetAlpha(context, 0.1);
			//[[NSColor redColor] set];
			[NSBezierPath setDefaultLineCapStyle:NSSquareLineCapStyle];
			[NSBezierPath setDefaultLineWidth:1];
			[NSBezierPath strokeLineFromPoint:lastPoint toPoint:currentPoint];
			//CGContextRestoreGState(context);
		
			
            lastPoint = currentPoint;
            
        }
        ++i;
    }
    
    CGContextRestoreGState(context);
    
   // [pathImage unlockFocus];
    
    //[pathImage drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    //[pathImage release];
}

-(void) mouseDown:(NSEvent *)theEvent
{
    timer = [NSTimer scheduledTimerWithTimeInterval:FPS target:self selector:@selector(redraw) userInfo:nil repeats:YES];
    
    [timer retain];
    
    [points release];
    points = [[NSMutableArray alloc] init];
    //[points addObject:[NSValue valueWithPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])]];
    bDrawGradient = FALSE;
    [currentPath release];
    currentPath = [[NSBezierPath alloc] init];
    
    [currentPath setLineWidth:30];
    [currentPath setLineJoinStyle:NSRoundLineJoinStyle];
    [currentPath setLineCapStyle:NSRoundLineCapStyle];
    [currentPath setFlatness:0.8];	
	NSPoint point = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
	m_pPointFilterChain->StartFilter(point.x, point.y);
	m_pPointFilterChain->ClearOutputBuffer();
    
    [paths addObject:currentPath];
    bClearDisplay = YES;
    
    [currentPath moveToPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])];
}

-(void) mouseDragged:(NSEvent *)theEvent
{
    bClearDisplay = NO;
	//if(points)
	{
		//[points addObject:[NSValue valueWithPoint:[theEvent locationInWindow]]];
        [currentPath lineToPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])];
        //[points addObject:[NSValue valueWithPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])]];
	}
	
	
	if (m_pPointFilterChain)
	{
		NSPoint point = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
		
		m_pPointFilterChain->MoveFilter(point.x, point.y);
		
		std::vector<PointF> &outPts = m_pPointFilterChain->GetOutputBuffer();
		
		for (int i=0; i<outPts.size(); ++i)
		{
			[points addObject:[NSValue valueWithPoint:NSMakePoint(outPts[i].X, outPts[i].Y)]];
		}
		
		m_pPointFilterChain->ClearOutputBuffer();
		
	}	
	
}

-(void) mouseUp:(NSEvent *)theEvent
{
    bDrawGradient = YES;
	//if(points)
	{
		//[points addObject:[NSValue valueWithPoint:[theEvent locationInWindow]]];
        [currentPath lineToPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])];
      //  [points addObject:[NSValue valueWithPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])]];
		NSPoint point = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
		m_pPointFilterChain->EndFilter(point.x, point.y);
	}
    
    [self setNeedsDisplay:YES];
    
    [timer invalidate];
    [timer release];
    timer = nil;
}

-(void) dealloc
{
    [currentPath release];
    [paths release];
    [timer release];
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
    NSRect rect = NSMakeRect(xmin, ymin, xmax - xmin, ymax - ymin);
    
    return rect;
}


@end
