//
//  JKResizeImageViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/20.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKResizeImageViewController.h"
#import "JKResizeImageExportViewController.h"

@interface JKResizeImageViewController ()

@property (weak) IBOutlet NSButton *startButton;

@property (weak) IBOutlet NSImageView *imageView;

@property (nonatomic, strong) JKResizeImageExportViewController *exportVC;

@end

@implementation JKResizeImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.imageView.editable = YES;
}

- (IBAction)startButtonAction:(NSButton *)sender
{
    if (!self.imageView.image) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"There is no image";
        alert.informativeText = @"Try to Drag an image into box";
        [alert beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    
    self.exportVC.image = self.imageView.image;
    [self presentViewControllerAsSheet:self.exportVC];
}



- (JKResizeImageExportViewController *)exportVC
{
    if (!_exportVC) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"ResizeImage" bundle:nil];
        _exportVC = [sb instantiateControllerWithIdentifier:@"JKResizeImageExportViewController"];
    }
    return _exportVC;
}

@end
