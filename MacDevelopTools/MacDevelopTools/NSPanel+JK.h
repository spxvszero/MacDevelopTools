//
//  NSPanel+JK.h
//  MacDevelopTools
//
//  Created by zqgame on 2022/1/10.
//  Copyright © 2022 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSavePanel (JK)

- (void)jk_beginWithCompletionHandler:(void(^)(NSModalResponse result))resultBlock;

@end

NS_ASSUME_NONNULL_END
