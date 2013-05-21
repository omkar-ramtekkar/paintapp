//
//  Constants.h
//  PaintApp
//
//  Created by Om on 17/03/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#ifndef PaintApp_Constants_h
#define PaintApp_Constants_h

#define DEFAULT_PEN_WIDTH   30
#define PEN_MAX_WIDTH       60
#define PEN_MIN_WIDTH       5
#define DEFAULT_PEN_COLOR [NSColor blueColor]

#define MIN_REFRESH_RATE 25

#define _UseLayers 0

#if _UseLayers
#define INFLATION 7
#else
#define INFLATION 3
#endif

#endif
