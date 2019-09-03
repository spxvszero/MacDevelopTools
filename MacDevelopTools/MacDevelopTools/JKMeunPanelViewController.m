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

#define kCollectionItemIdentify @"normal"

@interface JKMeunPanelViewController ()<NSCollectionViewDataSource,NSCollectionViewDelegate,NSCollectionViewDelegateFlowLayout>

@property (weak) IBOutlet NSCollectionView *itemCollectionView;
@property (weak) IBOutlet NSView *containView;

@property (nonatomic, strong) NSMutableArray *viewControllerArr;
@property (nonatomic, strong) NSMutableArray *toolTipArr;
@property (nonatomic, strong) NSMutableArray *imageNamesArr;
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
    self.viewControllerDic = [NSMutableDictionary dictionary];
    
    [self initailizeViewControllers];
    
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
    if (indexPath.item < self.toolTipArr.count) {
        item.toolTips = [self.toolTipArr objectAtIndex:indexPath.item];
    }else{
        item.toolTips = @"No Description";
    }
    
    if (indexPath.item < self.toolTipArr.count) {
        item.imgName = [self.imageNamesArr objectAtIndex:indexPath.item];
    }else{
        item.imgName = @"bug";
    }
    
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

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NSMakeSize(30, 30);
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
        self.MeunSizeChangeBlock(NSMakeSize(viewSize.width + 20, viewSize.height + 50));
    }
}

- (NSViewController *)getVCFromClass:(Class)class
{
    NSString *sbName = [self.vcNameToSbDic objectForKey:NSStringFromClass(class)];
    
    if (!sbName || sbName.length <= 0) {
        return nil;
    }
    
    if ([NSStringFromClass(class) isEqualToString:NSStringFromClass([JKWallPaperViewController class])]) {
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

- (void)addViewControllerWithClass:(Class)className toolTip:(NSString *)toolTip storyBoardName:(NSString *)sbName
{
    [self.viewControllerArr addObject:className];
    [self.imageNamesArr addObject:@"bug"];
    [self.toolTipArr addObject:toolTip];
    [self.vcNameToSbDic setObject:sbName forKey:NSStringFromClass(className)];
}

- (void)addViewControllerWithClass:(Class)className toolTip:(NSString *)toolTip storyBoardName:(NSString *)sbName img:(NSString *)imgName
{
    [self.viewControllerArr addObject:className];
    [self.imageNamesArr addObject:imgName];
    [self.toolTipArr addObject:toolTip];
    [self.vcNameToSbDic setObject:sbName forKey:NSStringFromClass(className)];
}

- (void)initailizeViewControllers
{
    [self addViewControllerWithClass:[PushViewController class] toolTip:@"Apple Push" storyBoardName:@"SmartPush" img:@"applepush"];
    
    [self addViewControllerWithClass:[JKWallPaperViewController class] toolTip:@"Wallpaper" storyBoardName:@"WallPaper" img:@"wallpaper"];
    
    [self addViewControllerWithClass:[JKEncodingViewController class] toolTip:@"Encode" storyBoardName:@"Encoding" img:@"encode"];
    
    [self addViewControllerWithClass:[JKJSONModelViewController class] toolTip:@"Json To Model" storyBoardName:@"JSONModel" img:@"jsonmodel"];
    
    [self addViewControllerWithClass:[JKResizeImageViewController class] toolTip:@"Resize Image" storyBoardName:@"ResizeImage" img:@"imgresize"];
    
    [self addViewControllerWithClass:[JKMoveFileViewController class] toolTip:@"Move File" storyBoardName:@"MoveFile" img:@"movefile"];
    
    [self addViewControllerWithClass:[JKStatusIconManagerViewController class] toolTip:@"Status Icon Manager" storyBoardName:@"StatusIcon"];
    
    [self addViewControllerWithClass:[JKImageInfoViewController class] toolTip:@"Image Info" storyBoardName:@"ImageInfo"];
    
    [self addViewControllerWithClass:[JKAutoPackViewController class] toolTip:@"Auto Pack" storyBoardName:@"AutoPack"];
    
    [self addViewControllerWithClass:[JKQRCodeViewController class] toolTip:@"QRCode" storyBoardName:@"QRCode" img:@"qrcode"];
    
    [self addViewControllerWithClass:[JKJSONFormatViewController class] toolTip:@"JSON Format" storyBoardName:@"JSONFormat"];
    
    [self addViewControllerWithClass:[JKShellManagerViewController class] toolTip:@"Shell Manager" storyBoardName:@"ShellManager"];
    
    [self addViewControllerWithClass:[JKClockViewController class] toolTip:@"Clock" storyBoardName:@"Clock" img:@"clock"];

}

#pragma mark - getter

- (NSMutableArray *)viewControllerArr
{
     if (!_viewControllerArr) {
         _viewControllerArr = [NSMutableArray array];
    }
    return _viewControllerArr;
}
- (NSMutableArray *)toolTipArr
{
    if (!_toolTipArr) {
        _toolTipArr = [NSMutableArray array];
    }
    return _toolTipArr;
}

- (NSMutableArray *)imageNamesArr
{
    if (!_imageNamesArr) {
        _imageNamesArr = [NSMutableArray array];
    }
    return _imageNamesArr;
}

- (NSMutableDictionary *)vcNameToSbDic
{
    if (!_vcNameToSbDic) {
        _vcNameToSbDic = [NSMutableDictionary dictionary];
    }
    return _vcNameToSbDic;
}

@end
