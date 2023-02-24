//
//  JKGoControlNetworkManager.m
//  jkgocontrol
//
//  Created by jk on 2022/5/20.
//

#import "JKGoControlNetworkManager.h"
#import "AFHTTPSessionManager.h"
#import "NSData+YYAdd.h"
#import "JKGoControlRequestParamsMaker.h"
#import "JKGoControlNetworkRoute.h"

@interface JKGoControlNetworkManager ()

@property(nonatomic, strong) AFHTTPSessionManager *httpSessionManager;
@property(nonatomic, strong) NSMutableDictionary<NSString *, JKGoControlBaseRequest *> *requestDic;

@end
@implementation JKGoControlNetworkManager


- (instancetype)init
{
    if (self = [super init]) {
        self.requestDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (NSString *)authRequestWithRequest:(JKGoControlBaseRequest *)request success:(nonnull void (^)(BOOL, NSInteger))successBlock failed:(nonnull void (^)(NSError * _Nonnull))failedBlock
{
    NSDictionary *params = [JKGoControlRequestParamsMaker authRequest:request];
    NSDictionary *encryptParams = [self encryptRequest:params withSecretData:request.secretData ivData:request.ivData];
    [self saveRequest:request];
    NSLog(@"Send Post Request To %@ \n%@\n Encrypt : %@", kRoute_Auth(request.hostUrl),params, encryptParams);
    __weak typeof(self) weakself = self;
    [self.httpSessionManager POST:kRoute_Auth(request.hostUrl) parameters:encryptParams headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success Response : %@",responseObject);
        NSString *dataStr = [responseObject objectForKey:@"data"];
        NSNumber *code = [responseObject objectForKey:@"code"];
        JKGoControlBaseRequest *decrpytRequest = [weakself getRequestForHostUrl:[weakself getUrlHostPortStr:task.originalRequest.URL]];
        BOOL res = false;
        if (decrpytRequest) {
            NSString *decrpytStr = [weakself decryptResponse:dataStr withSecretData:decrpytRequest.secretData ivData:decrpytRequest.ivData];
            decrpytRequest.accessKey = decrpytStr;
            decrpytRequest.seq = 1;
            NSLog(@"Decrpyt Success : %@",decrpytStr);
            res = true;
        }
        if (successBlock) {
            successBlock(res, [code integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed Response : %@",error);
        if (failedBlock) {
            failedBlock(error);
        }
    }];
    return request.hostUrl;
}

- (void)requestWithIdentify:(NSString *)identify params:(NSDictionary *)actionParams success:(void (^)(BOOL, NSInteger, id _Nonnull))successBlock failed:(void (^)(NSError * _Nonnull))failedBlock
{
    JKGoControlBaseRequest *request = [self getRequestForHostUrl:identify];
    if (!request) {
        return;
    }
    NSDictionary *params = [JKGoControlRequestParamsMaker actionRequest:request withDic:actionParams];
    NSDictionary *encryptParams = [self encryptRequest:params withSecretData:request.secretData ivData:request.ivData];
    NSLog(@"Send Post Request To %@ \n%@\n Encrypt : %@", kRoute_Action(request.hostUrl),params, encryptParams);
    __weak typeof(self) weakself = self;
    [self.httpSessionManager POST:kRoute_Action(request.hostUrl) parameters:encryptParams headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success Response : %@",responseObject);
        NSString *dataStr = [responseObject objectForKey:@"data"];
        NSNumber *code = [responseObject objectForKey:@"code"];
        BOOL res = false;
        NSString *decrpytStr = nil;
        JKGoControlBaseRequest *decrpytRequest = [weakself getRequestForHostUrl:[weakself getUrlHostPortStr:task.originalRequest.URL]];
        decrpytRequest.seq += 1;
        if ([code integerValue] == JKGoControlResponseCode_Suc) {
            if (decrpytRequest) {
                decrpytStr = [weakself decryptResponse:dataStr withSecretData:decrpytRequest.secretData ivData:decrpytRequest.ivData];
                NSLog(@"Decrpyt Success : %@",decrpytStr);
                res = true;
            }
        }
        if (successBlock) {
            successBlock(res, [code integerValue], decrpytStr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed Response : %@",error);
        if (failedBlock) {
            failedBlock(error);
        }
    }];
}

- (NSString *)getUrlHostPortStr:(NSURL *)url
{
    if (url.port && url.port > 0) {
        return [NSString stringWithFormat:@"%@://%@:%@",url.scheme,url.host,url.port];
    }else{
        return [NSString stringWithFormat:@"%@://%@",url.scheme,url.host];
    }
}


- (NSDictionary *)encryptRequest:(NSDictionary *)req withSecretData:(NSData *)secretData ivData:(NSData *)ivData
{
    NSData *reqData = [NSJSONSerialization dataWithJSONObject:req options:0 error:nil];
    NSData *encryptedData = [reqData aes256EncryptWithKey:secretData iv:ivData];
    
    NSDictionary *reqDic = @{@"data":[encryptedData base64EncodedString]};
    return reqDic;
}

- (NSString *)decryptResponse:(NSString *)respStr withSecretData:(NSData *)secretData ivData:(NSData *)ivData
{
    NSData *data = [NSData dataWithBase64EncodedString:respStr];
    NSString *decryptStr = [[data aes256DecryptWithkey:secretData iv:ivData] utf8String];
    return decryptStr;
}

- (void)saveRequest:(JKGoControlBaseRequest *)request
{
    if (!request || request.hostUrl.length <= 0) {
        return;
    }
    [self.requestDic setObject:request forKey:request.hostUrl];
}

- (JKGoControlBaseRequest *)getRequestForHostUrl:(NSString *)hostUrl
{
    if (hostUrl.length <= 0) {
        return nil;
    }
    return [self.requestDic objectForKey:hostUrl];
}

- (AFHTTPSessionManager *)httpSessionManager
{
    // Lazy-loading
    if (_httpSessionManager == nil) {
        _httpSessionManager = [[AFHTTPSessionManager alloc] init];
        _httpSessionManager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
        _httpSessionManager.requestSerializer.timeoutInterval = 20.f;
        [_httpSessionManager setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest *(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request) {
            return request;
        }];
    }
    return _httpSessionManager;
}


@end
