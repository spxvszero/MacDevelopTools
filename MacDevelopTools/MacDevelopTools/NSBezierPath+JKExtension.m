//
//  NSBezierPath+JKExtension.m
//  MacDevelopTools
//
//  Created by jk on 2022/2/22.
//  Copyright © 2022 JK. All rights reserved.
//

#import "NSBezierPath+JKExtension.h"

@implementation NSBezierPath (JKExtension)

// This method works only in OS X v10.2 and later.
// From https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CocoaDrawingGuide/Paths/Paths.html#//apple_ref/doc/uid/TP40003290-CH206-SW2
- (CGPathRef)quartzPath
{
    NSInteger i, numElements;
 
    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;
 
    // Then draw the path elements.
    numElements = [self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
 
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
 
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
 
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                        points[1].x, points[1].y,
                                        points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
 
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
 
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath)
            CGPathCloseSubpath(path);
 
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
 
    return immutablePath;
}

- (void)quadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint
{
    CGPoint startPoint = self.currentPoint;
    CGPoint controlPoint1 = CGPointMake((startPoint.x + (controlPoint.x - startPoint.x) * 2.0/3.0), (startPoint.y + (controlPoint.y - startPoint.y) * 2.0/3.0));
    CGPoint controlPoint2 = CGPointMake((endPoint.x + (controlPoint.x - endPoint.x) * 2.0/3.0), (endPoint.y + (controlPoint.y - endPoint.y) * 2.0/3.0));
    
    [self curveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
}

- (void)relativeQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint
{
    CGPoint startPoint = self.currentPoint;
    CGPoint controlPoint1 = CGPointMake((startPoint.x + (controlPoint.x - startPoint.x) * 2.0/3.0), (startPoint.y + (controlPoint.y - startPoint.y) * 2.0/3.0));
    CGPoint controlPoint2 = CGPointMake((endPoint.x + (controlPoint.x - endPoint.x) * 2.0/3.0), (endPoint.y + (controlPoint.y - endPoint.y) * 2.0/3.0));
    
    [self relativeCurveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
}

@end
