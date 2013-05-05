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
    
    //_pattern = new NSUInteger*[_iMaxSize];
    for (unsigned int i=0; i < _iMaxSize ; ++i)
    {
        //_pattern[i] = new NSUInteger[_iMaxLength];
        for (unsigned int j=0; j<_iMaxLength; ++j) 
        {
            _pattern[i][j] = rand() % 2;
        }
    }
    
    for (unsigned int i=0; i < _iMaxSize ; ++i)
    {
        for (unsigned int j=0; j<_iMaxLength; ++j) 
        {
            NSLog(@"%i",(int)_pattern[i][j]);
        }
        NSLog(@"\n");
    }
}
//-(NSUInteger**) getPatternForStrokeWidth:(NSUInteger) width forLength:(NSUInteger) length
//{
//    NSUInteger physicalLocation = length % _iMaxLength;
//    return _pattern;
//}

-(NSUInteger*) getPatternForStrokeWidth:(NSUInteger) width forLocation:(NSPoint) point
{
    NSUInteger physicalLocation = ((NSUInteger)point.x) % _iMaxLength;
    return _pattern[physicalLocation];
}

-(void) dealloc
{

//    for (unsigned int i=0; i<_iMaxSize; ++i)
//    {
//        delete []_pattern[i];
//    }
//    
//    delete []_pattern;
//    _pattern = NULL;
    
    [super dealloc];
}

@end
