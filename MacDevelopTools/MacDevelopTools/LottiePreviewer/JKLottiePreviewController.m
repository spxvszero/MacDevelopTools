//
//  JKLottiePreviewController.m
//  MacDevelopTools
//
//  Created by jk on 2020/3/31.
//  Copyright © 2020 JK. All rights reserved.
//

#import "JKLottiePreviewController.h"
#import "JKLottieDragBoxView.h"
#import "LottieFilesURL.h"
#import <Lottie/Lottie.h>
#import <Quartz/Quartz.h>
#import "JKLottieMoreSettingViewController.h"

@interface JKLottiePreviewController ()
@property (weak) IBOutlet NSBox *controlPanel;
@property (weak) IBOutlet NSSlider *progressSlider;
@property (weak) IBOutlet NSButton *playBtn;


@property (weak) IBOutlet JKLottieDragBoxView *dragBoxView;
@property (weak) IBOutlet NSView *contentBackView;
@property (weak) IBOutlet LOTAnimationView *contentView;

@property (nonatomic, strong) NSWindowController *moreSettingController;

@end

@implementation JKLottiePreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    __weak typeof(self) weakSelf = self;
    self.dragBoxView.OpenJsonLottieObjectBlock = ^(id  _Nonnull jsonObj) {
        [weakSelf reloadViewWithJsonObj:jsonObj];
    };
    self.dragBoxView.MouseActionBlock = ^(BOOL isEnter) {
        weakSelf.controlPanel.hidden = !isEnter;
    };
    
    self.playBtn.image = [NSImage imageNamed:@"play"];
    
    self.progressSlider.minValue = 0;
    self.progressSlider.maxValue = 1;
    self.progressSlider.floatValue = self.contentView.animationProgress;
    self.contentView.LOTAnimationProgressBlock = ^(LOTAnimationView * _Nullable animView) {
        weakSelf.progressSlider.floatValue = animView.animationProgress;
    };
    
}

- (IBAction)sliderValueChange:(id)sender
{
    [self updateBtnWithCurrentState:false];
    [self.contentView setAnimationProgress:self.progressSlider.doubleValue];
}
- (IBAction)moreAction:(id)sender
{
    [self showMoreSettingController];
}

- (void)showMoreSettingController
{
    if (self.moreSettingController) {
        self.moreSettingController.window.orderedIndex = 1;
        [self.moreSettingController showWindow:self.moreSettingController.window];
        [self.moreSettingController.window orderFrontRegardless];
    }else{
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"LottiePreviewer" bundle:nil];
        NSWindowController *w = [sb instantiateControllerWithIdentifier:@"MoreSetting"];
        self.moreSettingController = w;
        w.window.title = @"More";
        [NSApplication.sharedApplication addWindowsItem:w.window title:@"More" filename:false];
        w.window.orderedIndex = 1;
        [w showWindow:w.window];
        [w.window orderFrontRegardless];
    }
    
    [(JKLottieMoreSettingViewController *)self.moreSettingController.contentViewController updateWithLOTAnimationView:self.contentView transBackView:self.contentBackView];
}

- (IBAction)playAction:(id)sender
{
    if (!self.contentView.sceneModel) {
        return;
    }
    
    if (self.contentView.isAnimationPlaying) {
        [self.contentView pause];
        [self updateBtnWithCurrentState:false];
    }else{
        [self contentPlayAnimation];
    }
    
//    NSColorPanel *p = [NSColorPanel sharedColorPanel];
//    p.hidesOnDeactivate = false;
//    [NSApp orderFrontColorPanel:nil];

}

- (void)updateBtnWithCurrentState:(BOOL)play
{
    if (play) {
        self.playBtn.state = NSControlStateValueOn;
        self.playBtn.image = [NSImage imageNamed:@"pause"];
    }else{
        self.playBtn.state = NSControlStateValueOff;
        self.playBtn.image = [NSImage imageNamed:@"play"];
    }
}

- (void)contentPlayAnimation
{
    __weak typeof(self) weakSelf = self;
    [self.contentView playWithCompletion:^(BOOL animationFinished) {
        if (animationFinished) {
            [weakSelf updateBtnWithCurrentState:false];
        }
    }];
    [self updateBtnWithCurrentState:true];
}

- (void)reloadViewWithJsonObj:(id)jsonObj
{
    if (!jsonObj) {
        return;
    }
    
    LOTComposition *laScene = [[LOTComposition alloc] initWithJSON:jsonObj withAssetBundle:[NSBundle mainBundle]];
    self.contentView.sceneModel = laScene;
    self.contentView.contentMode = LOTViewContentModeScaleAspectFit;
    [self contentPlayAnimation];
    
}

- (void)paste:(id)sender {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *classes = [[NSArray alloc] initWithObjects:[NSURL class], nil];
    
    if ([pasteboard canReadObjectForClasses:classes options:nil]) {
        NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:nil];
        
        if (copiedItems != nil) {
            NSURL *url = (NSURL *)[copiedItems firstObject];
            LottieFilesURL *lottieFile = [[LottieFilesURL alloc] initWithURL:url];
            
            if (lottieFile != nil) {
                [self.dragBoxView openAnimationURL:lottieFile.jsonURL];
            }
        }
    }
}

@end
