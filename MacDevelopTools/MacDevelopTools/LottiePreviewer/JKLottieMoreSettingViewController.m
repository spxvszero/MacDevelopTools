//
//  JKLottieMoreSettingViewController.m
//  MacDevelopTools
//
//  Created by jk on 2020/4/2.
//  Copyright © 2020 JK. All rights reserved.
//

#import "JKLottieMoreSettingViewController.h"
#import <Lottie/Lottie.h>

@interface JKLottieMoreSettingViewController ()

@property (weak) IBOutlet NSColorWell *backgroundColorWell;
@property (weak) IBOutlet NSPopUpButton *contentModePopBtn;
@property (weak) IBOutlet NSButton *loopBtn;
@property (weak) IBOutlet NSButton *autoReverseBtn;

@property (weak) IBOutlet NSTextField *speedTxtField;
@property (weak) IBOutlet NSStepper *speedStepper;


@property (nonatomic, weak) LOTAnimationView *lotView;

@end

@implementation JKLottieMoreSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSArray *popupTitles = @[
        @"ScaleToFill",
        @"ScaleAspectFit",
        @"ScaleAspectFill",
        @"Redraw",
        @"Center",
        @"Top",
        @"Bottom",
        @"Left",
        @"Right",
        @"TopLeft",
        @"TopRight",
        @"BottomLeft",
        @"BottomRight"
    ];
    [self.contentModePopBtn removeAllItems];
    [self.contentModePopBtn addItemsWithTitles:popupTitles];
    
    self.speedStepper.minValue = -100;
    self.speedStepper.maxValue = 100;
}

- (void)updateWithLOTAnimationView:(LOTAnimationView *)lotView
{
    if (!lotView) {
        return;
    }
    self.backgroundColorWell.color = lotView.layer.backgroundColor?[NSColor colorWithCGColor:lotView.layer.backgroundColor]:[NSColor textColor];
    [self.contentModePopBtn selectItemAtIndex:lotView.contentMode];
    self.loopBtn.state = lotView.loopAnimation?NSControlStateValueOn:NSControlStateValueOff;
    self.autoReverseBtn.state = lotView.autoReverseAnimation?NSControlStateValueOn:NSControlStateValueOff;
    self.speedStepper.doubleValue = lotView.animationSpeed;
    self.speedTxtField.stringValue = [NSString stringWithFormat:@"x%.1f",lotView.animationSpeed];
    
    self.lotView = lotView;
}

#pragma mark - action

- (IBAction)colorWellChanged:(id)sender
{
    self.lotView.layer.backgroundColor = self.backgroundColorWell.color.CGColor;
}
- (IBAction)popUpItemsSelected:(id)sender
{
    self.lotView.contentMode = [self.contentModePopBtn indexOfSelectedItem];
}
- (IBAction)loopBtnClickAction:(id)sender
{
    self.lotView.loopAnimation = (self.loopBtn.state == NSControlStateValueOn);
}
- (IBAction)autoReverseClickAction:(id)sender
{
    self.lotView.autoReverseAnimation = (self.autoReverseBtn.state == NSControlStateValueOn);
}
- (IBAction)stepperClick:(id)sender
{
    self.lotView.animationSpeed = self.speedStepper.doubleValue;
    [self updateSpeedText];
}

- (IBAction)resetSpeedAction:(id)sender
{
    self.lotView.animationSpeed = 1;
    [self updateSpeedText];
}

- (void)updateSpeedText
{
    self.speedTxtField.stringValue = [NSString stringWithFormat:@"x%.1f",self.lotView.animationSpeed];
}

@end
