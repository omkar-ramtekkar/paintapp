/*
 *  types.h
 *  PaintApp
 *
 *  Created by omkar_ramtekkar on 13-02-07.
 *  Copyright 2013 __MyCompanyName__. All rights reserved.
 *
 */

#pragma once

#import <Foundation/Foundation.h>



typedef float REAL;

class PointF
{
public:
	
    REAL X;
    REAL Y;
	
public:
	PointF()
	{
		X = Y = 0.0f;
	}
	
	PointF(const PointF &point)
	{
		X = point.X;
		Y = point.Y;
	}
	
	//PointF(const SizeF &size)
//	{
//		X = size.Width;
//		Y = size.Height;
//	}
	
	PointF(REAL x,
		   REAL y)
	{
		X = x;
		Y = y;
	}
	
	PointF( const CGPoint& pt )
	{
		X = pt.x;
		Y = pt.y;
	}
	
	operator CGPoint() const
	{
		CGPoint retpt;
		retpt.x = X;
		retpt.y = Y;
		return retpt;
	}
	
	PointF operator+(const PointF& point) const
	{
		return PointF(X + point.X,
					  Y + point.Y);
	}
	
	PointF operator-(const PointF& point) const
	{
		return PointF(X - point.X,
					  Y - point.Y);
	}
	
	bool Equals(const PointF& point)
	{
		return (X == point.X) && (Y == point.Y);
	}
};





class SizeF
{
public:
    SizeF()
    {
        Width = Height = 0.0f;
    }
	
    SizeF(const SizeF& size)
    {
        Width = size.Width;
        Height = size.Height;
    }
	
    SizeF(REAL width,
           REAL height)
    {
        Width = width;
        Height = height;
    }
	
	SizeF( const CGSize& sz )
	{
		Width = sz.width;
		Height = sz.height;
	}
	
	operator CGSize() const
	{
		CGSize retsz;
		retsz.width = Width;
		retsz.height = Height;
		return retsz;
	}
	
    SizeF operator+( const SizeF& sz) const
    {
        return SizeF(Width + sz.Width,
                     Height + sz.Height);
    }
	
    SizeF operator-( const SizeF& sz) const
    {
        return SizeF(Width - sz.Width,
                     Height - sz.Height);
    }
	
    bool Equals( const SizeF& sz) const
    {
        return (Width == sz.Width) && (Height == sz.Height);
    }
	
    bool Empty() const
    {
        return (Width == 0.0f && Height == 0.0f);
    }
	
public:
	
    REAL Width;
    REAL Height;
};


inline bool nearf( float a,float b ) { return (fabs(a-b)<0.0001f); }
inline bool nearf( PointF pt1,PointF pt2 ) { return nearf(pt1.X,pt2.X) && nearf(pt1.Y,pt2.Y );}
