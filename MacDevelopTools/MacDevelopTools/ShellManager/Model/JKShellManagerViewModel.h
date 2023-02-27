//
//  JKShellManagerViewModel.h
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/2/27.
//  Copyright © 2023 JK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKShellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKShellManagerViewModel : NSObject

@property (nonatomic, assign, readonly) BOOL isGroup;
@property (nonatomic, weak) JKShellManagerViewModel *superModel;

- (instancetype)initWithGroup;
- (instancetype)initWithModel:(JKShellModel *)model;
- (JKShellModel *)attachModel;

- (instancetype)readFromDisk:(NSString *)filePath;
- (void)saveToDisk:(NSString *)filePath;

//Group
- (void)addModel:(JKShellManagerViewModel *)model atIndex:(NSInteger)idx;
- (void)moveModelFromIdx:(NSInteger)fromIdx toIdx:(NSInteger)toIdx;
- (void)removeModelAtIdx:(NSInteger)idx;
- (void)removeModel:(JKShellManagerViewModel *)model;
- (JKShellManagerViewModel *)modelAtIdex:(NSInteger)idx;
- (NSInteger)idxOfModel:(JKShellManagerViewModel *)model;
- (void)renameGroupName:(NSString *)groupName;
- (NSInteger)numberOfCount;

- (NSString *)displayName;


@end

NS_ASSUME_NONNULL_END
