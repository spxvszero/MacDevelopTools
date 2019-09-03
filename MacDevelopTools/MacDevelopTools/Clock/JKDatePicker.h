//
//  JKDatePicker.h
//  MacDevelopTools
//
//  Created by jk on 2019/9/2.
//  Copyright © 2019年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JKDatePicker : NSDatePicker

@property (nonatomic, strong) void(^MouseDownBlock)(void);

@end
