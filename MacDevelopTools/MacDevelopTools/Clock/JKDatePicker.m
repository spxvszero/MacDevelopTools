//
//  JKDatePicker.m
//  MacDevelopTools
//
//  Created by jk on 2019/9/2.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKDatePicker.h"

@implementation JKDatePicker

- (void)mouseDown:(NSEvent *)event
{
    [super mouseDown:event];
    
    if (self.MouseDownBlock) {
        self.MouseDownBlock();
    }
}

@end
