//
//  JKGTranslateStorage.m
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/4/15.
//  Copyright © 2023 JK. All rights reserved.
//

#import "JKGTranslateStorage.h"
#import "JKMacFileStoragePath.h"

@implementation JKGTranslateStorage

+ (NSString *)readProxyFromDisk
{
    NSString *filePath = [JKGTranslateStorage proxyFilePath];
    if (!filePath) {
        return nil;
    }
    NSString *proxy = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return proxy;
}

+ (void)saveProxyToDisk:(NSString *)proxy
{
    NSString *filePath = [JKGTranslateStorage proxyFilePath];
    [proxy writeToFile:filePath atomically:true encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString *)proxyFilePath
{
    NSString *dirPath = [JKMacFileStoragePath translateDirPath];
    if (!dirPath) {
        return nil;
    }
    return [NSString pathWithComponents:@[dirPath, @"proxy"]];
}

@end
