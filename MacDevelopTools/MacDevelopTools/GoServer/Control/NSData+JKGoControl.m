//
//  NSData+JKGoControl.m
//  jkgocontrol
//
//  Created by jk on 2022/5/20.
//

#import "NSData+JKGoControl.h"

@implementation NSData (JKGoControl)

+ (NSData *)capData:(NSData *)srcData withLength:(NSInteger)length {
    if (srcData.length >= length) {
        return [srcData subdataWithRange:NSMakeRange(0, length)];
    }
    NSMutableData *resData = [[NSMutableData alloc]initWithData:srcData];
    NSInteger leftBytes = length - srcData.length;
    Byte left[leftBytes];
    memset(&left, 0, leftBytes);
    [resData appendBytes:&left length:leftBytes];
    return resData;
}

@end
