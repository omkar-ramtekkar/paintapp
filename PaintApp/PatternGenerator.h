//
//  PatternGenerator.h
//  PaintApp
//
//  Created by Om on 28/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PatternGenerator : NSObject
{
    NSUInteger _pattern[60][60];
    NSUInteger _iMaxSize;
    NSUInteger _iMaxLength;
}

//-(NSUInteger**) getPatternForStrokeWidth:(NSUInteger) width forLength:(NSUInteger) length;
-(NSUInteger*) getPatternForStrokeWidth:(NSUInteger) width forLocation:(NSPoint) point;

-(void) initialize;

@end
