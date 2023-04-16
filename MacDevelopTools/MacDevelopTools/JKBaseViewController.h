//
//  JKBaseViewController.h
//  MacDevelopTools
//
//  Created by jk on 2018/12/29.
//  Copyright © 2018年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JKBaseViewController : NSViewController

@property (nonatomic, strong) void (^MeunSizeChangeBlock)(NSSize size);

//This will call while menu close panel. the view or viewcontroller present from this controller should close in this function.
- (void)statusItemClose;

@end
