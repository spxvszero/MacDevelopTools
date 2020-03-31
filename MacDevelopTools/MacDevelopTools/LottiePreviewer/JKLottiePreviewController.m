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

@interface JKLottiePreviewController ()
@property (weak) IBOutlet NSBox *controlPanel;
@property (weak) IBOutlet NSSlider *progressSlider;
@property (weak) IBOutlet NSButton *playBtn;


@property (weak) IBOutlet JKLottieDragBoxView *dragBoxView;
@property (weak) IBOutlet LOTAnimationView *contentView;

@end

@implementation JKLottiePreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
//    self.progressSlider.floatValue = self.contentView.animationProgress;
//
//    [self.contentView addObserver:self forKeyPath:@"animationProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionInitial context:nil];

    __weak typeof(self) weakSelf = self;
    self.dragBoxView.OpenJsonLottieObjectBlock = ^(id  _Nonnull jsonObj) {
        [weakSelf reloadViewWithJsonObj:jsonObj];
    };
    self.dragBoxView.MouseActionBlock = ^(BOOL isEnter) {
        weakSelf.controlPanel.hidden = !isEnter;
    };
    
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"observer -- %@ -- %@",keyPath,change);
}

- (IBAction)playAction:(id)sender
{
    [self.contentView play];
    NSLog(@"progress -- %@",[self.contentView valueForKey:@"animationProgress"]);
    
//    NSColorPanel *p = [NSColorPanel sharedColorPanel];
//    p.hidesOnDeactivate = false;
//    [NSApp orderFrontColorPanel:nil];

}

- (void)reloadViewWithJsonObj:(id)jsonObj
{
    if (!jsonObj) {
        return;
    }
    
    LOTComposition *laScene = [[LOTComposition alloc] initWithJSON:jsonObj withAssetBundle:[NSBundle mainBundle]];
    self.contentView.sceneModel = laScene;
    self.contentView.contentMode = LOTViewContentModeScaleAspectFit;
    [self.contentView play];
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
