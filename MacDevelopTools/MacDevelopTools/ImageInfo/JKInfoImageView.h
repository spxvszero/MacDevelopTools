//
//  JKInfoImageView.h
//  MacDevelopTools
//
//  Created by jk on 2019/1/2.
//  Copyright © 2019年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JKInfoImageView : NSImageView

@property (nonatomic, strong) void (^ImageDidChangeBlock)(JKInfoImageView *imageView,NSURL *fileUrl ,NSImage *image);

- (void)setImageWithNoBlock:(NSImage *)image;

@end
