//
//  JKInfoImageView.m
//  MacDevelopTools
//
//  Created by jk on 2019/1/2.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKInfoImageView.h"

@interface JKInfoImageView()

@property (nonatomic, strong) NSURL *currentFileUrl;

@end

@implementation JKInfoImageView

- (void)setImage:(NSImage *)image
{
    [super setImage:image];
    
    if (self.ImageDidChangeBlock) {
        self.ImageDidChangeBlock(self,self.currentFileUrl,image);
    }
}

- (void)setImageWithNoBlock:(NSImage *)image
{
    [super setImage:image];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    NSError *err;
    NSURL *fileUrl = [NSURL URLFromPasteboard:[sender draggingPasteboard]];
    NSString *type;
    if ([fileUrl getResourceValue:&type forKey:NSURLTypeIdentifierKey error:&err]) {
        //image
        if (UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeImage)) {
            self.currentFileUrl = fileUrl;
            return YES;
        }
    }
    
    return NO;
}

@end
