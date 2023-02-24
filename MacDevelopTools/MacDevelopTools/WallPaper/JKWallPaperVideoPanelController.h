//
//  JKWallPaperVideoPanelController.h
//  MacDevelopTools
//
//  Created by jk on 2018/12/28.
//  Copyright © 2018年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JKWallPaperVideoPanelController : NSViewController

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL voiceEnable;
@property (nonatomic, assign) CGFloat voiceValue;

@property (nonatomic, strong) void (^VideoAspectSelectBlock)(NSInteger selectIndex);
@property (nonatomic, strong) void (^VideoVoiceEnableBlock)(BOOL enable);
@property (nonatomic, strong) void (^VideoVoiceValueChangeBlock)(CGFloat value);

@end
