//
//  JKMouseButton.h
//  MacDevelopTools
//
//  Created by 曾坚 on 2018/12/12.
//  Copyright © 2018年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JKMouseButton : NSButton

@property (nonatomic, strong) void (^MouseUpBlock)(JKMouseButton *button);
@property (nonatomic, strong) void (^MouseDownBlock)(JKMouseButton *button);

@end
