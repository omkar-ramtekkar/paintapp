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
#import "PatternGenerator.h"
#import "OilPaintLayer.h"

struct DrawingInfo
{
    OilPaintLayer* layer;
    CGImageRef mask;
    PatternGenerator* pattern;
};

#define CONVERT_POINT_TO_VIEW(point) [self convertPoint:point fromView:nil]


#pragma mark --------- Global Function Declaration -----------
void MyCGPathApplierFunc (void *info, const CGPathElement *element);


#pragma mark --------- Global Function Defination -----------


void MyCGPathApplierFunc (void *info, const CGPathElement *element)
{
    DrawingInfo* drawingInfo = (DrawingInfo*) info;
    [NSBezierPath setDefaultLineWidth:drawingInfo->layer.lineWidth];
    
    NSCompositingOperation op = [[NSGraphicsContext currentContext] compositingOperation];
    [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceOver];

    CGPoint lastPt;
    switch (element->type) {
        case kCGPathElementMoveToPoint:
            lastPt = element->points[0];
            break;
        case kCGPathElementAddLineToPoint:
        {
            [NSBezierPath strokeLineFromPoint:lastPt toPoint:element->points[0]];
            
            NSUInteger* pattern = [drawingInfo->pattern getPatternForStrokeWidth:drawingInfo->layer.lineWidth forLocation:lastPt];
            
            CGPoint ptStart = lastPt;

            
            CGPoint ptEnd = element->points[0];
            
            int dx = abs(ptStart.x - ptEnd.x);
            int dy = abs(ptStart.y - ptEnd.y);
            
            if (dx < dy) // dx == 0 line is vertical, dx < dy line is vertically inclined
            {
                ptStart.x -= drawingInfo->layer.lineWidth/2;
                ptEnd.x -= drawingInfo->layer.lineWidth/2;
            }
            else
            {
                ptStart.y -= drawingInfo->layer.lineWidth/2;
                ptEnd.y -= drawingInfo->layer.lineWidth/2;
            }
            
            [NSBezierPath setDefaultLineWidth:0.25];
            
            for (unsigned int i=0; i<(NSUInteger)drawingInfo->layer.lineWidth/2; ++i)
            {
                {
                    if(pattern[i])
                    {
                        [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeDestinationIn];
                        [NSBezierPath strokeLineFromPoint:ptStart toPoint: ptEnd];
                    }
                    
                    if (dx < dy)
                    {
                        ptStart.x += 2;
                        ptEnd.x += 2;
                    }
                    else
                    {
                        ptStart.y += 2;
                        ptEnd.y += 2;
                    }
                }
            }
                        
            [[NSGraphicsContext currentContext] setCompositingOperation:op];
            lastPt = element->points[0];
        }
        default:
            break;
    }
}

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

- (CGColorRef)CGColor
{
    const NSInteger numberOfComponents = [self numberOfComponents];
    CGFloat components[numberOfComponents];
    CGColorSpaceRef colorSpace = [[self colorSpace] CGColorSpace];
    
    [self getComponents:(CGFloat *)&components];
    
#ifdef __OBJC_GC__  
    return (CGColorRef)CFMakeCollectable(CGColorCreate(colorSpace, components));
#else
    return (CGColorRef)[(id)CGColorCreate(colorSpace, components) autorelease];
#endif
}

+ (NSColor *)colorWithCGColor:(CGColorRef)CGColor
{
    if (CGColor == NULL) return nil;
    return [NSColor colorWithCIColor:[CIColor colorWithCGColor:CGColor]];
}


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
        penContext = [[PenContext alloc] init];
        
		m_pPointFilterChain.reset(new CPointFilterChain());
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
        
        m_pStartEndCapFilter.reset(new CPointFilterChain());
		m_pStartEndCapFilter->AppendFilter(new CMovingExpAverageFilter());
		m_pStartEndCapFilter->AppendFilter(new CCollinearFilter()); 
        
        
        invalidateRect = NSZeroRect;

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
    
    [NSBezierPath setDefaultFlatness:0.2];
    [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
    [NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
    
#if _UseLayers
    rootLayer = [[CALayer layer] retain];
    rootLayer.backgroundColor = [[NSColor whiteColor] CGColor];
    rootLayer.bounds = self.frame;//NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
    rootLayer.position = NSMakePoint(NSMidX(self.frame), NSMidY(self.frame));
    rootLayer.borderColor = [[NSColor redColor] CGColor];
    rootLayer.borderWidth = 3;
    viewImage = nil;
    
    pattern = [[PatternGenerator alloc] init];
    
    [self setLayerContentsRedrawPolicy: NSViewLayerContentsRedrawOnSetNeedsDisplay];
    [self setLayer: rootLayer];
    [self setWantsLayer:YES];
    [rootLayer setNeedsDisplay];
    [self setNeedsDisplay:YES];
    
#else
    currentPath = nil;
    paths = [[NSMutableArray alloc] init];  
    [NSBezierPath setDefaultFlatness:0.2];
    [NSBezierPath setDefaultLineWidth: penContext.penWidth];
    [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
    [NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
#endif

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

#if _UseLayers
-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{    
    if ([layer.name isEqualToString:@"PenCreationalLayer"])
    {
        NSGraphicsContext* nsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
        
        [nsContext setShouldAntialias:YES];
    
        
        [NSGraphicsContext setCurrentContext:nsContext];
        [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceOver];
        
        if ([viewImage.name isEqualToString:@"Drawn"])
        {
            NSLog(@"DrawLayer : Only Image Draw");
            [viewImage drawInRect:layer.frame fromRect:NSMakeRect(0, 0, viewImage.size.width, viewImage.size.height) operation:NSCompositeSourceOver fraction:1.0];
            
            return;           
        }
        else if([viewImage.name isEqualToString:@"LayerDraw"])
        {
            NSLog(@"DrawLayer : Layer Image Draw");
            [viewImage drawInRect:layer.frame fromRect:NSMakeRect(0, 0, viewImage.size.width, viewImage.size.height) operation:NSCompositeSourceOver fraction:1.0];
        }
        
        
        
        
        OilPaintLayer* shapeLayer = (OilPaintLayer*) layer;
        
        CGContextRef cgContext = ctx;
        
        CGContextSetBlendMode(cgContext, kCGBlendModeMultiply);
        [[[NSColor colorWithCGColor:shapeLayer.strokeColor] colorWithAlphaComponent:0.6] set];
        CGFloat fPenWidth = shapeLayer.bezierPath.lineWidth;
        [shapeLayer.bezierPath setLineWidth: fPenWidth + 4];
        [shapeLayer.bezierPath stroke];
        
        [shapeLayer.bezierPath setLineWidth: fPenWidth];
        
        [[[NSColor colorWithCGColor:shapeLayer.strokeColor] colorWithAlphaComponent:0.3] set];
        
        CGContextSetBlendMode(cgContext, kCGBlendModeSourceAtop);
        
        CGContextSaveGState(cgContext);
        CGContextSetLineWidth(cgContext, shapeLayer.lineWidth);
        CGContextSetBlendMode(cgContext, kCGBlendModeSoftLight);
        DrawingInfo info = {shapeLayer, penMask, pattern};
        CGPathApply(shapeLayer.path, &info, MyCGPathApplierFunc);
        CGContextRestoreGState(cgContext);
    }
    
}

- (NSImage *)imageWithSubviews
{
    NSSize mySize = self.bounds.size;
    NSSize imgSize = NSMakeSize( mySize.width, mySize.height );
    
    NSBitmapImageRep *bir = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
    [bir setSize:imgSize];
    [self cacheDisplayInRect:[self bounds] toBitmapImageRep:bir];
    
    NSImage* image = [[[NSImage alloc]initWithSize:imgSize] autorelease];
    [image addRepresentation:bir];
    return image;
}

#else
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
    
    
    [self drawOilPaintPaths:paths inContext:[NSGraphicsContext currentContext]];
    
}
#endif

-(void) drawOilPaintPaths:(NSArray*) oilPaintPaths inContext:(NSGraphicsContext*) pContext
{
    [pContext setShouldAntialias:YES];
    
	for(Path* path in oilPaintPaths)
	{
		[self drawPath:path inContext:pContext];
	}
}


-(void) drawPath:(Path*) path inContext:(NSGraphicsContext*) context
{
    
//    NSImage *image = nil;
//    NSGraphicsContext* originalContext = context;
//    
//    if (path == currentPath)
//    {
//        [NSGraphicsContext saveGraphicsState];
//        
//        image = [[NSImage alloc] initWithSize:NSMakeSize(path.bounds.size.width + 90, path.bounds.size.height+90)];
//        [image lockFocus];
//        
//        [[NSColor clearColor] set];
//        NSRectFill(path.bounds);
//        context = [NSGraphicsContext currentContext];
//        
//        NSAffineTransform* tranform = [NSAffineTransform transform];
//        
//        [tranform translateXBy:-path.bounds.origin.x yBy:-path.bounds.origin.y];
//        
//        [tranform concat];
//    }
    
	
	[context setShouldAntialias:YES];
	
    CGContextRef cgContext = (CGContextRef)[context graphicsPort];

    CGContextSetBlendMode(cgContext, kCGBlendModeMultiply);
	[[path.color colorWithAlphaComponent:0.6] set];
    CGFloat fPenWidth = [path lineWidth];
    [path setLineWidth: fPenWidth+3];
	[path stroke];
    
    [path setLineWidth: fPenWidth];

    [[path.color colorWithAlphaComponent:0.3] set];
	
	//CGContextSetBlendMode(cgContext, kCGBlendModeNormal);
    CGContextSetBlendMode(cgContext, kCGBlendModeSourceAtop);

	[self _strokePathPoints:path];
    
//    if (path == currentPath)
//    {
//        [image unlockFocus];
//        context = originalContext;
//        
//        
//        
//        [image drawAtPoint:path.bounds.origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
////        [[NSColor greenColor] setStroke];
////        [NSBezierPath setDefaultLineWidth:2];
////        [[NSBezierPath bezierPathWithRect:path.bounds] stroke];
////        
//        [image release];
//        [NSGraphicsContext restoreGraphicsState];
//        
////        [[image TIFFRepresentation] writeToFile:[NSString stringWithFormat:@"/Users/om/Desktop/Images/%i.png", ++lPenPointCounter_g] atomically:YES];
//    }
}

#pragma mark Event API

#if _UseLayers
-(void) mouseDown:(NSEvent *)theEvent
{
    CGMutablePathRef cgCurrentPath = CGPathCreateMutable();
    OilPaintLayer* shapeLayer = [[[OilPaintLayer alloc] init] autorelease];
    if (viewImage)
    {
        viewImage.name = @"LayerDraw";
    }
    
    [shapeLayer setDelegate:self];
    [shapeLayer setName:@"PenCreationalLayer"];
    shapeLayer.backgroundColor = [[NSColor clearColor] CGColor];
    shapeLayer.path = cgCurrentPath;
    shapeLayer.bezierPath = [NSBezierPath bezierPath];
    shapeLayer.bezierPath.lineCapStyle = NSRoundLineCapStyle;
    shapeLayer.bezierPath.lineJoinStyle = NSRoundLineJoinStyle;
    shapeLayer.bezierPath.lineWidth = penContext.penWidth;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineWidth = penContext.penWidth;
    shapeLayer.strokeColor = [penContext.color CGColor];
    shapeLayer.bounds = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
    shapeLayer.position = NSMakePoint(NSMidX(self.frame), NSMidY(self.frame));
    shapeLayer.borderWidth = 5;
    shapeLayer.borderColor = [[NSColor blueColor] CGColor];
    
    for (CALayer* layer in rootLayer.sublayers)
    {
        [layer removeFromSuperlayer];
    }
    
    [rootLayer addSublayer:shapeLayer];
    
	NSPoint pt = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
    pt = [shapeLayer convertPoint:pt fromLayer:rootLayer];

	m_pPointFilterChain->StartFilter(pt.x, pt.y);
	m_pPointFilterChain->ClearOutputBuffer();

    m_pStartEndCapFilter->StartFilter(pt.x, pt.y);
	m_pStartEndCapFilter->ClearOutputBuffer();
        
    CGPathMoveToPoint((CGMutablePathRef)shapeLayer.path, NULL, pt.x, pt.y);
    [shapeLayer.bezierPath moveToPoint:pt];
    
    CGPathAddLineToPoint((CGMutablePathRef)shapeLayer.path, NULL, pt.x, pt.y);
    [shapeLayer.bezierPath lineToPoint:pt];
	//CGPathAddLineToPoint((CGMutablePathRef)shapeLayer.path, NULL, pt.x, pt.y);
    
    CGFloat lineWidth = shapeLayer.lineWidth;
    invalidateRect = NSUnionRect(invalidateRect, NSMakeRect(pt.x - lineWidth/2 - INFLATION, pt.y - lineWidth/2 - INFLATION, lineWidth * 2 + INFLATION, lineWidth * 2 + INFLATION ));
    
    //shapeLayer.contentsRect = invalidateRect;
    [shapeLayer setNeedsDisplay];
    [self setNeedsDisplay:YES];
}

#else
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
#endif


#if _UseLayers
-(void) mouseDragged:(NSEvent *)theEvent
{
	if (m_pPointFilterChain.get() && m_pStartEndCapFilter.get())
	{
        OilPaintLayer* shapeLayer = (OilPaintLayer*)[[self.layer sublayers] lastObject];

		NSPoint pt = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
        pt = [shapeLayer convertPoint:pt fromLayer:rootLayer];

		m_pPointFilterChain->MoveFilter(pt.x, pt.y);
        m_pStartEndCapFilter->MoveFilter(pt.x, pt.y);
		
        std::vector<PointF> &outPts = m_pPointFilterChain->GetOutputBuffer();
        NSPointArray pts = NULL;
        
        pts = new NSPoint[outPts.size()];
        
        
        for (int i=0; i<outPts.size(); ++i)
        {
            NSPoint pt = NSMakePoint(outPts[i].X, outPts[i].Y);
            CGPathAddLineToPoint((CGMutablePathRef)shapeLayer.path, NULL, pt.x, pt.y);
            [shapeLayer.bezierPath lineToPoint:pt];
            
            pts[i] = pt;
        }
        		
        invalidateRect = NSUnionRect(invalidateRect, [self createNSRectFromPointArray:pts count:outPts.size()]);
        
        [shapeLayer setNeedsDisplayInRect:invalidateRect];
        [self setNeedsDisplayInRect:invalidateRect];
		m_pPointFilterChain->ClearOutputBuffer();
        m_pStartEndCapFilter->ClearOutputBuffer();
		delete []pts;
	}	
}
#else
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
#endif

#if _UseLayers
-(void) mouseUp:(NSEvent *)theEvent
{
    NSPoint pt = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
    
    OilPaintLayer* shapeLayer = (OilPaintLayer*)[[self.layer sublayers] lastObject];
    //pt = [shapeLayer convertPoint:pt fromLayer:rootLayer];
    //CGPathAddLineToPoint((CGMutablePathRef)shapeLayer.path, NULL, pt.x, pt.y);
    //[shapeLayer.bezierPath lineToPoint:pt];
    
    m_pPointFilterChain->EndFilter(pt.x, pt.y);
    m_pPointFilterChain->ClearOutputBuffer();
    
    m_pPointFilterChain->EndFilter(pt.x, pt.y);
    m_pPointFilterChain->ClearOutputBuffer();
    
    if (!viewImage) 
    {
        viewImage = [[NSImage alloc]  initWithSize:self.frame.size];
        [[NSColor clearColor] set];        
        NSRectFill(NSMakeRect(0, 0, viewImage.size.width, viewImage.size.height));

    }
    
    viewImage.name = @"Drawing";
    [viewImage lockFocus];
    
       
    for (CALayer* layer in [self.layer sublayers]) 
    {
        //if (shapeLayer != layer)
        {
            [self drawLayer:layer inContext:(CGContextRef)[[NSGraphicsContext currentContext] graphicsPort]];
        }
    }
    
    [viewImage unlockFocus];
    
    [viewImage setName:@"Drawn"];
    
    [self setNeedsDisplay:YES];
    [shapeLayer setNeedsDisplayInRect:shapeLayer.frame];
}
#else
-(void) mouseUp:(NSEvent *)theEvent
{
    NSPoint point = CONVERT_POINT_TO_VIEW([theEvent locationInWindow]);
    
    m_pPointFilterChain->EndFilter(point.x, point.y);
    m_pPointFilterChain->ClearOutputBuffer();
    
    m_pPointFilterChain->EndFilter(point.x, point.y);
    m_pPointFilterChain->ClearOutputBuffer();
}
#endif


-(void) dealloc
{
    [penContext release];
    m_pStartEndCapFilter.reset();
	m_pPointFilterChain.reset();
#if _UseLayers
    [rootLayer release];
    CFRelease(penMask);
    [pattern release];
    [viewImage release];
#else
    [currentPath release];
    [paths release];
#endif
    
	[super dealloc];
}

#if _UseLayers
-(void)clear:(id)sender
{
    rootLayer.sublayers = nil;
    [viewImage release];
    viewImage = nil;
}
#else
-(void)clear:(id)sender
{
    [paths removeAllObjects];
    [self setNeedsDisplay:YES];
}
#endif

- (void)rightMouseUp:(NSEvent *)theEvent
{
	[NSMenu popUpContextMenu:contextMenu withEvent:theEvent forView:self];
}

@end


