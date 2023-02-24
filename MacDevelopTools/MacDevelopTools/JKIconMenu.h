//
//  JKIconMenu.h
//  MacDevelopTools
//
//  Created by jk on 2018/12/12.
//  Copyright © 2018年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JKIconMenu : NSMenu

@property (nonatomic, strong) void (^MenuClickBlock)(NSInteger index);

@end
