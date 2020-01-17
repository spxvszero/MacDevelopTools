//
//  JKResizeImageViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/20.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKResizeImageViewController.h"
#import "JKResizeImageExportViewController.h"
#import "JKRecodeImageExportViewController.h"

@interface JKResizeImageViewController ()


@property (nonatomic, strong) NSString *singlePath;
@property (nonatomic, strong) NSString *multiPath;
@property (weak) IBOutlet NSButton *chooseSingleBtn;
@property (weak) IBOutlet NSButton *chooseMultiBtn;
@property (weak) IBOutlet NSButton *recodeSingBtn;

@property (nonatomic, strong) NSOpenPanel *openPanel;


@property (nonatomic, strong) JKResizeImageExportViewController *exportVC;
@property (nonatomic, strong) JKRecodeImageExportViewController *recodeVC;

@property (nonatomic, assign) BOOL selectedSingleBtn;

@end

@implementation JKResizeImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusItemClose) name:kJKStatusItemPopOverCloseNotification object:nil];
}

- (void)statusItemClose
{
    [self.openPanel close];
}

- (void)startButtonAction:(NSViewController *)sender
{
    NSString *single = self.singlePath;
    NSString *multi = self.multiPath;
    
    if (!single && !multi) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"There is no file path";
        alert.informativeText = @"Try to choose image file path";
        [alert beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    
    if (single && single.length > 0) {
        self.exportVC.imageUrl = single;
        self.exportVC.single = YES;
        self.recodeVC.imageUrl = single;
    }
    
    if (multi && multi.length > 0) {
        self.exportVC.imageUrl = multi;
        self.exportVC.single = NO;
        self.recodeVC.imageUrl = multi;
    }
    
    [self presentViewControllerAsSheet:sender];
}


- (IBAction)choosePathAction:(NSButton *)sender
{
    if (self.openPanel.visible) {
        return;
    }
    
    NSViewController *aimVC = nil;
    if (sender == self.chooseSingleBtn) {
        self.openPanel.canChooseFiles = YES;
        self.openPanel.canChooseDirectories = NO;
        self.selectedSingleBtn = YES;
        aimVC = self.exportVC;
    }
    if (sender == self.chooseMultiBtn) {
        self.openPanel.canChooseFiles = NO;
        self.openPanel.canChooseDirectories = YES;
        self.selectedSingleBtn = NO;
        aimVC = self.exportVC;
    }
    if (sender == self.recodeSingBtn) {
        self.openPanel.canChooseFiles = YES;
        self.openPanel.canChooseDirectories = NO;
        self.selectedSingleBtn = YES;
        aimVC = self.recodeVC;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            if (weakSelf.selectedSingleBtn) {
                weakSelf.singlePath = weakSelf.openPanel.URL.relativePath;
                weakSelf.multiPath = nil;
            }else{
                weakSelf.multiPath = weakSelf.openPanel.URL.relativePath;
                weakSelf.singlePath = nil;
            }
            
            [weakSelf startButtonAction:aimVC];
        }
    }];
}

- (NSOpenPanel *)openPanel
{
    if (!_openPanel) {
        _openPanel = [NSOpenPanel openPanel];
        _openPanel.showsHiddenFiles = YES;
        _openPanel.canCreateDirectories = YES;
        _openPanel.showsResizeIndicator = YES;
    }
    return _openPanel;
}


- (JKResizeImageExportViewController *)exportVC
{
    if (!_exportVC) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"ResizeImage" bundle:nil];
        _exportVC = [sb instantiateControllerWithIdentifier:@"JKResizeImageExportViewController"];
    }
    return _exportVC;
}

- (JKRecodeImageExportViewController *)recodeVC
{
    if (!_recodeVC) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"ResizeImage" bundle:nil];
        _recodeVC = [sb instantiateControllerWithIdentifier:@"JKRecodeImageExportViewController"];
    }
    return _recodeVC;
}

@end
