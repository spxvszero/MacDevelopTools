//
//  JKWellImageView.h
//  MacDevelopTools
//
//  Created by jk on 2018/12/14.
//  Copyright © 2018年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JKWellImageView : NSImageView

@property (nonatomic, strong) void (^ImageDidChangeBlock)(JKWellImageView *imageView, NSImage *image, NSURL *fileUrl,BOOL isImage);

@end
