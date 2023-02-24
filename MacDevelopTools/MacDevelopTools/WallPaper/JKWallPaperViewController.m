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
#import "JKWallPaperVideoPanelController.h"
#import <AVFoundation/AVFoundation.h>

@interface JKWallPaperWindowObject : NSObject

@property (nonatomic, weak) NSScreen *screen;
@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, assign) BOOL showWindow;
@property (nonatomic, strong) NSImageView *backImageView;
@property (nonatomic, strong) NSView *playerLayerBackView;
@property (nonatomic, strong) AVPlayerLayer *playerlayer;


@end
@implementation JKWallPaperWindowObject
@end




@interface JKWallPaperViewController ()

@property (weak) IBOutlet JKWellImageView *imageWallView;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSView *controlContainView;

@property (nonatomic, strong) JKWallPaperImagePanelController *imagePanelController;
@property (nonatomic, strong) JKWallPaperVideoPanelController *videoPanelController;
@property (nonatomic, weak) NSView *currentPanelView;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSMutableArray<JKWallPaperWindowObject *> *windowObjsArr;
@property (nonatomic, assign) BOOL showWindow;
@property (nonatomic, assign) NSImageScaling selectedImageScaling;

@end

@implementation JKWallPaperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self defaultSetting];
    [self addNotification];
    
    __weak typeof(self) weakSelf = self;
    self.imageWallView.ImageDidChangeBlock = ^(JKWellImageView *imageView, NSImage *image, NSURL *fileUrl, BOOL isImage) {
        
        for (JKWallPaperWindowObject *windowObj in weakSelf.windowObjsArr) {
            
            if (isImage) {
                windowObj.backImageView.image = image;
                windowObj.backImageView.hidden = NO;
                windowObj.playerLayerBackView.hidden = YES;
                [weakSelf stopPlay];
                if (image) {
                    weakSelf.imagePanelController.currentScaling = weakSelf.selectedImageScaling;
                    weakSelf.currentPanelView = weakSelf.imagePanelController.view;
                }else{
                    weakSelf.currentPanelView = nil;
                }
            }else{
                windowObj.backImageView.hidden = YES;
                windowObj.playerLayerBackView.hidden = NO;
                
                AVPlayerItem *item = [AVPlayerItem playerItemWithURL:fileUrl];
                windowObj.playerlayer.player = self.player;
                [self.player replaceCurrentItemWithPlayerItem:item];
                [self.player play];
                
                weakSelf.currentPanelView = weakSelf.videoPanelController.view;
            }
            [weakSelf resizeView];
            
        }
    };
    
}

- (void)defaultSetting
{
    _selectedImageScaling = NSImageScaleNone;
    
}

- (IBAction)startButtonClickAction:(id)sender
{
    [self buildWindowObj];
    
    self.showWindow = !self.showWindow;
    
    for (JKWallPaperWindowObject *windowObj in self.windowObjsArr) {
        if (windowObj.window) {
            windowObj.showWindow = !windowObj.showWindow;
            if (self.showWindow) {
                [windowObj.window makeKeyAndOrderFront:nil];
            }else{
                [windowObj.window close];
            }
        }else{
            
        }
    }
    
    if (self.showWindow) {
        if (self.currentPanelView) {
            [self.controlContainView addSubview:self.currentPanelView];
            if (self.currentPanelView == self.videoPanelController.view) {
                [self.player play];
            }
            [self resizeView];
        }
        self.startButton.title = @"Stop Replace";
        self.imageWallView.editable = YES;
    }else{
        [self stopPlay];
        if (self.currentPanelView.superview) {
            [self.currentPanelView removeFromSuperview];
        }
        self.startButton.title = @"Replace Start";
        self.imageWallView.editable = NO;
    }
}

- (void)stopPlay
{
    if (_player) {
        [self.player pause];
    }
}

- (void)resizeView
{
    if (self.MeunSizeChangeBlock) {
        CGFloat width = self.currentPanelView.bounds.size.width + self.imageWallView.bounds.size.width + 30;
        CGFloat height = self.currentPanelView.bounds.size.height + self.startButton.bounds.size.height + 30;
        
        self.view.frame = CGRectMake(0, 0, width, height);
        
        self.MeunSizeChangeBlock(NSMakeSize(width, height));
    
    }
}

- (void)buildWindowObj
{
    [self clearWindowObj];
    
    NSArray* screensArr = [NSScreen screens];
    for (NSScreen *screen in screensArr) {
        JKWallPaperWindowObject *obj = nil;
        for (JKWallPaperWindowObject *windowObj in self.windowObjsArr) {
            if (windowObj.screen == screen) {
                obj = windowObj;
                break;
            }
        }
        
        if (obj) {
        
        }else{
            obj = [[JKWallPaperWindowObject alloc] init];
            obj.screen = screen;
            [self setupWindowWithWindowObj:obj];
            [self.windowObjsArr addObject:obj];
        }
        
    }
}

- (void)clearWindowObj
{
    NSMutableArray *arr = [NSMutableArray array];
    for (JKWallPaperWindowObject *windowObj in self.windowObjsArr) {
        if (!windowObj.screen) {
            [arr addObject:windowObj];
        }
    }
    [self.windowObjsArr removeObjectsInArray:arr];
}


- (void)setupWindowWithWindowObj:(JKWallPaperWindowObject *)windowObj
{
    if (!windowObj.window) {
        windowObj.window = [[NSWindow alloc] init];
        
        windowObj.window.styleMask = NSWindowStyleMaskBorderless;
        windowObj.window.level = CGWindowLevelForKey(kCGDesktopWindowLevelKey);
        windowObj.window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces;
    }
    
    NSRect rect = windowObj.screen.frame;
    NSSize size = rect.size;
    NSPoint point = rect.origin;
    [windowObj.window setContentSize:size];
    [windowObj.window setFrameOrigin:point];
    [windowObj.window setReleasedWhenClosed:NO];
    
    [self setupWindowSubviewsWithSize:size windowObj:windowObj];
    
    [windowObj.window makeKeyAndOrderFront:nil];
}

- (void)setupWindowSubviewsWithSize:(NSSize)size windowObj:(JKWallPaperWindowObject *)windowObj
{
    if (!windowObj.backImageView) {
        windowObj.backImageView = [[NSImageView alloc] init];
        windowObj.backImageView.frame = NSMakeRect(0, 0, size.width, size.height);
        windowObj.backImageView.hidden = YES;
        windowObj.backImageView.imageScaling = self.selectedImageScaling;
    }
    
    if (!windowObj.playerLayerBackView) {
        windowObj.playerLayerBackView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, size.width, size.height)];
        windowObj.playerLayerBackView.wantsLayer = YES;
    }else{
        windowObj.playerLayerBackView.frame = NSMakeRect(0, 0, size.width, size.height);
    }
    
    if (!windowObj.playerlayer) {
        windowObj.playerlayer = [[AVPlayerLayer alloc] init];
        windowObj.playerlayer.videoGravity = AVLayerVideoGravityResizeAspect;
        windowObj.playerlayer.frame = NSMakeRect(0, 0, size.width, size.height);
        [windowObj.playerLayerBackView.layer addSublayer:windowObj.playerlayer];
    }
    
    windowObj.window.contentView.wantsLayer = YES;
    [windowObj.window.contentView addSubview:windowObj.backImageView];
    [windowObj.window.contentView addSubview:windowObj.playerLayerBackView];
}

- (void)setSelectedImageScaling:(NSImageScaling)selectedImageScaling
{
    _selectedImageScaling = selectedImageScaling;
    
    for (JKWallPaperWindowObject *windowObj in self.windowObjsArr) {
        windowObj.backImageView.imageScaling = _selectedImageScaling;
    }
}

#pragma mark - notification

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerReachEndOfItem:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playerReachEndOfItem:(NSNotification *)notify
{
    if (_player && notify.object == self.player.currentItem) {
        [self.player seekToTime:CMTimeMake(0, 30)];
        [self.player play];
    }
}

#pragma mark - setter

- (void)setCurrentPanelView:(NSView *)currentPanelView
{
    if (_currentPanelView.superview) {
        [_currentPanelView removeFromSuperview];
    }
    
    _currentPanelView = currentPanelView;
    
    [self.controlContainView addSubview:_currentPanelView];
    
}

#pragma mark - getter

- (AVPlayer *)player
{
    if (!_player) {
        _player = [[AVPlayer alloc] init];
//        CMTime timeInterval = CMTimeMake(1, 30);
//        [_player addPeriodicTimeObserverForInterval:timeInterval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//            NSLog(@"play time - %lld",time.value/time.timescale);
//        }];
        self.videoPanelController.voiceValue = _player.volume;
        self.videoPanelController.selectedIndex = 0;
        
    }
    return _player;
    
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

- (JKWallPaperVideoPanelController *)videoPanelController
{
    if (!_videoPanelController) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"WallPaper" bundle:nil];
        _videoPanelController = [sb instantiateControllerWithIdentifier:@"JKWallPaperVideoPanelController"];
        __weak typeof(self) weakSelf = self;
        _videoPanelController.VideoAspectSelectBlock = ^(NSInteger selectIndex) {
            NSString *resStr = AVLayerVideoGravityResizeAspect;
            switch (selectIndex) {
                case 0:
                    resStr = AVLayerVideoGravityResizeAspect;
                    break;
                case 1:
                    resStr = AVLayerVideoGravityResizeAspectFill;
                    break;
                case 2:
                    resStr = AVLayerVideoGravityResize;
                    break;
                default:
                    break;
            }
            
            for (JKWallPaperWindowObject *windowObj in weakSelf.windowObjsArr) {
                windowObj.playerlayer.videoGravity =  resStr;
            }
        };
        
        _videoPanelController.VideoVoiceEnableBlock = ^(BOOL enable) {
            if (enable) {
                weakSelf.player.volume = 0;
            }else{
                weakSelf.player.volume = 0;
            }
        };
        
        _videoPanelController.VideoVoiceValueChangeBlock = ^(CGFloat value) {
            weakSelf.player.volume = value;
        };
        
    }
    return _videoPanelController;
}

- (NSMutableArray<JKWallPaperWindowObject *> *)windowObjsArr
{
    if (!_windowObjsArr) {
        _windowObjsArr = [NSMutableArray array];
    }
    return _windowObjsArr;
}

@end
