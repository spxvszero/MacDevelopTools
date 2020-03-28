//
//  JKItemsManager.h
//  MacDevelopTools
//
//  Created by jk on 2020/3/25.
//  Copyright © 2020 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKItemsObject : NSObject

@property (nonatomic, assign) BOOL visable;
@property (nonatomic, strong) NSString *toolTip;
@property (nonatomic, strong) NSString *itemImageName;
@property (nonatomic, strong) NSString *storyBoardName;
@property (nonatomic, strong) NSString *vcClassName;

- (instancetype)initWithDic:(NSDictionary *)dic;
- (NSDictionary *)dicValue;

@end



@interface JKItemsManager : NSObject

+ (instancetype)defaultManager;

- (NSMutableArray<JKItemsObject *> *)obtainItemsList;

@end

NS_ASSUME_NONNULL_END
