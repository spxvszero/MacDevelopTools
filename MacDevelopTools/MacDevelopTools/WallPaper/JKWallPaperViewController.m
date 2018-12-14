//
//  JKWallPaperViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/14.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKWallPaperViewController.h"
#import "JKWellImageView.h"
#import "JKWallPaperImagePanelController.h"

@interface JKWallPaperViewController ()

@property (weak) IBOutlet JKWellImageView *imageWallView;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSView *controlContainView;

@property (nonatomic, strong) JKWallPaperImagePanelController *imagePanelController;

@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, assign) BOOL showWindow;
@property (nonatomic, strong) NSImageView *backImageView;
@property (nonatomic, assign) NSImageScaling selectedImageScaling;

@end

@implementation JKWallPaperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self defaultSetting];
    
    __weak typeof(self) weakSelf = self;
    self.imageWallView.ImageDidChangeBlock = ^(JKWellImageView *imageView, NSImage *image) {
        weakSelf.backImageView.image = image;
        if (image) {
            if (weakSelf.controlContainView.subviews.count <= 0) {
                weakSelf.imagePanelController.currentScaling = weakSelf.selectedImageScaling;
                [weakSelf.controlContainView addSubview:weakSelf.imagePanelController.view];
            }
        }else{
            if (weakSelf.imagePanelController.view.superview) {
                [weakSelf.imagePanelController.view removeFromSuperview];
            }
        }
    };
    
}

- (void)defaultSetting
{
    /*
    NSImageScaleProportionallyDown = 0, // Scale image down if it is too large for destination. Preserve aspect ratio.
    NSImageScaleAxesIndependently,      // Scale each dimension to exactly fit destination. Do not preserve aspect ratio.
    NSImageScaleNone,                   // Do not scale.
    NSImageScaleProportionallyUpOrDown,
     */
    _selectedImageScaling = NSImageScaleNone;
    
}

- (IBAction)startButtonClickAction:(id)sender
{
    if (self.window) {
        self.showWindow = !self.showWindow;
        if (self.showWindow) {
            [self.window makeKeyAndOrderFront:nil];
        }else{
            [self.window close];
        }
    }else{
        [self setupWindow];
        self.showWindow = YES;
    }
    
    if (self.showWindow) {
        self.startButton.title = @"Stop Replace";
        self.imageWallView.editable = YES;
    }else{
        self.startButton.title = @"Replace Start";
        self.imageWallView.editable = NO;
    }
    
}


- (void)setupWindow
{
    self.window = [[NSWindow alloc] init];
    
    NSScreen *screen = [NSScreen mainScreen];
    self.window.styleMask = NSWindowStyleMaskBorderless;
    self.window.level = CGWindowLevelForKey(kCGDesktopWindowLevelKey);
    self.window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces;
    
    NSRect rect = screen.frame;
    NSSize size = rect.size;
    NSPoint point = rect.origin;
    [self.window setFrameOrigin:point];
    [self.window setContentSize:size];
    [self.window setReleasedWhenClosed:NO];
    
    [self setupWindowSubviewsWithSize:size];
    
    [self.window makeKeyAndOrderFront:nil];
}

- (void)setupWindowSubviewsWithSize:(NSSize)size
{
    self.backImageView = [[NSImageView alloc] init];
    self.backImageView.frame = NSMakeRect(0, 0, size.width, size.height);
    self.backImageView.imageScaling = self.selectedImageScaling;
    [self.window.contentView addSubview:self.backImageView];
}

- (void)setSelectedImageScaling:(NSImageScaling)selectedImageScaling
{
    _selectedImageScaling = selectedImageScaling;
    self.backImageView.imageScaling = _selectedImageScaling;
}

- (JKWallPaperImagePanelController *)imagePanelController
{
    if (!_imagePanelController) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"WallPaper" bundle:nil];
        _imagePanelController = [sb instantiateControllerWithIdentifier:@"JKWallPaperImagePanelController"];
        __weak typeof(self) weakSelf = self;
        _imagePanelController.ImageScaleButtonSelectBlock = ^(NSImageScaling scaling) {
            weakSelf.selectedImageScaling = scaling;
        };
    }
    return _imagePanelController;
}

@end
