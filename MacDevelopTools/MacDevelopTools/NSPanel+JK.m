//
//  NSPanel+JK.m
//  MacDevelopTools
//
//  Created by zqgame on 2022/1/10.
//  Copyright © 2022 JK. All rights reserved.
//

#import "NSPanel+JK.h"

@implementation NSSavePanel (JK)

- (void)jk_beginWithCompletionHandler:(void(^)(NSModalResponse result))resultBlock
{
    [self beginWithCompletionHandler:resultBlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self orderFrontRegardless];
    });
}

@end

