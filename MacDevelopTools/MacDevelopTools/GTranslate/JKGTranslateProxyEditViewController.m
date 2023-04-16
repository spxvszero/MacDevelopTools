//
//  JKGTranslateProxyEditViewController.m
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/4/15.
//  Copyright © 2023 JK. All rights reserved.
//

#import "JKGTranslateProxyEditViewController.h"

@interface JKGTranslateProxyEditViewController ()
@property (weak) IBOutlet NSPopUpButton *proxyTypeBtn;
@property (weak) IBOutlet NSTextField *proxyTxtField;
@property (weak) IBOutlet NSTextField *proxyUsername;
@property (weak) IBOutlet NSTextField *proxyPassword;

@end

@implementation JKGTranslateProxyEditViewController

- (void)statusItemClose
{
    if (self.presentingViewController) {
        [self dismissViewController:self];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.proxyTxtField.placeholderString = @"host:port";
    self.proxyUsername.placeholderString = @"username";
    self.proxyPassword.placeholderString = @"password";
    [self.proxyTypeBtn removeAllItems];
    NSMutableArray *itemTitlesArr = [NSMutableArray array];
    for (int i = JKProxyTypeMin; i < JKProxyTypeMax; i++) {
        NSString *name = [JKProxy displayNameWithProxyType:i];
        if (name != nil) {
            [itemTitlesArr addObject:name];
        }
    }
    [self.proxyTypeBtn addItemsWithTitles:itemTitlesArr];
    
    [self updateData];
}


- (IBAction)finishBtnAction:(id)sender {
    
    JKProxyModel *nModel = [[JKProxyModel alloc] init];
    nModel.proxyType = self.proxyTypeBtn.indexOfSelectedItem;
    nModel.host = self.proxyTxtField.stringValue;
    nModel.username = self.proxyUsername.stringValue;
    nModel.password = self.proxyPassword.stringValue;
    
    if (self.FinishEditActionBlock) {
        self.FinishEditActionBlock(true, nModel);
    }
    if (self.presentingViewController) {
        [self dismissViewController:self];
    }
}
- (IBAction)cancelBtnAction:(id)sender {
    if (self.FinishEditActionBlock) {
        self.FinishEditActionBlock(false, nil);
    }
    if (self.presentingViewController) {
        [self dismissViewController:self];
    }
}

- (void)updateData
{
    if (self.currentProxy) {
        [self.proxyTypeBtn selectItemAtIndex:self.currentProxy.proxyType];
        self.proxyTxtField.stringValue = self.currentProxy.host?:@"";
        self.proxyUsername.stringValue = self.currentProxy.username?:@"";
        self.proxyPassword.stringValue = self.currentProxy.password?:@"";
    }
}

- (void)setCurrentProxy:(JKProxyModel *)currentProxy
{
    _currentProxy = currentProxy;
    if (self.proxyTxtField) {
        [self updateData];
    }
}

@end
