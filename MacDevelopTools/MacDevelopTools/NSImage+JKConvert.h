//
//  NSImage+JKConvert.h
//  MacDevelopTools
//
//  Created by 曾坚 on 2019/2/16.
//  Copyright © 2019年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (JKConvert)

- (CIImage *)jk_CIImage;

+ (NSImage *)jk_imageFromCGImageRef:(CGImageRef)image;

- (CGImageRef)jk_imageToCGImageRef;

@end
