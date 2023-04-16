//
//  JKProxy.m
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/4/16.
//  Copyright © 2023 JK. All rights reserved.
//

#import "JKProxy.h"

@implementation JKProxy

+ (NSString *)displayNameWithProxyType:(JKProxyType)type
{
    switch (type) {
        case JKProxyTypeSocks5:
            return @"socks5";
        break;
            
        default:
            break;
    }
    return nil;
}

@end
