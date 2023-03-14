//
//  JKMacFileStoragePath.m
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/2/28.
//  Copyright © 2023 JK. All rights reserved.
//

#import "JKMacFileStoragePath.h"

@implementation JKMacFileStoragePath

+ (NSString *)rootDirPath
{
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    if (!dirPath) {
        return nil;
    }
    dirPath = [NSString pathWithComponents:@[dirPath, @"MacDevelopToolsData"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:false attributes:nil error:nil];
    }
    return dirPath;
}

+ (NSString *)goServerDataDirPath
{
    NSString *dirPath = [[self class] rootDirPath];
    if (!dirPath) {
        return nil;
    }
    dirPath = [NSString pathWithComponents:@[dirPath, @"GoServerData"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:false attributes:nil error:nil];
    }
    return dirPath;
}

+ (NSString *)shellManagerDataDirPath
{
    NSString *dirPath = [[self class] rootDirPath];
    if (!dirPath) {
        return nil;
    }
    dirPath = [NSString pathWithComponents:@[dirPath, @"ShellManager"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:false attributes:nil error:nil];
    }
    return dirPath;
}

+ (NSString *)itemsManagerListDirPath
{
    NSString *dirPath = [[self class] rootDirPath];
    if (!dirPath) {
        return nil;
    }
    dirPath = [NSString pathWithComponents:@[dirPath, @"Items"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:false attributes:nil error:nil];
    }
    return dirPath;
}

@end

