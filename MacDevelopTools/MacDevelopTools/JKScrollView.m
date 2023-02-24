//
//  JKScrollView.m
//  MacDevelopTools
//
//  Created by jk on 2021/11/1.
//  Copyright © 2021 JK. All rights reserved.
//

#import "JKScrollView.h"

@implementation JKScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)scrollWheel:(NSEvent *)event
{
    float rangeCanScroll = self.contentView.documentRect.size.width - self.contentView.documentVisibleRect.size.width;
    if (rangeCanScroll > 0) {
        float curPointX = self.contentView.documentVisibleRect.origin.x;
//        float destinateX = event.deltaY + curPointX;
        //wanna scroll more quickly, so 4 times it
        float destinateX = event.deltaY * 4 + curPointX;
        destinateX = MIN(rangeCanScroll, MAX(0, destinateX));
        [self.contentView scrollToPoint:CGPointMake(destinateX, event.deltaX)];
    }
}

- (void)scrollToPoint:(NSPoint)point
{
    float rangeCanScroll = self.contentView.documentRect.size.width - self.contentView.documentVisibleRect.size.width;
    [self.contentView scrollToPoint:CGPointMake(MIN(rangeCanScroll, MAX(0, point.x)), point.y)];
}

@end
