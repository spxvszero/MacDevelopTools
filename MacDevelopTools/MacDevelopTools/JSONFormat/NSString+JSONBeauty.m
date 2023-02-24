//
//  NSString+JSONBeauty.m
//  MacDevelopTools
//
//  Created by jk on 2022/5/27.
//  Copyright © 2022 JK. All rights reserved.
//

#import "NSString+JSONBeauty.h"

typedef enum : NSUInteger {
    JKNextCharacterTypeEOS, // End of string
    JKNextCharacterTypeNormal,
    JKNextCharacterTypeString, // "
    JKNextCharacterTypeDot, // ,
    JKNextCharacterTypeTransfer, // '\'
    JKNextCharacterTypeDictionaryStart, // {
    JKNextCharacterTypeDictionaryEnd, // }
    JKNextCharacterTypeArrayStart, // [
    JKNextCharacterTypeArrayEnd, // ]
    JKNextCharacterTypeWhiteOrNewLine, // white space or new line
} JKNextCharacterType;


typedef enum : NSUInteger {
    JKCircleTypeNone,
    JKCircleTypeString, //" "
    JKCircleTypeDictionary, // { }
    JKCircleTypeArray, // [ ]
} JKCircleType;

static NSCharacterSet *whiteNewLineCharacterSet;

@implementation NSString (JSONBeauty)

- (NSString *)beautyJSON
{
    NSString *trimStr = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger idx = 0;
    NSMutableString *resStr = [NSMutableString string];
    JKNextCharacterType type = [self checkNext:trimStr index:&idx];
    do {
        NSString *innerStr = [self checkCircleBeginWith:trimStr fromIndex:&idx atLayer:0 checkType:type];
        if (innerStr) {
            [resStr appendString:innerStr];
        }else{
            idx++;
        }
        type = [self checkNext:trimStr index:&idx];
    }while(type != JKNextCharacterTypeEOS);
    return resStr;
}

- (JKNextCharacterType)checkNext:(NSString *)trimStr index:(NSInteger *)idx
{
    if (*idx < 0 || *idx >= trimStr.length) {
        return JKNextCharacterTypeEOS;
    }
    char c = [trimStr characterAtIndex:*idx];
    switch (c) {
        case '{':
            return JKNextCharacterTypeDictionaryStart;
            break;
        case '}':
            return JKNextCharacterTypeDictionaryEnd;
            break;
        case '[':
            return JKNextCharacterTypeArrayStart;
            break;
        case ']':
            return JKNextCharacterTypeArrayEnd;
            break;
        case '"':
            return JKNextCharacterTypeString;
            break;
        case ',':
            return JKNextCharacterTypeDot;
            break;
        case '\\':
            return JKNextCharacterTypeTransfer;
            break;
        default:
            if (!whiteNewLineCharacterSet) {
                whiteNewLineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            }
            if ([whiteNewLineCharacterSet characterIsMember:c]) {
                return JKNextCharacterTypeWhiteOrNewLine;
            }else{
                return JKNextCharacterTypeNormal;
            }
            break;
    }
}

- (NSString *)checkCircleBeginWith:(NSString *)trimStr fromIndex:(NSInteger *)idx atLayer:(NSInteger)layer checkType:(JKNextCharacterType)type
{
    switch (type) {
        case JKNextCharacterTypeArrayStart:
        {
            return [self beautyArray:trimStr fromIndex:idx atLayer:layer];
        }
            break;
        case JKNextCharacterTypeDictionaryStart:
        {
            return [self beautyDictionary:trimStr fromIndex:idx atLayer:layer];
        }
            break;
        case JKNextCharacterTypeString:
        {
            return [self protectString:trimStr fromIndex:idx];
        }
            break;
        default:
            return nil;
            break;
    }
}

- (NSString *)beautyDictionary:(NSString *)trimStr fromIndex:(NSInteger *)idx atLayer:(NSInteger)layer
{
    NSString *padding = [@"" stringByPaddingToLength:layer * 2 withString:@" " startingAtIndex:0];
    NSMutableString *resStr = [NSMutableString string];
//    [self addNewLine:resStr padding:padding];
    JKNextCharacterType nextType = JKNextCharacterTypeDictionaryStart;
    do {
        if (nextType == JKNextCharacterTypeWhiteOrNewLine) {
        }else{
            [resStr appendFormat:@"%c",[trimStr characterAtIndex:*idx]];
            [self addNewLine:resStr withType:nextType padding:padding];
        }
        (*idx)++;
        nextType = [self checkNext:trimStr index:idx];
        NSString *checkInnerCircle = [self checkCircleBeginWith:trimStr fromIndex:idx atLayer:layer+1 checkType:nextType];
        if (checkInnerCircle) {
            [resStr appendString:checkInnerCircle];
            nextType = [self checkNext:trimStr index:idx];
        }
        if (nextType == JKNextCharacterTypeDictionaryEnd) {
            [self addNewLine:resStr padding:padding];
            [resStr appendFormat:@"%c",[trimStr characterAtIndex:*idx]];
            (*idx)++;
        }
    }while(nextType != JKNextCharacterTypeEOS && nextType != JKNextCharacterTypeDictionaryEnd);
    
    return resStr;
}

- (NSString *)beautyArray:(NSString *)trimStr fromIndex:(NSInteger *)idx atLayer:(NSInteger)layer
{
    NSString *padding = [@"" stringByPaddingToLength:layer * 2 withString:@" " startingAtIndex:0];
    NSMutableString *resStr = [NSMutableString string];
//    [self addNewLine:resStr padding:padding];
    JKNextCharacterType nextType = JKNextCharacterTypeArrayStart;
    do {
        if (nextType == JKNextCharacterTypeWhiteOrNewLine) {
        }else{
            [resStr appendFormat:@"%c",[trimStr characterAtIndex:*idx]];
            [self addNewLine:resStr withType:nextType padding:padding];
        }
        (*idx)++;
        nextType = [self checkNext:trimStr index:idx];
        NSString *checkInnerCircle = [self checkCircleBeginWith:trimStr fromIndex:idx atLayer:layer+1 checkType:nextType];
        if (checkInnerCircle) {
            [resStr appendString:checkInnerCircle];
            nextType = [self checkNext:trimStr index:idx];
        }
        if (nextType == JKNextCharacterTypeArrayEnd) {
            [self addNewLine:resStr padding:padding];
            [resStr appendFormat:@"%c",[trimStr characterAtIndex:*idx]];
            (*idx)++;
        }
    }while(nextType != JKNextCharacterTypeEOS && nextType != JKNextCharacterTypeArrayEnd);
    
    return resStr;
}

- (NSString *)protectString:(NSString *)trimStr fromIndex:(NSInteger *)idx
{
    NSMutableString *resStr = [NSMutableString string];
    JKNextCharacterType nextType = JKNextCharacterTypeString;
    do {
        [resStr appendFormat:@"%c",[trimStr characterAtIndex:*idx]];
        (*idx)++;
        nextType = [self checkNext:trimStr index:idx];
        if (nextType == JKNextCharacterTypeTransfer) {
            [resStr appendFormat:@"%c",[trimStr characterAtIndex:*idx]];
            (*idx)++;
        }
        if (nextType == JKNextCharacterTypeString) {
            [resStr appendFormat:@"%c",[trimStr characterAtIndex:*idx]];
            (*idx)++;
        }
    }while(nextType != JKNextCharacterTypeEOS && nextType != JKNextCharacterTypeString);
    
    return resStr;
}

- (void)addNewLine:(NSMutableString *)str withType:(JKNextCharacterType)type padding:(NSString *)padding
{
    if (type == JKNextCharacterTypeDot || type == JKNextCharacterTypeDictionaryStart || type == JKNextCharacterTypeArrayStart) {
        [self addNewLine:str padding:padding];
    }
}
- (void)addNewLine:(NSMutableString *)str padding:(NSString *)padding
{
    [str appendFormat:@"\n%@",padding];
}





- (NSString *)unBeautyJSON
{
    NSString *trimStr = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger idx = 0;
    NSMutableString *resStr = [NSMutableString string];
    JKNextCharacterType type = [self checkNext:trimStr index:&idx];
    do {
        NSString *innerStr = [self checkStringBeginWith:trimStr fromIndex:&idx checkType:type];
        if (innerStr) {
            [resStr appendString:innerStr];
        }else{
            idx++;
        }
        type = [self checkNext:trimStr index:&idx];
    }while(type != JKNextCharacterTypeEOS);
    return resStr;
}

- (NSString *)checkStringBeginWith:(NSString *)trimStr fromIndex:(NSInteger *)idx checkType:(JKNextCharacterType)type
{
    switch (type) {
        case JKNextCharacterTypeString:
            return [self protectString:trimStr fromIndex:idx];
        case JKNextCharacterTypeWhiteOrNewLine:
            return nil;
        case JKNextCharacterTypeEOS:
            return nil;
        default:
        {
            NSString *str = [NSString stringWithFormat:@"%c",[trimStr characterAtIndex:*idx]];
            (*idx)++;
            return str;
        }
            break;
    }
}


@end
