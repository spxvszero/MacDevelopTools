//
//  JKAuthChecker.m
//  MacDevelopTools
//
//  Created by zqgame on 2022/2/21.
//  Copyright © 2022 JK. All rights reserved.
//

#import "JKAuthChecker.h"

@implementation JKAuthChecker

+ (BOOL)checkAccessibility
{
    NSDictionary* opts = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts);
}

@end
