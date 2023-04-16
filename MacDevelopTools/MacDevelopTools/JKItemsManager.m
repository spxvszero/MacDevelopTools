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
    NSMutableArray *resultArr = [NSMutableArray array];
    //try to read from sand box.
    NSString *plistPath = [self itemsListSandboxPath];
    NSLog(@"read item list from sandbox : %@",plistPath);
    NSArray *listArr = [NSArray arrayWithContentsOfFile:plistPath];
    if (!listArr || listArr.count <= 0) {
        NSLog(@"sandbox item list is empty.");
        plistPath = [self itemsListPath];
        listArr = [NSArray arrayWithContentsOfFile:plistPath];
        [resultArr addObjectsFromArray:listArr];
    }else{
        NSLog(@"sandbox item list is exsit. check if need sync.");
        //check if need sync list.
        NSString *packPlistPath = [self itemsListPath];
        NSArray *packListArr = [NSArray arrayWithContentsOfFile:packPlistPath];
        if (listArr.count != packListArr.count) {
            NSLog(@"found item list is not sync with current app. update local list.");
            //need sync list cause pack list have new feature.
            //new feature always append to the tail, but in case exception condition, we loop for it.
            for (NSDictionary *newFeature in packListArr) {
                BOOL findOne = false;
                NSString *nName = [newFeature objectForKey:@"ClassName"];
                for (NSDictionary *oldFeature in listArr) {
                    NSString *oName = [oldFeature objectForKey:@"ClassName"];
                    if ([oName isKindOfClass:[NSString class]] && [oName isEqualToString:nName]) {
                        findOne = true;
                        [resultArr addObject:oldFeature];
                        break;
                    }
                }
                if (findOne == false) {
                    [resultArr addObject:newFeature];
                }
            }
        }else{
            NSLog(@"no need sync item list.");
            [resultArr addObjectsFromArray:listArr];
        }
    }
    
    if (resultArr && resultArr.count > 0) {
        [self seralizeListItems:resultArr];
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
