//
//  DrawingView.m
//  CustomViewDrawing
//
//  Created by omkar_ramtekkar on 13-01-18.
//  Copyright 2013 Om's MacBook Pro. All rights reserved.
//

#import "DrawingView.h"
#import <Quartz/Quartz.h>

#define CONVERT_POINT_TO_VIEW(point) [self convertPoint:point fromView:nil]

const float FPS = 1.0f/30.0;
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
        [NSBezierPath setDefaultFlatness:0.8];
        [NSBezierPath setDefaultLineWidth:30];
        [NSBezierPath setDefaultLineJoinStyle:NSRoundLineCapStyle];
        [NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
         
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


- (NSImage *)rotateImage:(NSImage *)image angle:(int)alpha 
{  
    NSImage *existingImage = image; 
    NSSize existingSize = [existingImage size]; 
    NSSize newSize = NSMakeSize(existingSize.height, existingSize.width); 
    NSImage *rotatedImage = [[[NSImage alloc] initWithSize:newSize] autorelease];  
    [rotatedImage lockFocus]; 
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];  
    NSAffineTransform *rotateTF = [NSAffineTransform transform]; 
    NSPoint centerPoint = NSMakePoint(newSize.width / 2, newSize.height / 2);  
    //translate the image to bring the rotation point to the center (default is 0,0 ie lower left corner) 
    
    [rotateTF translateXBy:centerPoint.x yBy:centerPoint.y]; 
    [rotateTF rotateByDegrees:alpha]; 
    [rotateTF translateXBy:-centerPoint.x yBy:-centerPoint.y];
    [rotateTF concat]; 
    //NSSize size = [rotateTF transformSize:newSize];
    [existingImage drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, 25, 25) operation:NSCompositeSourceOver fraction:1.0];  
    [rotatedImage unlockFocus];  
    return rotatedImage; 
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
    
    float lineWidth = [currentPath lineWidth];
    NSRect rect = [currentPath bounds];
    rect.origin.x -= lineWidth;
    rect.origin.y -= lineWidth;
    rect.size.width += 2 * lineWidth;
    rect.size.height += 2 * lineWidth;
    
    NSImage* pathImage = [[NSImage alloc] initWithSize:rect.size];
    
    [pathImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    
    [[NSColor clearColor] set];
    [[NSBezierPath bezierPathWithRect:rect] fill];
    
    [[NSColor redColor] set];
    
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];

    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-rect.origin.x , -rect.origin.y ));
   
    //[currentPath stroke];
    
    CGContextSetAlpha(context, 0.2);
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
            NSPoint currentPoint = [value pointValue];
 
            [NSBezierPath strokeLineFromPoint:lastPoint toPoint:currentPoint];
            lastPoint = currentPoint;
            
        }
        ++i;
    }
    
    
    [pathImage unlockFocus];
    
    
    NSRect frame = [self frame];
    NSRect bounds = [self bounds];
     [pathImage drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    [pathImage release];
}

-(void) mouseDown:(NSEvent *)theEvent
{
    timer = [NSTimer scheduledTimerWithTimeInterval:FPS target:self selector:@selector(redraw) userInfo:nil repeats:YES];
    
    [timer retain];
    
    [points release];
    points = [[NSMutableArray alloc] init];
    [points addObject:[NSValue valueWithPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])]];
    bDrawGradient = FALSE;
    [currentPath release];
    currentPath = [[NSBezierPath alloc] init];
    
    [currentPath setLineWidth:30];
    [currentPath setLineJoinStyle:NSRoundLineJoinStyle];
    [currentPath setLineCapStyle:NSRoundLineCapStyle];
    [currentPath setFlatness:0.8];	
    
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
        [points addObject:[NSValue valueWithPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])]];
	}
	
}

-(void) mouseUp:(NSEvent *)theEvent
{
    bDrawGradient = YES;
	//if(points)
	{
		//[points addObject:[NSValue valueWithPoint:[theEvent locationInWindow]]];
        [currentPath lineToPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])];
        [points addObject:[NSValue valueWithPoint:CONVERT_POINT_TO_VIEW([theEvent locationInWindow])]];
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
	[super dealloc];
}

@end
