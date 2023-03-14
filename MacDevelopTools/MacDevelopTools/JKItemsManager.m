//
//  JKItemsManager.m
//  MacDevelopTools
//
//  Created by jk on 2020/3/25.
//  Copyright © 2020 JK. All rights reserved.
//

#import "JKItemsManager.h"
#import "JKMacFileStoragePath.h"

@implementation JKItemsObject
- (NSDictionary *)dicValue
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@(self.visable) forKey:@"Visable"];
    [dic setObject:self.toolTip?:@"" forKey:@"ToolTip"];
    [dic setObject:self.itemImageName?:@"" forKey:@"ItemImageName"];
    [dic setObject:self.storyBoardName?:@"" forKey:@"StoryBoardName"];
    [dic setObject:self.vcClassName?:@"" forKey:@"ClassName"];
    return dic;
    
}

- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        if (dic) {
            self.visable = [[dic objectForKey:@"Visable"] boolValue];
            self.toolTip = [dic objectForKey:@"ToolTip"];
            self.itemImageName = [dic objectForKey:@"ItemImageName"];
            self.storyBoardName = [dic objectForKey:@"StoryBoardName"];
            self.vcClassName = [dic objectForKey:@"ClassName"];
        }
    }
    return self;
}
@end


@interface JKItemsManager()

@property (nonatomic, strong) NSMutableArray *listItemsArr;

@end
@implementation JKItemsManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (NSMutableArray<JKItemsObject *> *)obtainItemsList
{
    return self.listItemsArr;
}

- (void)readFromPlist
{
    //try to read from sand box.
    NSString *plistPath = [self itemsListSandboxPath];
    NSArray *listArr = [NSArray arrayWithContentsOfFile:plistPath];
    if (!listArr || listArr.count <= 0) {
        plistPath = [self itemsListPath];
        listArr = [NSArray arrayWithContentsOfFile:plistPath];
    }
    
    if (listArr && listArr.count > 0) {
        [self seralizeListItems:listArr];
    }
}

- (void)seralizeListItems:(NSArray *)listArr
{
    for (NSDictionary *item in listArr) {
        JKItemsObject *obj = [[JKItemsObject alloc] initWithDic:item];
        [self.listItemsArr addObject:obj];
    }
}

- (void)updatePlistFile
{
    NSMutableArray *writeArr = [NSMutableArray array];
    for (JKItemsObject *obj in self.listItemsArr) {
        [writeArr addObject:[obj dicValue]];
    }
    BOOL res = [writeArr writeToFile:[self itemsListSandboxPath] atomically:true];
    NSLog(@"write Item res %@",res ?@"success":@"failed");
}

- (NSString *)itemsListPath
{
    return [[NSBundle mainBundle] pathForResource:@"items" ofType:@"plist"];
}
- (NSString *)itemsListSandboxPath
{
    return [[JKMacFileStoragePath itemsManagerListDirPath] stringByAppendingPathComponent:@"items.plist"];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemListChange) name:kJKStatusItemListChangeNotification object:nil];
}

- (void)itemListChange
{
    [self updatePlistFile];
}

#pragma mark - getter

- (NSMutableArray *)listItemsArr
{
    if (!_listItemsArr) {
        _listItemsArr = [NSMutableArray array];
    }
    return _listItemsArr;
}

#pragma mark - 单例

+ (instancetype)defaultManager
{
    return [[self alloc] init];
}

- (instancetype)init {
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((obj = [super init])) {
            [self readFromPlist];
            [self addNotification];
        }
    });
    return obj;
}

@end
