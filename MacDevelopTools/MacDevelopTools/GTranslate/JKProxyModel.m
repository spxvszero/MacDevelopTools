//
//  JKProxyModel.m
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/4/16.
//  Copyright © 2023 JK. All rights reserved.
//

#import "JKProxyModel.h"
#import "GTMBase64.h"

@implementation JKProxyModel

- (instancetype)initWithFileString:(NSString *)fileStr
{
    if (self = [super init]) {
        NSString *embStr = [[NSString alloc] initWithData:[GTMBase64 decodeString:fileStr] encoding:NSUTF8StringEncoding];
        NSArray *dataArr = [embStr componentsSeparatedByString:@":"];
        if (dataArr.count == 4) {
            self.proxyType = [dataArr[0] integerValue];
            self.host = [[NSString alloc] initWithData:[GTMBase64 decodeString:dataArr[1]] encoding:NSUTF8StringEncoding];
            self.username = [[NSString alloc] initWithData:[GTMBase64 decodeString:dataArr[2]] encoding:NSUTF8StringEncoding];
            self.password = [[NSString alloc] initWithData:[GTMBase64 decodeString:dataArr[3]] encoding:NSUTF8StringEncoding];
        }
    }
    return self;
}

- (NSString *)fileString
{
    NSString *b_host = [GTMBase64 stringByEncodingData:[self.host dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *b_name = [GTMBase64 stringByEncodingData:[self.username dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *b_pwd = [GTMBase64 stringByEncodingData:[self.password dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *embStr = [NSString stringWithFormat:@"%ld:%@:%@:%@",
                        self.proxyType,
                        b_host?:@"",
                        b_name?:@"",
                        b_pwd?:@""
                        ];
    
    return [GTMBase64 stringByEncodingData:[embStr dataUsingEncoding:NSUTF8StringEncoding]];
    
}

@end
