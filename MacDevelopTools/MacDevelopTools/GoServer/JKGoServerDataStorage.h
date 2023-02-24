//
//  JKGoServerDataStorage.h
//  MacDevelopTools
//
//  Created by jk on 2022/5/25.
//  Copyright © 2022 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKGoServerDataModel.h"
#import "JKGoServerActionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKGoServerDataStorage : NSObject

+ (NSArray<JKGoServerDataModel *> *)serverListFromDisk;

+ (void)saveServerListInDisk:(NSArray<JKGoServerDataModel *> *)list;


+ (NSArray<JKGoServerActionModel *> *)actionsListFromDisk;

+ (void)saveActionsListInDisk:(NSArray<JKGoServerActionModel *> *)list;

@end

NS_ASSUME_NONNULL_END
