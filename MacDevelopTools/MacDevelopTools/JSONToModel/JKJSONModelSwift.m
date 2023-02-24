//
//  JKJSONModelSwift.m
//  MacDevelopTools
//
//  Created by zqgame on 2022/6/27.
//  Copyright © 2022 JK. All rights reserved.
//

#import "JKJSONModelSwift.h"

@implementation JKJSONModelSwift


+ (NSString *)transformFromJSONString:(NSString *)jsonStr
{
    id objModel = [JKJSONModelSwift convertDicFromJSON:jsonStr];
    
    if (!objModel) {
        return @"JSON serialize failed";
    }
    
    return [JKJSONModelSwift seperateWithModelObject:objModel withClassName:@"TopClass"];
}

+ (id)convertDicFromJSON:(NSString *)jsonStr
{
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!jsonData) {
        return nil;
    }
    
    NSError *err = nil;
    id objModel = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&err];
    
    if (!err && objModel) {
        return objModel;
    }
    NSLog(@"json serialize err -- %@",err);
    return nil;
}


+ (NSString *)seperateWithModelObject:(id)obj withClassName:(NSString *)className
{
    NSMutableString *resStr = [NSMutableString string];
    
    NSMutableDictionary *subClassObjDic = [NSMutableDictionary dictionary];
    
    [resStr appendFormat:@"class %@ { \n\n",className];
    
    if ([obj isKindOfClass:[NSArray class]]) {
        NSString *arrStr = [JKJSONModelSwift componentWithArray:obj extendDictionary:subClassObjDic];
        if (!arrStr || arrStr.length <= 0) {
            return nil;
        }else{
            [resStr appendString:arrStr];
        }
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        [resStr appendString:[JKJSONModelSwift componentWithDictionary:obj extendDictionary:subClassObjDic]];
    }
    
    [resStr appendString:@"\n}"];
    
    NSArray *subClassObjArr = [subClassObjDic allKeys];
    for (NSString *subclassObjKey in subClassObjArr) {
        [resStr appendString:@"\n\n==================\n\n"];
        NSString *appendSubClassStr = [JKJSONModelSwift seperateWithModelObject:[subClassObjDic objectForKey:subclassObjKey] withClassName:subclassObjKey];
        if (appendSubClassStr) {
            [resStr appendString:appendSubClassStr];
        }
    }
    
    return resStr;
}

+ (NSString *)componentWithDictionary:(NSDictionary *)obj extendDictionary:(NSMutableDictionary *)subClassObjDic
{
    NSMutableString *resStr = [NSMutableString string];
    
    NSArray *keyArray = [(NSDictionary *)obj allKeys];
    for (NSString *key in keyArray) {
        id value = [(NSDictionary *)obj objectForKey:key];
        [resStr appendString:[JKJSONModelSwift propertyWithKey:key value:value]];
        [resStr appendString:@"\n"];
        
        if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
            [subClassObjDic setObject:value forKey:key];
        }
    }
    return resStr;
}

+ (NSString *)componentWithArray:(NSArray *)obj extendDictionary:(NSMutableDictionary *)subClassObjDic
{
    NSMutableString *resStr = [NSMutableString string];
    if (obj && [(NSArray *)obj count] > 0) {
        id value = [(NSArray *)obj firstObject];
        if ([value isKindOfClass:[NSArray class]]) {
            [resStr appendString:[JKJSONModelSwift componentWithArray:value extendDictionary:subClassObjDic]];
        }
        if ([value isKindOfClass:[NSDictionary class]]) {
            [resStr appendString:[JKJSONModelSwift componentWithDictionary:value extendDictionary:subClassObjDic]];
        }
    }
    return resStr;
}


+ (NSString *)propertyWithKey:(NSString *)key value:(id)value
{
    NSMutableString *resStr = [NSMutableString string];
    [resStr appendFormat:@"var "];
    if ([value isKindOfClass:[NSNumber class]]) {
        [resStr appendFormat:@"%@",key];
        [resStr appendFormat:@" : %@?",[JKJSONModelSwift valueTypeWithNumber:value]];
    }else{
        NSString *typeValue = [JKJSONModelSwift valueTypeWithId:value];
        if (!typeValue) {
            [resStr appendFormat:@"%@",key];
            [resStr appendFormat:@" : <#%@Class#>?",key];
        }else{
            [resStr appendFormat:@"%@",key];
            [resStr appendFormat:@" : %@?",typeValue];
        }
    }
    return resStr;
}

+ (NSString *)assignStrongOfValue:(id)value
{
    return nil;
}

+ (NSString *)valueTypeWithId:(id)value
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if ([value isKindOfClass:[NSArray class]]) {
        return @"[]";
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return @"String";
    }
    
    return @"Any";
}

+ (NSString *)valueTypeWithNumber:(NSNumber *)number
{
    if ([JKJSONModelSwift isBoolNumber:number]) {
        return @"Bool";
    }
    
    switch(CFNumberGetType((CFNumberRef)number))
    {
        case kCFNumberIntType:
        {
            return @"Int";
        }
            break;
        case kCFNumberNSIntegerType:
        case kCFNumberLongType:
        {
            return @"Int";
        }
            break;
        case kCFNumberLongLongType:
        {
            return @"Int64";
        }
            break;
           
        case kCFNumberFloatType:
        {
            return @"Float";
        }
            break;
            
        case kCFNumberCGFloatType:
        case kCFNumberDoubleType:
        {
            return @"Double";
        }
            break;
            default:
        {
            return @"Int";
        }
            break;
    }
}

+ (BOOL)isBoolNumber:(NSNumber *)num
{
    CFTypeID boolID = CFBooleanGetTypeID(); // the type ID of CFBoolean
    CFTypeID numID = CFGetTypeID((__bridge CFTypeRef)(num)); // the type ID of num
    return numID == boolID;
}


@end
