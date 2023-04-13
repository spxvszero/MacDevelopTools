//
//  JKWallPaperImagePanelController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/14.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKWallPaperImagePanelController.h"

#define Slider_Tag_Basic 111

@interface JKWallPaperImagePanelController ()

@property (weak) IBOutlet NSButton *scaleToFillBtn;
@property (weak) IBOutlet NSButton *aspectToFitBtn;
@property (weak) IBOutlet NSButton *aspectToFillBtn;
@property (weak) IBOutlet NSButton *customBtn;


@property (weak) IBOutlet NSBox *customBox;
@property (weak) IBOutlet NSSlider *xpos;
@property (weak) IBOutlet NSSlider *ypos;
@property (weak) IBOutlet NSSlider *wpos;
@property (weak) IBOutlet NSSlider *hpos;
@property (weak) IBOutlet NSSlider *scalepos;


@property (weak) IBOutlet NSButton *resetBtn;

@property (nonatomic, assign) CGRect listenRect;

@end

@implementation JKWallPaperImagePanelController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.scaleToFillBtn.tag = JKWallImageScalingScaleToFill;
    self.aspectToFitBtn.tag = JKWallImageScalingAspectToFit;
    self.aspectToFillBtn.tag = JKWallImageScalingAspectToFill;
    self.customBtn.tag = JKWallImageScalingCustom;
    
    self.xpos.tag = Slider_Tag_Basic + JKWallPaperImagePanelSliderTypeX;
    self.ypos.tag = Slider_Tag_Basic + JKWallPaperImagePanelSliderTypeY;
    self.wpos.tag = Slider_Tag_Basic + JKWallPaperImagePanelSliderTypeW;
    self.hpos.tag = Slider_Tag_Basic + JKWallPaperImagePanelSliderTypeH;
    self.scalepos.tag = Slider_Tag_Basic + JKWallPaperImagePanelSliderTypeScale;
    
    [self resetPanel];
    
}
- (IBAction)buttonSelectAction:(NSButton *)sender
{
    if (self.ImageScaleButtonSelectBlock) {
        self.ImageScaleButtonSelectBlock(sender.tag);
    }
    
    self.currentScaling = (JKWallImageScaling)sender.tag;
}
- (IBAction)sliderAction:(NSSlider *)sender {
    if (self.CustomSliderValueChangedBlock) {
        JKWallPaperImagePanelSliderType type = sender.tag - Slider_Tag_Basic;
        if (type == JKWallPaperImagePanelSliderTypeScale) {
            //0.1 to 8
            CGFloat value = (sender.floatValue / (sender.maxValue - sender.minValue)) * 7.9 + 0.1;
            self.CustomSliderValueChangedBlock(type, value, nil);
        }else{
             CGFloat value = sender.floatValue / (sender.maxValue - sender.minValue);
            self.CustomSliderValueChangedBlock(type, value, &_listenRect);
            self.xpos.floatValue =_listenRect.origin.x * (sender.maxValue - sender.minValue);
            self.ypos.floatValue = _listenRect.origin.y * (sender.maxValue - sender.minValue);
            self.wpos.floatValue = _listenRect.size.width * (sender.maxValue - sender.minValue);
            self.hpos.floatValue = _listenRect.size.height * (sender.maxValue - sender.minValue);
        }
    }
}

- (IBAction)resetBtnAction:(id)sender {
    [self resetPanel];
    if (self.ResetActionBlock) {
        self.ResetActionBlock();
    }
}

- (void)resetPanel
{
    self.xpos.floatValue = self.ypos.minValue;
    self.ypos.floatValue = self.ypos.minValue;
    self.wpos.floatValue = self.wpos.maxValue;
    self.hpos.floatValue = self.hpos.maxValue;
    self.scalepos.floatValue = (0.9 / 7.9) * (self.scalepos.maxValue - self.scalepos.minValue);
}

- (void)setCurrentScaling:(JKWallImageScaling)currentScaling
{
    _currentScaling = currentScaling;
    
    NSButton *btn = [self.view viewWithTag:currentScaling];
    btn.state = NSControlStateValueOn;
    
    if (currentScaling == JKWallImageScalingCustom) {
        self.scalepos.enabled = true;
    }else{
        self.scalepos.enabled = false;
    }
}

@end
