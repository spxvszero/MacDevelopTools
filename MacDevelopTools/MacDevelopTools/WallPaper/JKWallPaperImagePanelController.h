//
//  JKWallPaperImagePanelController.h
//  MacDevelopTools
//
//  Created by jk on 2018/12/14.
//  Copyright © 2018年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JKWallPaperImagePanelController : NSViewController

@property (nonatomic, assign) NSImageScaling currentScaling;

@property (nonatomic, strong) void (^ImageScaleButtonSelectBlock)(NSImageScaling scaling);

@end
