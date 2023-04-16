//
//  JKProxy.h
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/4/16.
//  Copyright © 2023 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    JKProxyTypeMin,
    JKProxyTypeSocks5 = JKProxyTypeMin,
    JKProxyTypeMax,
} JKProxyType;

@interface JKProxy : NSObject

+ (NSString *)displayNameWithProxyType:(JKProxyType)type;

@end

NS_ASSUME_NONNULL_END
