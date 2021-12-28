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
        float destinateX = event.deltaY + curPointX;
        if (destinateX < 0 || destinateX > rangeCanScroll) {
            return;
        }
        [self.contentView scrollToPoint:CGPointMake(event.deltaY + curPointX, event.deltaX)];
    }
}

@end
