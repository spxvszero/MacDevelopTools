//
//  JKWellImageView.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/14.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKWellImageView.h"
#import <AVFoundation/AVFoundation.h>


@interface JKWellImageView()

@property (nonatomic, strong) NSURL *currentFileUrl;
@property (nonatomic, assign) BOOL isImage;

@end

@implementation JKWellImageView

- (void)setImage:(NSImage *)image
{
    [super setImage:image];
    
    if (self.ImageDidChangeBlock) {
        self.ImageDidChangeBlock(self,image,self.currentFileUrl,self.isImage);
    }
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    if (!self.editable) {
        return NSDragOperationNone;
    }
    
    NSError *err;
    NSURL *fileUrl = [NSURL URLFromPasteboard:[sender draggingPasteboard]];
    NSString *type;
    if ([fileUrl getResourceValue:&type forKey:NSURLTypeIdentifierKey error:&err]) {
        //movie
        if (UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeMovie)) {
            return NSDragOperationCopy;
        }
        //image
        if (UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeImage)) {
            return NSDragOperationCopy;
        }
    }

    return NSDragOperationNone;
}


- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    NSError *err;
    NSURL *fileUrl = [NSURL URLFromPasteboard:[sender draggingPasteboard]];
    NSString *type;
    if ([fileUrl getResourceValue:&type forKey:NSURLTypeIdentifierKey error:&err]) {
        //movie
        if (UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeMovie)) {
            self.isImage = NO;
            self.currentFileUrl = fileUrl;
            [self generateImageWithTime:0 fileUrl:fileUrl];
            return YES;
        }
        //image
        if (UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeImage)) {
            self.currentFileUrl = fileUrl;
            self.isImage = YES;
            return YES;
        }
    }
    
    return NO;
}

- (void)generateImageWithTime:(CGFloat)timeInterval fileUrl:(NSURL *)fileUrl
{
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:fileUrl options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = true;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    
    __weak typeof(self) weakSelf = self;
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        NSLog(@"current thread %@ image request -- %f  actual --- %f",[NSThread currentThread],(float)requestedTime.value/(float)requestedTime.timescale,(float)actualTime.value/(float)actualTime.timescale);
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }
        NSImage *resImage = [[NSImage alloc] initWithCGImage:im size:NSZeroSize];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.image = resImage;
        });
    };
    
//    CGSize maxSize = CGSizeMake(320, 180);
//    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    
}

@end
