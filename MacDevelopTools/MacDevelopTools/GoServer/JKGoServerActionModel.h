//
//  JKGoServerActionModel.h
//  MacDevelopTools
//
//  Created by jk on 2022/6/9.
//  Copyright © 2022 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKGoServerActionModel : NSObject

@property(nonatomic, strong) NSString *nickName;
@property(nonatomic, assign) NSInteger actionPath;
@property(nonatomic, assign) NSInteger action;
@property(nonatomic, assign) BOOL isQuickCMD;
@property(nonatomic, strong) NSString *content;


+ (NSArray *)sortMemberKeysArr;

@end

NS_ASSUME_NONNULL_END
