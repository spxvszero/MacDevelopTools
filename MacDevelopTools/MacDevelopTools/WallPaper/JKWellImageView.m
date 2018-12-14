//
//  JKWellImageView.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/14.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKWellImageView.h"

@implementation JKWellImageView

- (void)setImage:(NSImage *)image
{
    [super setImage:image];
    
    if (self.ImageDidChangeBlock) {
        self.ImageDidChangeBlock(self,image);
    }
}
@end
