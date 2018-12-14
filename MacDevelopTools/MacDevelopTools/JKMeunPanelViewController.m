//
//  JKMeunPanelViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/13.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKMeunPanelViewController.h"
#import "JKCollectionMenuPanelItem.h"
#import "PushViewController.h"

#define kCollectionItemIdentify @"normal"

@interface JKMeunPanelViewController ()<NSCollectionViewDataSource,NSCollectionViewDelegate>

@property (weak) IBOutlet NSCollectionView *itemCollectionView;
@property (weak) IBOutlet NSView *containView;

@property (nonatomic, strong) NSMutableArray *viewControllerArr;
@property (nonatomic, strong) NSMutableDictionary *viewControllerDic;

@end

@implementation JKMeunPanelViewController

+ (JKMeunPanelViewController *)fromStoryBoard
{
    NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    JKMeunPanelViewController *vc = [sb instantiateControllerWithIdentifier:NSStringFromClass([JKMeunPanelViewController class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    
    self.view.wantsLayer = YES;
    self.itemCollectionView.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.itemCollectionView.dataSource = self;
    self.itemCollectionView.delegate = self;
    self.itemCollectionView.selectable = YES;
    
    [self.itemCollectionView registerClass:[JKCollectionMenuPanelItem class] forItemWithIdentifier:kCollectionItemIdentify];
}


//- (void)configureCollectionView
//{
//    NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc] init];
//
//    // 1
//    let flowLayout = NSCollectionViewFlowLayout()
//    flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
//    flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
//    flowLayout.minimumInteritemSpacing = 20.0
//    flowLayout.minimumLineSpacing = 20.0
//    collectionView.collectionViewLayout = flowLayout
//    // 2
//    view.wantsLayer = true
//    // 3
//    collectionView.layer?.backgroundColor = NSColor.blackColor().CGColor
//}

#pragma mark - collectionview datasource

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewControllerArr.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    JKCollectionMenuPanelItem *item = [collectionView makeItemWithIdentifier:kCollectionItemIdentify forIndexPath:indexPath];
    
    return item;
}

#pragma mark - collectionview delegate

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    NSLog(@"index path -- %@",indexPaths);
    NSIndexPath *indexP = indexPaths.anyObject;
    Class className = [self.viewControllerArr objectAtIndex:indexP.item];
    NSViewController *vc = [self.viewControllerDic objectForKey:NSStringFromClass(className)];
    if (!vc) {
        vc = [self getVCFromClass:className];
        [self.viewControllerDic setObject:vc forKey:NSStringFromClass(className)];
    }
    [self.containView addSubview:vc.view];
    [self resizeWithView:vc.view];
}

#pragma mark - tool

- (void)resizeWithView:(NSView *)view
{
    if (self.MeunSizeChangeBlock) {
        self.MeunSizeChangeBlock(NSMakeSize(view.bounds.size.width + 20, view.bounds.size.height + 50));
    }
}

- (NSViewController *)getVCFromClass:(Class)class
{
    if ([NSStringFromClass(class) isEqualToString:NSStringFromClass([PushViewController class])]) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"SmartPush" bundle:nil];
        PushViewController *vc = [sb instantiateInitialController];
        return vc;
    }
    
    return nil;
}

#pragma mark - getter

- (NSMutableArray *)viewControllerArr
{
    if (!_viewControllerArr) {
        _viewControllerArr = [NSMutableArray arrayWithObjects:[PushViewController class], nil];
    }
    return _viewControllerArr;
}

@end
