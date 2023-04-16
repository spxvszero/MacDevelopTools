//
//  JKGoServerEditViewController.m
//  MacDevelopTools
//
//  Created by jk on 2022/5/25.
//  Copyright © 2022 JK. All rights reserved.
//

#import "JKGoServerEditViewController.h"

@interface JKGoServerEditViewController ()
@property (weak) IBOutlet NSTextField *hostTxtField;
@property (weak) IBOutlet NSTextField *secretTxtField;
@property (weak) IBOutlet NSTextField *ivTxtField;


@property (weak) IBOutlet NSTextField *nickTxtField;
@property (weak) IBOutlet NSTextField *locationTxtField;

@end

@implementation JKGoServerEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self updateModel];
}

- (void)statusItemClose
{
    if (self.presentingViewController) {
        [self dismissViewController:self];
    }
}

- (IBAction)okBtnAction:(id)sender {
    JKGoServerDataModel *resModel = nil;
    if (self.serverModel) {
        resModel = self.serverModel;
    }else{
        resModel = [[JKGoServerDataModel alloc] init];
        resModel.req = [[JKGoControlBaseRequest alloc] init];
    }
    resModel.host = self.hostTxtField.stringValue;
    resModel.secret = self.secretTxtField.stringValue;
    resModel.iv = self.ivTxtField.stringValue;
    
    resModel.nick = self.nickTxtField.stringValue;
    resModel.location = self.locationTxtField.stringValue;
    
    if (self.FinishUpdatedWithResultBlock) {
        self.FinishUpdatedWithResultBlock(resModel,true);
    }
    if (self.presentingViewController) {
        [self dismissViewController:self];
    }
}
- (IBAction)cancelBtnAction:(id)sender {
    if (self.FinishUpdatedWithResultBlock) {
        self.FinishUpdatedWithResultBlock(nil,false);
    }
    if (self.presentingViewController) {
        [self dismissViewController:self];
    }
}

- (void)clearData
{
    self.serverModel = nil;
    self.hostTxtField.stringValue = @"";
    self.secretTxtField.stringValue = @"";
    self.ivTxtField.stringValue = @"";
    
    self.nickTxtField.stringValue = @"";
    self.locationTxtField.stringValue = @"";
}

- (void)setServerModel:(JKGoServerDataModel *)serverModel
{
    _serverModel = serverModel;
    if (_hostTxtField) {
        [self updateModel];
    }
}

- (void)updateModel {
    self.hostTxtField.stringValue = self.serverModel.host?:@"";
    self.secretTxtField.stringValue = self.serverModel.secret?:@"";
    self.ivTxtField.stringValue = self.serverModel.iv?:@"";
    
    self.nickTxtField.stringValue = self.serverModel.nick?:@"";
    self.locationTxtField.stringValue = self.serverModel.location?:@"";
}

@end
