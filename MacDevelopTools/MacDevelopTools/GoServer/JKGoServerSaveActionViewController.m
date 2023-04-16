//
//  JKGoServerSaveActionViewController.m
//  MacDevelopTools
//
//  Created by jk on 2022/6/9.
//  Copyright © 2022 JK. All rights reserved.
//

#import "JKGoServerSaveActionViewController.h"
#import "JKGoControlRequestParamsMaker.h"

@interface JKGoServerSaveActionViewController ()
@property (weak) IBOutlet NSTextField *nameTxtField;
@property (weak) IBOutlet NSTextField *contentLabel;
@property (weak) IBOutlet NSTextField *actionLabel;
@property (weak) IBOutlet NSTextField *optionStatusLabel;

@end

@implementation JKGoServerSaveActionViewController

- (void)statusItemClose
{
    if (self.presentingViewController) {
        [self dismissViewController:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self updateEditModel];
}

- (void)setEditModel:(JKGoServerActionModel *)editModel
{
    _editModel = editModel;
    [self updateEditModel];
}

- (void)updateEditModel
{
    self.nameTxtField.stringValue = self.editModel.nickName?:@"";
    self.actionLabel.stringValue = [NSString stringWithFormat:@"%@-%@",
                                    [JKGoControlRequestParamsMaker describeNameForActionCategory:self.editModel.actionPath],
                                    [JKGoControlRequestParamsMaker describeNameForActionType:self.editModel.action + ActionTypeMin]];
    self.contentLabel.stringValue = self.editModel.content?:@"";
    
    if (self.editModel.isQuickCMD) {
        self.optionStatusLabel.stringValue = @"√";
    }else{
        self.optionStatusLabel.stringValue = @"X";
    }
}

- (IBAction)finishAction:(id)sender {
    NSString *name = [self.nameTxtField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (name && name.length > 0) {
        self.editModel.nickName = name;
    }else{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"名称不能为空"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    if (self.SaveActionBlock) {
        self.SaveActionBlock(self, true);
    }
    if (self.presentingViewController) {
        [self dismissViewController:self];
    }
}
- (IBAction)cancelAction:(id)sender {
    if (self.SaveActionBlock) {
        self.SaveActionBlock(self, false);
    }
    if (self.presentingViewController) {
        [self dismissViewController:self];
    }
}

@end
