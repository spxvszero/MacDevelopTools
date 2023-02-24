//
//  JKGoControlNetworkManager.h
//  jkgocontrol
//
//  Created by jk on 2022/5/20.
//

#import <Foundation/Foundation.h>
#import "JKGoControlBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKGoControlNetworkManager : NSObject

- (void)requestWithIdentify:(NSString *)identify params:(NSDictionary *)actionParams success:(void (^)(BOOL res, NSInteger errCode, id dataObject))successBlock failed:(void(^)(NSError *err))failedBlock;

//Auth Request will renew request accessKey, return Identify using with other request
- (NSString *)authRequestWithRequest:(JKGoControlBaseRequest *)request success:(void (^)(BOOL res, NSInteger errCode))successBlock failed:(void(^)(NSError *err))failedBlock;

@end

NS_ASSUME_NONNULL_END
