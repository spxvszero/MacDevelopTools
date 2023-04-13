//
//  JKWallImageView.h
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/4/13.
//  Copyright © 2023 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    JKWallImageScalingScaleToFill,
    JKWallImageScalingAspectToFit,
    JKWallImageScalingAspectToFill,
    JKWallImageScalingCustom,
} JKWallImageScaling;



@interface JKWallImageView : NSView

- (void)setImage:(NSImage *)image;
- (void)setImageScaling:(JKWallImageScaling)imageScaling;
- (CGRect)changeXPos:(CGFloat)value;
- (CGRect)changeYPos:(CGFloat)value;
- (CGRect)changeWPos:(CGFloat)value;
- (CGRect)changeHPos:(CGFloat)value;
- (void)changeScale:(CGFloat)value;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
