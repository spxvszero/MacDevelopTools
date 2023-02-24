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

@end
