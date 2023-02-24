//
//  JKSVGAPreviewController.m
//  MacDevelopTools
//
//  Created by jk on 2022/2/22.
//  Copyright © 2022 JK. All rights reserved.
//

#import "JKSVGAPreviewController.h"
#import "JKSVGADragBoxView.h"
#import "SVGAImageView.h"
#import "SVGAParser.h"
#import "SVGAVideoEntity.h"

@interface JKSVGAPreviewController ()<SVGAPlayerDelegate>

@property (weak) IBOutlet NSBox *controlPanel;
@property (weak) IBOutlet NSSlider *progressSlider;
@property (weak) IBOutlet NSButton *playBtn;


@property (weak) IBOutlet JKSVGADragBoxView *dragBoxView;
@property (weak) IBOutlet NSView *contentBackView;
@property (weak) IBOutlet SVGAImageView *contentView;

@property(nonatomic, strong) SVGAParser *parser;

@end

@implementation JKSVGAPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.progressSlider.minValue = 0;
    self.progressSlider.maxValue = 1;
    self.progressSlider.floatValue = 0;
    __weak typeof(self) weakSelf = self;
    self.contentView.alphaValue = 1;
    self.contentView.delegate = self;
    self.contentView.contentMode = SVGAContentModeScaleAspectFit;
    self.dragBoxView.OpenSVGAObjectBlock = ^(NSString * _Nonnull svgaPath) {
        [weakSelf reloadSVGAWithFilePath:svgaPath];
    };
    self.dragBoxView.MouseActionBlock = ^(BOOL isEnter) {
        weakSelf.controlPanel.hidden = !isEnter;
    };
}

- (void)reloadSVGAWithFilePath:(NSString *)svgaPath
{
    __weak typeof(self) weakSelf = self;
    [self.parser parseWithURL:[NSURL fileURLWithPath:svgaPath] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
        if (videoItem) {
            weakSelf.contentView.videoItem = videoItem;
            weakSelf.contentView.loops = 1;
            weakSelf.contentView.clearsAfterStop = false;
            [weakSelf.contentView startAnimation];
            [weakSelf updateBtnWithCurrentState:true];
        }else{
            NSLog(@"SVGA load videoItem failed");
        }
    } failureBlock:^(NSError * _Nullable error) {
        NSLog(@"SVGA load failed : %@",error);
    }];
}
- (IBAction)slideProgressChangeValue:(id)sender {
    [self.contentView stepToPercentage:self.progressSlider.doubleValue andPlay:false];
    [self updateBtnWithCurrentState:false];
}

- (IBAction)playAction:(id)sender {
    if (self.contentView.isOnAnimation) {
        [self.contentView stepToPercentage:self.progressSlider.doubleValue andPlay:false];
        [self updateBtnWithCurrentState:false];
    }else{
        CGFloat progress = self.progressSlider.doubleValue;
        if (progress >= 1) {
            progress = 0;
        }
        [self.contentView stepToPercentage:progress andPlay:true];
        [self updateBtnWithCurrentState:true];
    }
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

- (SVGAParser *)parser {
    if (_parser == nil) {
        _parser = [[SVGAParser alloc]init];
    }
    return _parser;
}

#pragma mark - SVGA Delegate

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    [self updateBtnWithCurrentState:false];
    [self.contentView resetLoopCount];
}

- (void)svgaPlayer:(SVGAPlayer *)player didAnimatedToPercentage:(CGFloat)percentage
{
    self.progressSlider.doubleValue = percentage;
}

@end
