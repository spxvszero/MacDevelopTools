//
//  JKItemsManager.m
//  MacDevelopTools
//
//  Created by jk on 2020/3/25.
//  Copyright © 2020 JK. All rights reserved.
//

#import "JKItemsManager.h"


@implementation JKItemsObject
@end


@interface JKItemsManager()

@property (nonatomic, strong) NSMutableArray *listItemsArr;

@end
@implementation JKItemsManager



- (NSMutableArray<JKItemsObject *> *)obtainItemsList
{
    return self.listItemsArr;
}

- (void)readFromPlist
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"items" ofType:@"plist"];
    NSArray *listArr = [NSArray arrayWithContentsOfFile:plistPath];
    
    if (listArr && listArr.count > 0) {
        [self seralizeListItems:listArr];
    }
}

- (void)seralizeListItems:(NSArray *)listArr
{
    for (NSDictionary *item in listArr) {
        JKItemsObject *obj = [[JKItemsObject alloc] init];
        obj.visable = [[item objectForKey:@"Visable"] boolValue];
        obj.toolTip = [item objectForKey:@"ToolTip"];
        obj.itemImageName = [item objectForKey:@"ItemImageName"];
        obj.storyBoardName = [item objectForKey:@"StoryBoardName"];
        obj.vcClassName = [item objectForKey:@"ClassName"];
        
        [self.listItemsArr addObject:obj];
    }
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
        }
    });
    return obj;
}

@end
