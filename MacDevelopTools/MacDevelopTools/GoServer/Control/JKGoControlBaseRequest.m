//
//  JKGoControlBaseRequest.m
//  jkgocontrol
//
//  Created by jk on 2022/5/20.
//

#import "JKGoControlBaseRequest.h"
#import "NSData+JKGoControl.h"

@implementation JKGoControlBaseRequest

+ (instancetype)requestWithHostUrl:(NSString *)hostUrl secret:(NSString *)secret iv:(NSString *)iv
{
    JKGoControlBaseRequest *req = [[JKGoControlBaseRequest alloc] init];
    req.hostUrl = hostUrl;
    req.secret = secret;
    req.iv = iv;
    return req;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.sessionUUID = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (NSData *)secretData
{
    if (!_secretData) {
        _secretData = [NSData capData:[self.secret dataUsingEncoding:NSUTF8StringEncoding] withLength:32];
    }
    return _secretData;
}

- (void)setSecret:(NSString *)secret
{
    _secret = secret;
    self.secretData = [NSData capData:[self.secret dataUsingEncoding:NSUTF8StringEncoding] withLength:32];
}

- (NSData *)ivData
{
    if (!_ivData) {
        _ivData = [NSData capData:[self.iv dataUsingEncoding:NSUTF8StringEncoding] withLength:16];
    }
    return _ivData;
}

- (void)setIv:(NSString *)iv
{
    _iv = iv;
    self.ivData = [NSData capData:[self.iv dataUsingEncoding:NSUTF8StringEncoding] withLength:16];
}

@end
