//
//  JKWallPaperImagePanelController.h
//  MacDevelopTools
//
//  Created by jk on 2018/12/14.
//  Copyright © 2018年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JKWallImageView.h"

typedef enum : NSUInteger {
    JKWallPaperImagePanelSliderTypeX,
    JKWallPaperImagePanelSliderTypeY,
    JKWallPaperImagePanelSliderTypeW,
    JKWallPaperImagePanelSliderTypeH,
    JKWallPaperImagePanelSliderTypeScale,
} JKWallPaperImagePanelSliderType;

@interface JKWallPaperImagePanelController : NSViewController

@property (nonatomic, assign) JKWallImageScaling currentScaling;

@property (nonatomic, strong) void (^ImageScaleButtonSelectBlock)(JKWallImageScaling scaling);
@property (nonatomic, strong) void (^CustomSliderValueChangedBlock)(JKWallPaperImagePanelSliderType type, CGFloat value, CGRect *listenRect);
@property (nonatomic, strong) void (^ResetActionBlock)(void);

- (void)resetPanel;

@end
