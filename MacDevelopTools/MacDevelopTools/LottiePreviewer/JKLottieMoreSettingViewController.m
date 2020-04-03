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
@property (weak) IBOutlet NSSlider *rotateSlider;
@property (weak) IBOutlet NSTextField *rotatetxtField;


@property (weak) IBOutlet NSButton *loopBtn;
@property (weak) IBOutlet NSButton *autoReverseBtn;

@property (weak) IBOutlet NSTextField *speedTxtField;
@property (weak) IBOutlet NSStepper *speedStepper;


@property (nonatomic, weak) NSView *transBackView;
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

- (void)updateWithLOTAnimationView:(LOTAnimationView *)lotView transBackView:(nonnull NSView *)backView
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
    
    if (backView) {
        self.transBackView = backView;
        self.transBackView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.transBackView.layer.position = CGPointMake(self.transBackView.bounds.size.width * 0.5, self.transBackView.bounds.size.height * 0.5);
    }else{
        self.transBackView = nil;
    }
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

- (IBAction)rotateSliderAction:(id)sender
{
    [self.transBackView.layer setAffineTransform:CGAffineTransformMakeRotation(self.rotateSlider.doubleValue * 0.01 * 2 * M_PI)];
    self.rotatetxtField.doubleValue = self.rotateSlider.doubleValue * 0.01 * 360;
}

- (IBAction)rotateTxtAction:(id)sender
{
    CGFloat value = self.rotatetxtField.doubleValue;
    BOOL minus = false;
    if (value > 0) {
    }else{
        minus = true;
    }
    
    if (ABS(value) / 360.f > 1) {
        value = value - ((NSInteger)value / 360 * 360);
    }
    
    if (minus) {
        value = 360 + value;
    }
    
    self.rotateSlider.floatValue = (value / 360.0) * 100;
    [self.transBackView.layer setAffineTransform:CGAffineTransformMakeRotation(self.rotateSlider.doubleValue * 0.01 * 2 * M_PI)];
    
    self.rotatetxtField.doubleValue = value;
}

- (IBAction)rotateClearBtnAction:(id)sender
{
    self.rotateSlider.floatValue = 0;
    self.rotatetxtField.doubleValue = 0;
    [self.transBackView.layer setAffineTransform:CGAffineTransformIdentity];
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

- (IBAction)speedTxtAction:(id)sender
{
    float value = self.speedTxtField.floatValue;
    self.lotView.animationSpeed = value;
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
