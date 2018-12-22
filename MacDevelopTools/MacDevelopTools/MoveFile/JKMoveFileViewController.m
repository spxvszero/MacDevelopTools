//
//  JKMoveFileViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/21.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKMoveFileViewController.h"

@interface JKMoveFileViewController ()

@property (weak) IBOutlet NSTextField *sourceTxtField;
@property (weak) IBOutlet NSTextField *outPutTxtField;
@property (weak) IBOutlet NSTextField *fileExtensionTxtField;


@property (nonatomic, strong) NSOpenPanel *openPanel;


@end

@implementation JKMoveFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (IBAction)buttonAction:(id)sender
{
    NSString *shellPath = [[NSBundle mainBundle] pathForResource:@"packupResource" ofType:@"sh"];
    if (!shellPath || shellPath.length <= 0) {
        [self showAlertWithTitle:@"Shell file not found"];
        return;
    }
    NSString *sourcePath = self.sourceTxtField.stringValue;
    
    if (!sourcePath || sourcePath.length <= 0) {
        [self showAlertWithTitle:@"Source Path not found"];
        return;
    }
    
    if ([sourcePath containsString:@" "]) {
        [self showAlertWithTitle:@"Source Path should not has blank character"];
        return;
    }
    
    NSString *destinatePath = self.outPutTxtField.stringValue;
    
    if (!destinatePath || destinatePath.length <= 0) {
        [self showAlertWithTitle:@"Output Path not found"];
        return;
    }
    
    if ([destinatePath containsString:@" "]) {
        [self showAlertWithTitle:@"Output Path should not has blank character"];
        return;
    }
    
    NSString *fileExtension = self.fileExtensionTxtField.stringValue;
    
    NSString *cmd = [NSString stringWithFormat:@"yes | sh %@ -r %@ -o %@",shellPath,sourcePath,destinatePath];
    if (!fileExtension || fileExtension.length <= 0) {
    }else{
        NSArray *fileExtensionArr = [fileExtension componentsSeparatedByString:@","];
        if (fileExtensionArr && fileExtensionArr.count > 0) {
            cmd = [NSString stringWithFormat:@"yes | sh %@ -r %@ -o %@ -a %@",shellPath,sourcePath,destinatePath,fileExtension];
        }
    }
    
    system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (IBAction)chooseSourceAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self.openPanel beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            weakSelf.sourceTxtField.stringValue = weakSelf.openPanel.URL.relativePath;
        }
    }];
}

- (IBAction)chooseDestinate:(id)sender
{
    
    __weak typeof(self) weakSelf = self;
    [self.openPanel beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            weakSelf.outPutTxtField.stringValue = weakSelf.openPanel.URL.relativePath;
        }
    }];
    
}


- (void)showAlertWithTitle:(NSString *)title
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = title;
    [alert beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse returnCode) {
        
    }];
}




- (NSOpenPanel *)openPanel
{
    if (!_openPanel) {
        _openPanel = [NSOpenPanel openPanel];
        _openPanel.canChooseFiles = NO;
        _openPanel.canChooseDirectories = YES;
        _openPanel.showsHiddenFiles = YES;
        _openPanel.canCreateDirectories = YES;
        _openPanel.showsResizeIndicator = YES;
    }
    return _openPanel;
}

@end
