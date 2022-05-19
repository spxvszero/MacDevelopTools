//
//  NSBezierPath+JKExtension.h
//  MacDevelopTools
//
//  Created by zqgame on 2022/2/22.
//  Copyright © 2022 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBezierPath (JKExtension)

- (CGPathRef)quartzPath;

- (void)quadCurveToPoint:(CGPoint)endPoint
            controlPoint:(CGPoint)controlPoint;

- (void)relativeQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint;


@end

NS_ASSUME_NONNULL_END
