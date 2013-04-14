//
//  PenContext.h
//  PaintApp
//
//  Created by Om on 17/03/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface PenContext : NSObject

@property (retain, nonatomic) NSColor* color;
@property (assign, nonatomic) float penWidth;
@property (retain, nonatomic) CAShapeLayer* penCreationalLayer;

@end
