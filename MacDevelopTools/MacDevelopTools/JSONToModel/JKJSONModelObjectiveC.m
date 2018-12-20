//
//  JKJSONModelObjectiveC.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/20.
//  Copyright © 2018年 JK. All rights reserved.
//

#define kJKNonAtomic @"nonatomic"
#define kJKAtomic @"atomic"
#define kJKStrong @"strong"
#define kJKAssign @"assign"


#import "JKJSONModelObjectiveC.h"

@implementation JKJSONModelObjectiveC


+ (NSString *)transformFromJSONString:(NSString *)jsonStr
{
    id objModel = [JKJSONModelObjectiveC convertDicFromJSON:jsonStr];
    
    if (!objModel) {
        return @"JSON serialize failed";
    }
    
    return [JKJSONModelObjectiveC seperateWithModelObject:objModel withClassName:@"TopClass"];
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
    
    [resStr appendFormat:@"@interface %@ : NSObject \n\n",className];
    
    if ([obj isKindOfClass:[NSArray class]]) {
        NSString *arrStr = [JKJSONModelObjectiveC componentWithArray:obj extendDictionary:subClassObjDic];
        if (!arrStr || arrStr.length <= 0) {
            return nil;
        }else{
            [resStr appendString:arrStr];
        }
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        [resStr appendString:[JKJSONModelObjectiveC componentWithDictionary:obj extendDictionary:subClassObjDic]];
    }
    
    [resStr appendString:@"\n@end"];
    
    NSArray *subClassObjArr = [subClassObjDic allKeys];
    for (NSString *subclassObjKey in subClassObjArr) {
        [resStr appendString:@"\n\n==================\n\n"];
        NSString *appendSubClassStr = [JKJSONModelObjectiveC seperateWithModelObject:[subClassObjDic objectForKey:subclassObjKey] withClassName:subclassObjKey];
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
        [resStr appendString:[JKJSONModelObjectiveC propertyWithKey:key value:value]];
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
            [resStr appendString:[JKJSONModelObjectiveC componentWithArray:value extendDictionary:subClassObjDic]];
        }
        if ([value isKindOfClass:[NSDictionary class]]) {
            [resStr appendString:[JKJSONModelObjectiveC componentWithDictionary:value extendDictionary:subClassObjDic]];
        }
    }
    return resStr;
}


+ (NSString *)propertyWithKey:(NSString *)key value:(id)value
{
    NSMutableString *resStr = [NSMutableString string];
    [resStr appendFormat:@"@property (%@, ",kJKNonAtomic];
    if ([value isKindOfClass:[NSNumber class]]) {
        [resStr appendFormat:@"%@) ",kJKAssign];
        [resStr appendString:[JKJSONModelObjectiveC valueTypeWithNumber:value]];
        [resStr appendFormat:@" %@;",key];
    }else{
        [resStr appendFormat:@"%@) ",kJKStrong];
        NSString *typeValue = [JKJSONModelObjectiveC valueTypeWithId:value];
        if (!typeValue) {
            [resStr appendFormat:@"<#%@Class#>",key];
            [resStr appendFormat:@" *%@;",key];
        }else{
            [resStr appendString:typeValue];
            if ([typeValue isEqualToString:@"id"]) {
                [resStr appendFormat:@" %@;",key];
            }else{
                [resStr appendFormat:@" *%@;",key];
            }
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
        return @"NSArray";
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return @"NSString";
    }
    
    return @"id";
}

+ (NSString *)valueTypeWithNumber:(NSNumber *)number
{
    if ([JKJSONModelObjectiveC isBoolNumber:number]) {
        return @"BOOL";
    }
    
    switch(CFNumberGetType((CFNumberRef)number))
    {
        case kCFNumberIntType:
        {
            return @"int";
        }
            break;
        case kCFNumberNSIntegerType:
        case kCFNumberLongType:
        {
            return @"NSInteger";
        }
            break;
        case kCFNumberLongLongType:
        {
            return @"long long";
        }
            break;
           
        case kCFNumberFloatType:
        {
            return @"float";
        }
            break;
            
        case kCFNumberCGFloatType:
        case kCFNumberDoubleType:
        {
            return @"double";
        }
            break;
            default:
        {
            return @"NSInteger";
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
