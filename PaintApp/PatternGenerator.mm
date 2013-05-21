//
//  PatternGenerator.m
//  PaintApp
//
//  Created by Om on 28/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PatternGenerator.h"

@implementation PatternGenerator

-(id) init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

-(void) initialize
{
    _iMaxLength = 60;
    _iMaxSize = 60;
    
    for (unsigned int i=0; i < _iMaxSize ; ++i)
    {
        for (unsigned int j=0; j<_iMaxLength; ++j) 
        {
            _pattern[i][j] = rand() % 2;
        }
    }
}

-(NSUInteger*) getPatternForStrokeWidth:(NSUInteger) width forLocation:(NSPoint) point
{
    NSUInteger physicalLocation = ((NSUInteger)point.x) % _iMaxLength;
    return _pattern[physicalLocation];
}

-(void) dealloc
{
    [super dealloc];
}

@end
