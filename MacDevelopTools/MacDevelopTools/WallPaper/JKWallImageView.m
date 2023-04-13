//
//  JKWallImageView.m
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/4/13.
//  Copyright © 2023 JK. All rights reserved.
//

#import "JKWallImageView.h"


@interface JKWallImageView()

@property (nonatomic, strong) NSImage *currentImage;

@end

@implementation JKWallImageView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setImage:(NSImage *)image
{
    self.currentImage = image;
    self.layer.contents = image;
}

- (void)setImageScaling:(JKWallImageScaling)imageScaling
{
    switch (imageScaling) {
            
        case JKWallImageScalingAspectToFit:
        {
            self.layer.contentsGravity = kCAGravityResizeAspect;
        }
            break;
        case JKWallImageScalingAspectToFill:
        {
            self.layer.contentsGravity = kCAGravityResizeAspectFill;
        }
            break;
        case JKWallImageScalingCustom:
        {
            self.layer.contentsGravity = kCAGravityCenter;
        }
            break;
        case JKWallImageScalingScaleToFill:
        default:
        {
            self.layer.contentsGravity = kCAGravityResize;
        }
            break;
    }
}

- (CGRect)changeXPos:(CGFloat)value
{
    CGFloat maxX = 1 - self.layer.contentsRect.size.width;
    CGFloat offset = value - maxX;
    self.layer.contentsRect = CGRectMake(value , self.layer.contentsRect.origin.y, self.layer.contentsRect.size.width - MAX(0, offset), self.layer.contentsRect.size.height);
    return self.layer.contentsRect;
}

- (CGRect)changeWPos:(CGFloat)value
{
    CGFloat maxWidth = 1 - self.layer.contentsRect.origin.x;
    CGFloat offset = value - maxWidth;
    self.layer.contentsRect = CGRectMake(self.layer.contentsRect.origin.x - MAX(0, offset), self.layer.contentsRect.origin.y, value, self.layer.contentsRect.size.height);
    return self.layer.contentsRect;
}

- (CGRect)changeYPos:(CGFloat)value
{
    CGFloat maxY = 1 - self.layer.contentsRect.size.height;
    CGFloat offset = value - maxY;
    self.layer.contentsRect = CGRectMake(self.layer.contentsRect.origin.x, value, self.layer.contentsRect.size.width, self.layer.contentsRect.size.height - MAX(0, offset));
    return self.layer.contentsRect;
}

- (CGRect)changeHPos:(CGFloat)value
{
    CGFloat maxHeight = 1 - self.layer.contentsRect.origin.y;
    CGFloat offset = value - maxHeight;
    self.layer.contentsRect = CGRectMake(self.layer.contentsRect.origin.x, self.layer.contentsRect.origin.y - MAX(0, offset), self.layer.contentsRect.size.width, value);
    return self.layer.contentsRect;
}

- (void)changeScale:(CGFloat)value
{
    self.layer.contentsScale = value;
}

- (void)reset
{
    self.layer.contentsScale = 1;
    self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
}


@end
