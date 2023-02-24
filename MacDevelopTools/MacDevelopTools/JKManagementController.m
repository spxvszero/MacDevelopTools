//
//  JKManagementController.m
//  MacDevelopTools
//
//  Created by jk on 2020/3/23.
//  Copyright © 2020 JK. All rights reserved.
//

#import "JKManagementController.h"
#import "JKManageListItemsViewController.h"
#import "JKAboutViewController.h"

@interface JKManagementController ()

@property (weak) IBOutlet NSSegmentedControl *segmentControl;
@property (weak) IBOutlet NSView *containView;

@property (nonatomic, weak) NSView *curView;
@property (nonatomic, strong) JKManageListItemsViewController *itemsViewController;
@property (nonatomic, strong) JKAboutViewController *aboutViewController;

@end

@implementation JKManagementController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.segmentControl.selectedSegment = 0;
    self.segmentControl.target = self;
    self.segmentControl.action = @selector(segmentControlAction:);
    
    
    [self segmentControlAction:self.segmentControl];
}

- (void)segmentControlAction:(NSSegmentedControl *)segment
{
    NSLog(@"segment click %ld",(long)segment.selectedSegment);
    [self.curView removeFromSuperview];
    NSViewController *vc = nil;
    if (segment.selectedSegment == 0) {
        vc = self.itemsViewController;
    }
    if (segment.selectedSegment == 1) {
        //show about
        vc = self.aboutViewController;
    }
    [self.containView addSubview:vc.view];
    self.curView = vc.view;
    [self compactPerferSize:vc.view.bounds.size];
//    [self reoriginCenter:vc.view inContainView:self.containView];
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    [self reoriginCenter:self.curView inContainView:self.containView];
}

- (void)reoriginCenter:(NSView *)view inContainView:(NSView *)containView
{
    CGFloat originX = MAX((containView.bounds.size.width - view.bounds.size.width) * 0.5, 0);
    CGFloat originY = MAX((containView.bounds.size.height - view.bounds.size.height) * 0.5, 0);
    view.frame = NSMakeRect(originX, originY, view.bounds.size.width, view.bounds.size.height);
}

- (void)compactPerferSize:(CGSize)viewSize
{
    CGFloat minWidth = MAX(CGRectGetWidth(self.segmentControl.frame), viewSize.width) + 40;
    CGFloat minHeight = CGRectGetHeight(self.segmentControl.frame) + 20 + 20 + 15 + viewSize.height;
    
    self.preferredContentSize = NSMakeSize(minWidth, minHeight);
//    __weak typeof(self) weakSelf = self;
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
//        [weakSelf.view.animator setPreparedContentRect:NSMakeRect(0, 0,minWidth, minHeight)];
//    } completionHandler:^{
//
//    }];
}

- (JKAboutViewController *)aboutViewController
{
    if (!_aboutViewController) {
        _aboutViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"JKAboutViewController"];
    }
    return _aboutViewController;
}

- (JKManageListItemsViewController *)itemsViewController
{
    if (!_itemsViewController) {
        _itemsViewController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"JKManageListItemsViewController"];
    }
    return _itemsViewController;
}

@end
