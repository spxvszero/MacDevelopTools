//
//  JKGoControlBaseRequest.h
//  jkgocontrol
//
//  Created by jk on 2022/5/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKGoControlBaseRequest : NSObject

@property(nonatomic, strong) NSString *sessionUUID;
@property(nonatomic, strong) NSString *hostUrl;
@property(nonatomic, strong) NSString *secret;
@property(nonatomic, strong) NSString *iv;
@property(nonatomic, strong) NSData *secretData;
@property(nonatomic, strong) NSData *ivData;

//runtime data
@property(nonatomic, strong) NSString *accessKey;
@property(nonatomic, assign) NSInteger seq;

+ (instancetype)requestWithHostUrl:(NSString *)hostUrl secret:(NSString *)secret iv:(NSString *)iv;

@end

NS_ASSUME_NONNULL_END
