//
//  JKLive2dViewController.m
//  MacDevelopTools
//
//  Created by jk on 2020/6/3.
//  Copyright © 2020 JK. All rights reserved.
//

#import "JKLive2dViewController.h"
#import "AppDelegate.h"
#import "JKLive2dHelper.h"
#import "NSPanel+JK.h"

@interface JKLive2dViewController ()
@property (weak) IBOutlet NSButton *runBtn;

@property (nonatomic, strong) NSOpenPanel *openPanel;
@property (weak) IBOutlet NSTextField *pathLabel;

@end

@implementation JKLive2dViewController


- (void)statusItemClose
{
    [self.openPanel cancel:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

}



- (IBAction)runAction:(id)sender
{
    if ([JKLive2dHelper isRunning]) {
        self.runBtn.title = @"Run";
        [JKLive2dHelper stop];
    }else{
        AppDelegate *appD = [[NSApplication sharedApplication] delegate];
        [appD closePopOver];
        self.runBtn.title = @"Stop";
        dispatch_async(dispatch_get_main_queue(), ^{
            [JKLive2dHelper start];
        });
    }
}

- (void)mouseMoved:(NSEvent *)event
{
    [super mouseMoved:event];
    NSLog(@"mouseMove %@",event);
}

- (IBAction)centerAction:(id)sender
{
    [JKLive2dHelper centerWindow];
}

- (IBAction)resizeAction:(id)sender
{
    [JKLive2dHelper resizeWindowWithWidth:400 height:800];
}
- (IBAction)nextSceneAction:(id)sender
{
    if ([JKLive2dHelper isRunning]) {
        [JKLive2dHelper nextScene];
    }else{
         NSLog(@"Live2d not running");
    }
}


- (IBAction)resourceDirSelectAction:(id)sender
{
    
    if (self.openPanel.visible) {
        return;
    }
    
    self.openPanel.canChooseFiles = NO;
    self.openPanel.canChooseDirectories = YES;
    
    __weak typeof(self) weakSelf = self;
    [self.openPanel jk_beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            weakSelf.pathLabel.stringValue = weakSelf.openPanel.URL.relativePath;
            [JKLive2dHelper setResoucePath:weakSelf.openPanel.URL.relativePath];
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



@end
