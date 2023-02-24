//
//  JKGoServerDataModel.m
//  MacDevelopTools
//
//  Created by jk on 2022/5/25.
//  Copyright © 2022 JK. All rights reserved.
//

#import "JKGoServerDataModel.h"
#import "JKGoControlNetworkRoute.h"

@implementation JKGoServerDataModel

- (NSDictionary *)dicValue
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.host?:@"" forKey:@"Host"];
    [dic setObject:self.secret?:@"" forKey:@"Secret"];
    [dic setObject:self.iv?:@"" forKey:@"Iv"];
    [dic setObject:self.nick?:@"" forKey:@"Nick"];
    [dic setObject:self.location?:@"" forKey:@"Location"];
    
    [dic setObject:self.req.sessionUUID?:@"" forKey:@"UUID"];
    [dic setObject:self.req.accessKey?:@"" forKey:@"AccessKey"];
    
    return dic;
    
}

- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        if (dic) {
            NSString *uuid = [dic objectForKey:@"UUID"];
            JKGoControlBaseRequest *req;
            if (uuid && uuid.length > 0) {
                req = [JKGoControlBaseRequest new];
                req.sessionUUID = uuid;
                req.accessKey = [dic objectForKey:@"AccessKey"];
            }else{
                req = [[JKGoControlBaseRequest alloc] init];
            }
            self.req = req;
            
            self.host = [dic objectForKey:@"Host"];
            self.secret = [dic objectForKey:@"Secret"];
            self.iv = [dic objectForKey:@"Iv"];
            self.nick = [dic objectForKey:@"Nick"];
            self.location = [dic objectForKey:@"Location"];
        }
    }
    return self;
}

- (void)setHost:(NSString *)host
{
    _host = host;
    self.req.hostUrl = [NSString stringWithFormat:@"http://%@",host];
}

- (void)setSecret:(NSString *)secret
{
    _secret = secret;
    self.req.secret = secret;
}

- (void)setIv:(NSString *)iv
{
    _iv = iv;
    self.req.iv = iv;
}

- (JKGoServerLinkStatus)linkStatus
{
    if (self.reqIdentify) {
        if (self.req.accessKey && self.req.accessKey.length > 0) {
            return JKGoServerLinkStatusOn;
        }else{
            if (self.lastFailedCode != 0 || self.lastFailedCode != JKGoControlResponseCode_Suc) {
                return JKGoServerLinkStatusFailed;
            }else{
                return JKGoServerLinkStatusConnecting;                
            }
        }
    }else{
        return JKGoServerLinkStatusOff;
    }
}

+ (JKGoServerDataModel *)exampleModel
{
    JKGoServerDataModel *model = [[JKGoServerDataModel alloc] init];
    model.host = @"0.0.0.0:1234";
    model.secret = @"secret";
    model.iv = @"iv";
    model.nick = @"nick";
    model.location = @"location";
    model.version = @"";
    return model;
}

+ (NSArray *)sortMemberKeysArr
{
    return @[@"version",@"host",@"nick",@"linkStatus",@"location",@"lastRequest",@"time"];
}

+ (NSInteger)numbersOfColumns
{
    return 6;
}

@end
