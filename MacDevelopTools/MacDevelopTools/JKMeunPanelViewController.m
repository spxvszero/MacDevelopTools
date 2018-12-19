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
#import "JKWallPaperViewController.h"
#import "JKEncodingViewController.h"

#define kCollectionItemIdentify @"normal"

@interface JKMeunPanelViewController ()<NSCollectionViewDataSource,NSCollectionViewDelegate>

@property (weak) IBOutlet NSCollectionView *itemCollectionView;
@property (weak) IBOutlet NSView *containView;

@property (nonatomic, strong) NSMutableArray *viewControllerArr;
@property (nonatomic, strong) NSMutableDictionary *viewControllerDic;

@property (nonatomic, weak) NSView *currentView;

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
    self.viewControllerDic = [NSMutableDictionary dictionary];
    
    self.view.wantsLayer = YES;
    self.itemCollectionView.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.itemCollectionView.dataSource = self;
    self.itemCollectionView.delegate = self;
    self.itemCollectionView.selectable = YES;
    
    [self.itemCollectionView registerClass:[JKCollectionMenuPanelItem class] forItemWithIdentifier:kCollectionItemIdentify];
}

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
    
    [self changeToNewView:vc.view];
}

#pragma mark - tool

- (void)changeToNewView:(NSView *)view
{
    if (self.currentView.superview) {
        [self.currentView removeFromSuperview];
    }
    [self.containView addSubview:view];
    self.currentView = view;
    [self resizeWithView:view];
}

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
        NSViewController *vc = [sb instantiateInitialController];
        return vc;
    }
    
    if ([NSStringFromClass(class) isEqualToString:NSStringFromClass([JKWallPaperViewController class])]) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"WallPaper" bundle:nil];
        NSViewController *vc = [sb instantiateInitialController];
        return vc;
    }
    if ([NSStringFromClass(class) isEqualToString:NSStringFromClass([JKEncodingViewController class])]) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Encoding" bundle:nil];
        NSViewController *vc = [sb instantiateInitialController];
        return vc;
    }
    
    return nil;
}

#pragma mark - getter

- (NSMutableArray *)viewControllerArr
{
    if (!_viewControllerArr) {
        _viewControllerArr = [NSMutableArray arrayWithObjects:[PushViewController class],[JKWallPaperViewController class],[JKEncodingViewController class], nil];
    }
    return _viewControllerArr;
}

@end
