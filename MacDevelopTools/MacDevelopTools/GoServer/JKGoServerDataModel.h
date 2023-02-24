//
//  JKGoServerDataModel.h
//  MacDevelopTools
//
//  Created by jk on 2022/5/25.
//  Copyright © 2022 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKGoControlBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    JKGoServerLinkStatusOff,
    JKGoServerLinkStatusFailed,
    JKGoServerLinkStatusConnecting,
    JKGoServerLinkStatusOn,
} JKGoServerLinkStatus;

@interface JKGoServerDataModel : NSObject

@property(nonatomic, strong) NSString *host;
@property(nonatomic, strong) NSString *secret;
@property(nonatomic, strong) NSString *iv;

//memory
@property(nonatomic, assign) JKGoServerLinkStatus linkStatus;
@property(nonatomic, strong) JKGoControlBaseRequest *req;
@property(nonatomic, strong) NSString *reqIdentify;// if exist, means has been connected, see req.AccessKey if exist
@property(nonatomic, assign) NSInteger lastFailedCode;// if exist, means connection failed
@property(nonatomic, assign) CGFloat timeInterval; // timeInterval between request
@property(nonatomic, strong) NSString *version;

//optional
@property(nonatomic, strong) NSString *nick;
@property(nonatomic, strong) NSString *location;

+ (NSInteger)numbersOfColumns;
+ (JKGoServerDataModel *)exampleModel;
+ (NSArray *)sortMemberKeysArr;

- (instancetype)initWithDic:(NSDictionary *)dic;
- (NSDictionary *)dicValue;

@end

NS_ASSUME_NONNULL_END
