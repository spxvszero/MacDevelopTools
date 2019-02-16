//
//  NSImage+JKConvert.m
//  MacDevelopTools
//
//  Created by 曾坚 on 2019/2/16.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "NSImage+JKConvert.h"
#import <QuartzCore/CIFilter.h>

@implementation NSImage (JKConvert)

//将NSImage转换为CIImage


// convert NSImage to bitmap
- (CIImage *)jk_CIImage
{
    
    NSImage * myImage  = self;
    
    NSData  * tiffData = [myImage TIFFRepresentation];
    
    NSBitmapImageRep * bitmap;
    
    bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
    
    
    
    // create CIImage from bitmap
    
    CIImage * ciImage = [[CIImage alloc] initWithBitmapImageRep:bitmap];
    
    
    
    // create affine transform to flip CIImage
    
    NSAffineTransform *affineTransform = [NSAffineTransform transform];
    
    [affineTransform translateXBy:0 yBy:128];
    
    [affineTransform scaleXBy:1 yBy:-1];
    
    
    
    // create CIFilter with embedded affine transform
    
    CIFilter *transform = [CIFilter filterWithName:@"CIAffineTransform"];
    
    [transform setValue:ciImage forKey:@"inputImage"];
    
    [transform setValue:affineTransform forKey:@"inputTransform"];
    
    
    
    // get the new CIImage, flipped and ready to serve
    
    CIImage * result = [transform valueForKey:@"outputImage"];
    
    
    
    // draw to view
    
    [result drawAtPoint: NSMakePoint ( 0,0 )
     
               fromRect: NSMakeRect  ( 0,0,128,128 )
     
              operation: NSCompositingOperationSourceOver
     
               fraction: 1.0];
    
    // cleanup
    
    return ciImage;
    
}



//将CGImageRef转换为NSImage *



+ (NSImage *)jk_imageFromCGImageRef:(CGImageRef)image

{
    
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    
    CGContextRef imageContext = nil;
    
    NSImage* newImage = nil;
    
    
    
    // Get the image dimensions.
    
    imageRect.size.height = CGImageGetHeight(image);
    
    imageRect.size.width = CGImageGetWidth(image);
    
    
    
    // Create a new image to receive the Quartz image data.
    
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    
    [newImage lockFocus];
    
    
    
    // Get the Quartz context and draw.
    
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    
    [newImage unlockFocus];
    
    return newImage;
    
}



//将NSImage *转换为CGImageRef
- (CGImageRef)jk_imageToCGImageRef

{
    
    NSData * imageData = [self TIFFRepresentation];
    
    CGImageRef imageRef = NULL;
    
    if(imageData)
        
    {
        
        CGImageSourceRef imageSource =
        
        CGImageSourceCreateWithData(
                                    
                                    (CFDataRef)imageData,  NULL);
        
        imageRef = CGImageSourceCreateImageAtIndex(
                                                   
                                                   imageSource, 0, NULL);
        
    }
    
    return imageRef;
}

@end
