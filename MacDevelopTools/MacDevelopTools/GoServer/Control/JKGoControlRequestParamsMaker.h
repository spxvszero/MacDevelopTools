//
//  JKGoControlRequestParamsMaker.h
//  jkgocontrol
//
//  Created by jk on 2022/5/20.
//

#import <Foundation/Foundation.h>
#import "JKGoControlBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ActionCategoryVersion,
    ActionCategoryConfig,
    ActionCategoryCmd,
    ActionCategoryUpdate,
} JKGoControlActionCategory;

typedef enum : NSUInteger {
    ActionTypeMin = 100,
    ActionTypeGet = ActionTypeMin,
    ActionTypeModify,
    ActionTypeDelete,
} JKGoControlActionType;

@interface JKGoControlRequestParamsMaker : NSObject

+ (NSDictionary *)makeAction:(JKGoControlActionCategory)category type:(JKGoControlActionType)type data:(id)dataObj;

//Using in networkmanager
+ (NSDictionary *)authRequest:(JKGoControlBaseRequest *)request;
+ (NSDictionary *)actionRequest:(JKGoControlBaseRequest *)request withDic:(NSDictionary *)actionDic;

+ (NSString *)describeNameForActionCategory:(JKGoControlActionCategory)catagory;
+ (NSString *)describeNameForActionType:(JKGoControlActionType)type;

@end

NS_ASSUME_NONNULL_END
