//
//  JKMeunPanelViewController.h
//  MacDevelopTools
//
//  Created by jk on 2018/12/13.
//  Copyright © 2018年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JKMeunPanelViewController : NSViewController

+ (JKMeunPanelViewController *)fromStoryBoard;

@property (nonatomic, strong) void (^MeunSizeChangeBlock)(NSSize size);

@end
