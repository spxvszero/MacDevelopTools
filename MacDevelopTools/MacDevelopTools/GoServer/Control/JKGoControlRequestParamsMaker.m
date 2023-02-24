//
//  JKGoControlRequestParamsMaker.m
//  jkgocontrol
//
//  Created by jk on 2022/5/20.
//

#import "JKGoControlRequestParamsMaker.h"

@implementation JKGoControlRequestParamsMaker

+ (NSDictionary *)authRequest:(JKGoControlBaseRequest *)request
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [JKGoControlRequestParamsMaker safeAdd:dic object:request.sessionUUID forKey:@"uuid"];
    [JKGoControlRequestParamsMaker safeAdd:dic object:request.secret forKey:@"secret"];
    return dic;
}

+ (NSDictionary *)makeAction:(JKGoControlActionCategory)category type:(JKGoControlActionType)type data:(id)dataObj
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [JKGoControlRequestParamsMaker safeAdd:dic object:[JKGoControlRequestParamsMaker routeWithCategory:category] forKey:@"path"];
    [JKGoControlRequestParamsMaker safeAdd:dic object:@(type) forKey:@"action"];
    [JKGoControlRequestParamsMaker safeAdd:dic object:dataObj forKey:@"data"];
    return dic;
}
+ (NSDictionary *)actionRequest:(JKGoControlBaseRequest *)request withDic:(nonnull NSDictionary *)actionDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [JKGoControlRequestParamsMaker safeAdd:dic object:request.sessionUUID forKey:@"uuid"];
    [JKGoControlRequestParamsMaker safeAdd:dic object:request.accessKey forKey:@"accessKey"];
    [JKGoControlRequestParamsMaker safeAdd:dic object:@(request.seq) forKey:@"seq"];
    [JKGoControlRequestParamsMaker safeAdd:dic object:actionDic forKey:@"action"];
    return dic;
}

+ (NSString *)routeWithCategory:(JKGoControlActionCategory)category
{
    switch (category) {
        case ActionCategoryVersion:
            return @"version";
        case ActionCategoryConfig:
            return @"config";
        case ActionCategoryCmd:
            return @"cmd";
        case ActionCategoryUpdate:
            return @"update";
        default:
            return @"unknown";
            break;
    }
}

+ (void)safeAdd:(NSMutableDictionary *)dic object:(id)obj forKey:(NSString *)key
{
    if (!key || key.length <= 0) {
        return;
    }
    if (!obj || !dic) {
        return;
    }
    [dic setObject:obj forKey:key];
}


+ (NSString *)describeNameForActionCategory:(JKGoControlActionCategory)catagory
{
    switch (catagory) {
        case ActionCategoryVersion:
            return @"Version";
        case ActionCategoryConfig:
            return @"Config";
        case ActionCategoryCmd:
            return @"Command";
        case ActionCategoryUpdate:
            return @"Update";
        default:
            return @"Undefine";
            break;
    }
}
+ (NSString *)describeNameForActionType:(JKGoControlActionType)type
{
    switch (type) {
        case ActionTypeGet:
        {
            return @"GET";
        }
            break;
        case ActionTypeModify:
        {
            return @"Modify";
        }
            break;
        case ActionTypeDelete:
        {
            return @"Delete";
        }
            break;
        default:
            return @"Undefine";
            break;
    }
}

@end
