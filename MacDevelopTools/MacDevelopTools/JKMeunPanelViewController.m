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
#import "JKJSONModelViewController.h"
#import "JKResizeImageViewController.h"
#import "JKMoveFileViewController.h"
#import "JKStatusIconManagerViewController.h"
#import "JKImageInfoViewController.h"
#import "JKAutoPackViewController.h"
#import "JKQRCodeViewController.h"
#import "JKJSONFormatViewController.h"
#import "JKShellManagerViewController.h"
#import "JKClockViewController.h"
#import "JKItemsManager.h"

#define kCollectionItemIdentify @"normal"

@interface JKMeunPanelViewController ()<NSCollectionViewDataSource,NSCollectionViewDelegate,NSCollectionViewDelegateFlowLayout>

@property (weak) IBOutlet NSCollectionView *itemCollectionView;
@property (weak) IBOutlet NSView *containView;

@property (nonatomic, strong) NSMutableDictionary *vcNameToSbDic;
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
    
    [self addNotification];
    
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
    return [[JKItemsManager defaultManager] obtainItemsList].count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    JKCollectionMenuPanelItem *item = [collectionView makeItemWithIdentifier:kCollectionItemIdentify forIndexPath:indexPath];
    
    NSArray *arr = [[JKItemsManager defaultManager] obtainItemsList];
    
    JKItemsObject *obj = [arr objectAtIndex:indexPath.item];
    
    item.toolTips = kJKHasStringValue(obj.toolTip)?obj.toolTip:@"No Description";
    item.imgName = kJKHasStringValue(obj.itemImageName)?obj.itemImageName:@"bug";
    
    return item;
}

#pragma mark - collectionview delegate

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    NSLog(@"index path -- %@",indexPaths);
    NSIndexPath *indexP = indexPaths.anyObject;
    
    NSArray *arr = [[JKItemsManager defaultManager] obtainItemsList];
    
    JKItemsObject *obj = [arr objectAtIndex:indexP.item];
    
    NSViewController *vc = [self.viewControllerDic objectForKey:obj.vcClassName];
    if (!vc) {
        if (![obj.vcClassName isKindOfClass:[NSString class]] || obj.vcClassName.length <= 0) {
            NSLog(@"Failed To Load View Controller , class name is unavailiable");
            return;
        }
        vc = [self getVCFromClassName:obj.vcClassName sbName:obj.storyBoardName];
        if (!vc) {
            NSLog(@"Failed To Load View Controller , View Controller object not found");
            return;
        }
        [self.viewControllerDic setObject:vc forKey:obj.vcClassName];
    }
    
    [self changeToNewView:vc.view];
}

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = [[JKItemsManager defaultManager] obtainItemsList];
    
    JKItemsObject *obj = [arr objectAtIndex:indexPath.item];
    
    if (obj.visable) {
        return NSMakeSize(40, 30);
    }else{
        return NSMakeSize(0.00001, 30);
    }
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (NSEdgeInsets)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return NSEdgeInsetsMake(0, 10, 0, 10);
}

#pragma mark - notification

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemListChange:) name:kJKStatusItemListChangeNotification object:nil];
}

- (void)itemListChange:(NSNotification *)notify
{
    [self.itemCollectionView reloadData];
}

#pragma mark - tool

- (void)changeToNewView:(NSView *)view
{
    if (self.currentView.superview) {
        [self.currentView removeFromSuperview];
    }
    [self.containView addSubview:view];
    self.currentView = view;
    [self resizeWithViewSize:view.bounds.size];
}

- (void)resizeWithViewSize:(NSSize)viewSize
{
    if (self.MeunSizeChangeBlock) {
        self.MeunSizeChangeBlock(NSMakeSize(viewSize.width + 20, viewSize.height + 60));
    }
}

- (NSViewController *)getVCFromClassName:(NSString *)className sbName:(NSString *)sbName
{
    if (!sbName || sbName.length <= 0) {
        return nil;
    }
    
    if ([className isEqualToString:NSStringFromClass([JKWallPaperViewController class])]) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"WallPaper" bundle:nil];
        JKBaseViewController *vc = [sb instantiateInitialController];
        __weak typeof(self) weakSelf = self;
        vc.MeunSizeChangeBlock = ^(NSSize size) {
            [weakSelf resizeWithViewSize:size];
        };
        return vc;
    }
    
    NSStoryboard *sb = [NSStoryboard storyboardWithName:sbName bundle:nil];
    NSViewController *vc = [sb instantiateInitialController];
    return vc;
}


@end
