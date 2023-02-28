//
//  JKGoServerDataStorage.m
//  MacDevelopTools
//
//  Created by jk on 2022/5/25.
//  Copyright © 2022 JK. All rights reserved.
//

#import "JKGoServerDataStorage.h"
#import "YYModel.h"
#import "JKMacFileStoragePath.h"

@implementation JKGoServerDataStorage

+ (NSArray<JKGoServerDataModel *> *)serverListFromDisk
{
    NSString *filePath = [JKGoServerDataStorage plistFilePath];
    if (!filePath) {
        return nil;
    }
    NSArray *serversArr = [NSArray arrayWithContentsOfFile:filePath];
    NSMutableArray *resArr = [NSMutableArray array];
    for (NSDictionary *server in serversArr) {
        JKGoServerDataModel *s = [[JKGoServerDataModel alloc] initWithDic:server];
        [resArr addObject:s];
    }
    return resArr;
}

+ (void)saveServerListInDisk:(NSArray<JKGoServerDataModel *> *)list
{
    NSString *filePath = [JKGoServerDataStorage plistFilePath];
    if (!filePath) {
        return ;
    }
    NSMutableArray *resArr = [NSMutableArray array];
    for (JKGoServerDataModel *server in list) {
        [resArr addObject:[server dicValue]];
    }
    [resArr writeToFile:filePath atomically:true];
}

+ (NSArray<JKGoServerActionModel *> *)actionsListFromDisk
{
   NSString *filePath = [JKGoServerDataStorage actionsFilePath];
   if (!filePath) {
       return nil;
   }
   NSArray *serversArr = [NSArray arrayWithContentsOfFile:filePath];
   NSMutableArray *resArr = [NSMutableArray array];
   for (NSDictionary *server in serversArr) {
       JKGoServerActionModel *s = [JKGoServerActionModel yy_modelWithDictionary:server];
       [resArr addObject:s];
   }
   return resArr;
}

+ (void)saveActionsListInDisk:(NSArray<JKGoServerActionModel *> *)list
{
   NSString *filePath = [JKGoServerDataStorage actionsFilePath];
   if (!filePath) {
       return ;
   }
   NSMutableArray *resArr = [NSMutableArray array];
   for (JKGoServerActionModel *server in list) {
       [resArr addObject:[server yy_modelToJSONObject]];
   }
   [resArr writeToFile:filePath atomically:true];
}



+ (NSString *)plistFilePath
{
    NSString *dirPath = [JKGoServerDataStorage dirPath];
    if (!dirPath) {
        return nil;
    }
    return [NSString pathWithComponents:@[dirPath, @"servers.plist"]];
}

+ (NSString *)actionsFilePath
{
    NSString *dirPath = [JKGoServerDataStorage dirPath];
    if (!dirPath) {
        return nil;
    }
    return [NSString pathWithComponents:@[dirPath, @"actions.plist"]];
}

+ (NSString *)dirPath
{
    return [JKMacFileStoragePath goServerDataDirPath];
}

@end
