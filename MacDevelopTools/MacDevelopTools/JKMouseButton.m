//
//  JKMouseButton.m
//  MacDevelopTools
//
//  Created by 曾坚 on 2018/12/12.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKMouseButton.h"

@implementation JKMouseButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


- (void)mouseDown:(NSEvent *)event
{
    if (self.MouseDownBlock) {
        self.MouseDownBlock(self);
    }
    
    [super mouseDown:event];
    
    if (self.MouseUpBlock) {
        self.MouseUpBlock(self);
    }
}

@end
