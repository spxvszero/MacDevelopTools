//
//  JKWallPaperVideoPanelController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/28.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKWallPaperVideoPanelController.h"

#define kJKVideoAspectTag 123
@interface JKWallPaperVideoPanelController ()

@property (weak) IBOutlet NSButton *resizeAspectButton;
@property (weak) IBOutlet NSButton *resizeAspectFillButton;
@property (weak) IBOutlet NSButton *resizeButton;
@property (weak) IBOutlet NSButton *voiceEnableButton;
@property (weak) IBOutlet NSSlider *voiceVolumnSlider;

@end

@implementation JKWallPaperVideoPanelController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.resizeAspectButton.tag = kJKVideoAspectTag;
    self.resizeAspectFillButton.tag = kJKVideoAspectTag + 1;
    self.resizeButton.tag = kJKVideoAspectTag + 2;
    
    self.voiceVolumnSlider.minValue = 0.0;
    self.voiceVolumnSlider.maxValue = 1.0;
    
}



- (IBAction)aspectSelectAction:(NSButton *)sender
{
    if (self.VideoAspectSelectBlock) {
        self.VideoAspectSelectBlock(sender.tag - kJKVideoAspectTag);
    }
    sender.state = NSControlStateValueOn;
}

- (IBAction)voiceEnableAction:(NSButton *)sender
{
    if (self.VideoVoiceEnableBlock) {
        BOOL res = NO;
        switch (sender.state) {
            case NSControlStateValueOn:
                res = YES;
                break;
            case NSControlStateValueOff:
                res = NO;
                break;
                
            default:
                break;
        }
        self.VideoVoiceEnableBlock(res);
    }
    
}

- (IBAction)voiceSliderValueChanged:(NSSlider *)sender
{
    if (self.VideoVoiceValueChangeBlock) {
        self.VideoVoiceValueChangeBlock(sender.doubleValue);
    }
}


- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    NSButton *btn = [self.view viewWithTag:selectedIndex + kJKVideoAspectTag];
    if (btn && [btn isKindOfClass:[NSButton class]]) {
        btn.state = NSControlStateValueOn;
    }
}

- (void)setVoiceEnable:(BOOL)voiceEnable
{
    _voiceEnable = voiceEnable;
    if (voiceEnable) {
        self.voiceEnableButton.state = NSControlStateValueOn;
    }else{
        self.voiceEnableButton.state = NSControlStateValueOff;
    }
}

- (void)setVoiceValue:(CGFloat)voiceValue
{
    _voiceValue = voiceValue;
    
    self.voiceVolumnSlider.doubleValue = voiceValue;
}

@end
