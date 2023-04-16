//
//  JKGTranslateStorage.h
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/4/15.
//  Copyright © 2023 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKGTranslateStorage : NSObject

+ (NSString *)readProxyFromDisk;
+ (void)saveProxyToDisk:(NSString *)proxy;

@end

NS_ASSUME_NONNULL_END
