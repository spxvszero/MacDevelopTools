//
//  JKShellManagerViewModel.m
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/2/27.
//  Copyright © 2023 JK. All rights reserved.
//

#import "JKShellManagerViewModel.h"
#import "JKMacFileStoragePath.h"

@interface JKShellManagerViewModel ()<NSCoding, NSSecureCoding>

@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSMutableArray<JKShellManagerViewModel *> *containerArr;
@property (nonatomic, strong) JKShellModel *attachModel;

@end

@implementation JKShellManagerViewModel

+ (BOOL)supportsSecureCoding
{
    return true;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _isGroup = [coder decodeBoolForKey:@"isGroup"];
        if (_isGroup) {
            self.groupName = [coder decodeObjectForKey:@"groupName"];
            self.containerArr = [coder decodeObjectForKey:@"containerArr"];
            
            //relation
            for (JKShellManagerViewModel *model in self.containerArr) {
                model.superModel = self;
            }
        }else{
            self.attachModel = [coder decodeObjectForKey:@"attachModel"];
        }
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBool:self.isGroup forKey:@"isGroup"];
    if (self.isGroup) {
        [coder encodeObject:self.groupName forKey:@"groupName"];
        [coder encodeObject:self.containerArr forKey:@"containerArr"];
    }else{
        [coder encodeObject:self.attachModel forKey:@"attachModel"];        
    }
}

- (instancetype)initWithGroup
{
    if (self = [super init]) {
        _isGroup = true;
        _groupName = @"Untitled";
        self.containerArr = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithModel:(JKShellModel *)model
{
    if (self = [super init]) {
        _isGroup = false;
        self.attachModel = model;
    }
    return self;
}

- (void)addModel:(JKShellManagerViewModel *)model atIndex:(NSInteger)idx
{
    if (idx >= 0 && idx <= self.containerArr.count) {
        [self.containerArr insertObject:model atIndex:idx];
        model.superModel = self;
    }else{
        NSLog(@"Insert Object Out of bounds %ld to [0..%ld]",idx, self.containerArr.count);
    }
}

- (void)moveModelFromIdx:(NSInteger)fromIdx toIdx:(NSInteger)toIdx
{
    if (fromIdx == toIdx) {
        return;
    }
    if (fromIdx >= 0 && fromIdx < self.containerArr.count &&
        toIdx >= 0 && toIdx < self.containerArr.count) {
        JKShellManagerViewModel *model = [self.containerArr objectAtIndex:fromIdx];
        NSLog(@"Add To %ld in %ld",toIdx, self.containerArr.count);
        [self addModel:model atIndex:toIdx];
        if (toIdx < fromIdx) {
            fromIdx += 1;
        }
        NSLog(@"Remove To %ld in %ld",fromIdx, self.containerArr.count);
        [self removeModelAtIdx:fromIdx];
        model.superModel = self;
        
    }else{
        NSLog(@"Move Object Out of bounds from %ld to %ld in [0..%ld]",fromIdx, toIdx, self.containerArr.count);
    }
}

- (void)removeModelAtIdx:(NSInteger)idx
{
    if (idx >= 0 && idx < self.containerArr.count) {
        JKShellManagerViewModel *model = [self.containerArr objectAtIndex:idx];
        [self.containerArr removeObjectAtIndex:idx];
        model.superModel = nil;
    }else{
        NSLog(@"Remove Object Out of bounds %ld to [0..%ld)",idx, self.containerArr.count);
    }
}

- (void)removeModel:(JKShellManagerViewModel *)model
{
    if (model) {
        [self.containerArr removeObject:model];
    }
}

- (JKShellManagerViewModel *)modelAtIdex:(NSInteger)idx
{
    if (idx >= 0 && idx < self.containerArr.count) {
        return [self.containerArr objectAtIndex:idx];
    }else{
        NSLog(@"Get Model Object Out of bounds %ld to [0..%ld)",idx, self.containerArr.count);
        return nil;
    }
}

- (NSInteger)idxOfModel:(JKShellManagerViewModel *)model
{
    if (model) {
        return [self.containerArr indexOfObject:model];
    }else{
        return NSNotFound;
    }
}

- (NSInteger)numberOfCount
{
    if (self.isGroup) {
        return self.containerArr.count;
    }else{
        if (self.attachModel) {
            return 1;
        }else{
            return 0;
        }
    }
}

- (void)renameGroupName:(NSString *)groupName
{
    if (groupName.length > 0) {
        self.groupName = groupName;
    }
}

- (NSString *)displayName
{
    if (self.isGroup) {
        return self.groupName;
    }else{
        return self.attachModel.name;
    }
}

- (void)updateName:(NSString *)name
{
    if (self.isGroup) {
        self.groupName = name;
    }else{
        self.attachModel.name = name;
    }
}

- (JKShellModel *)attachModel
{
    return _attachModel;
}


- (void)saveToDisk
{
    NSString *filePath = [[self class] shellDataPath];

    if (@available(macOS 10.13, *)) {
        NSError *err;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:false error:&err];
        NSLog(@"archiver object error -- %@",err);
        [data writeToFile:filePath atomically:true];
    }else{
        [NSKeyedArchiver archiveRootObject:self toFile:filePath];
    }
}

+ (JKShellManagerViewModel *)readFromDisk
{
    NSString *filePath = [JKShellManagerViewModel shellDataPath];
    if (@available(macOS 10.13, *)) {
        NSError *err;
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        JKShellManagerViewModel *model = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[JKShellManagerViewModel class],[NSMutableArray class],[JKShellModel class], nil] fromData:data error:&err];
        NSLog(@"unarchiver object error -- %@",err);
        return model;
    }else{
        return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
}

+ (NSString *)shellDataPath
{
    // Get a file path to save the archived object to
    NSString *filePath = [[JKMacFileStoragePath shellManagerDataDirPath] stringByAppendingPathComponent:@"ShellDatas"];
    return filePath;
}

@end
