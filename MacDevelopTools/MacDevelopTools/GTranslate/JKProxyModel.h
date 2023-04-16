//
//  JKProxyModel.h
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/4/16.
//  Copyright © 2023 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKProxyModel : NSObject

@property (nonatomic, assign) JKProxyType proxyType;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

- (instancetype)initWithFileString:(NSString *)fileStr;
- (NSString *)fileString;

@end

NS_ASSUME_NONNULL_END
