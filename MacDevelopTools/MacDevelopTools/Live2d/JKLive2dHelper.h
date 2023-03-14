//
//  JKLive2dHelper.h
//  MacDevelopTools
//
//  Created by jk on 2020/6/2.
//  Copyright © 2020 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKLive2dHelper : NSObject

+ (void)start;

+ (BOOL)setResoucePath:(NSString *)str;

+ (BOOL)isRunning;

+ (void)stop;

+ (void)nextScene;

+ (void)centerWindow;
+ (void)resizeWindowWithWidth:(int)width height:(int)height;

+ (void)registMouseTracking;
+ (void)unregistMouseTracking;

@end

NS_ASSUME_NONNULL_END
