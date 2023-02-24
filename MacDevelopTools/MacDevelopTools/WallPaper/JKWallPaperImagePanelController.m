//
//  JKWallPaperImagePanelController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/14.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKWallPaperImagePanelController.h"

@interface JKWallPaperImagePanelController ()

@property (weak) IBOutlet NSButton *noneButton;
@property (weak) IBOutlet NSButton *centerTopButton;
@property (weak) IBOutlet NSButton *sizeToFillButton;
@property (weak) IBOutlet NSButton *sizeToFitButton;

@end

@implementation JKWallPaperImagePanelController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.noneButton.tag = NSImageScaleNone;
    self.centerTopButton.tag = NSImageScaleProportionallyDown;
    self.sizeToFillButton.tag = NSImageScaleAxesIndependently;
    self.sizeToFitButton.tag = NSImageScaleProportionallyUpOrDown;
    
    
}
- (IBAction)buttonSelectAction:(NSButton *)sender
{
    if (self.ImageScaleButtonSelectBlock) {
        self.ImageScaleButtonSelectBlock(sender.tag);
    }
}

- (void)setCurrentScaling:(NSImageScaling)currentScaling
{
    _currentScaling = currentScaling;
    
    NSButton *btn = [self.view viewWithTag:currentScaling];
    btn.state = NSControlStateValueOn;
}

@end
