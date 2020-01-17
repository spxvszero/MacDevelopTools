//
//  JKRecodeImageExportViewController.m
//  MacDevelopTools
//
//  Created by jk on 2019/9/17.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKRecodeImageExportViewController.h"
#import "Magick++.h"
#import "ImageInfoHelper.hpp"

@interface JKRecodeImageExportViewController ()

@property (weak) IBOutlet NSTextField *curPathFile;
@property (weak) IBOutlet NSTextField *imageInfoTextField;

@property (weak) IBOutlet NSTextField *outputTextField;
@property (weak) IBOutlet NSTextField *errInfo;
@property (weak) IBOutlet NSSlider *qualitySlider;
@property (weak) IBOutlet NSTextField *qualityInfo;

@property (nonatomic, strong) NSData *imgData;
@end

@implementation JKRecodeImageExportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.qualitySlider.target = self;
    self.qualitySlider.action = @selector(sliderValueChange);
    self.qualitySlider.altIncrementValue = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusItemClose) name:kJKStatusItemPopOverCloseNotification object:nil];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    self.curPathFile.stringValue = self.imageUrl;
}

- (void)statusItemClose
{
    [self cancelAction:nil];
}


- (void)cancelAction:(id)sender
{
    if (self.presentingViewController) {
        [self dismissViewController:self];
    }
    self.imgData = nil;
}

- (void)sliderValueChange
{
    self.qualityInfo.stringValue = [NSString stringWithFormat:@"%d",self.qualitySlider.intValue];
}

- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    self.imgData = [NSData dataWithContentsOfFile:_imageUrl];
}

- (IBAction)exportBtnAction:(id)sender
{
    if (!self.imgData) {
        self.errInfo.stringValue = @"ERR:Empty Image!";
        return;
    }
    const void *imageData = [self.imgData bytes];
    
    NSString *outputValue = self.outputTextField.stringValue;
    if (!outputValue || outputValue.length <= 0) {
        self.errInfo.stringValue = @"ERR:Empty Output Txt!";
        return;
    }
    
    self.errInfo.stringValue = @"Waiting...";
    
    int quality = self.qualitySlider.intValue;
    NSLog(@"quality: %d",quality);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *basePath = [self.imageUrl stringByDeletingLastPathComponent];
        NSString *aimPath = [basePath stringByAppendingPathComponent:outputValue];
        
        MagickCore::Image *imageInfo = MagickCore::BlobToImage(MagickCore::AcquireImageInfo(), imageData, self.imgData.length, MagickCore::AcquireExceptionInfo());
        MagickCore::MagickWand *wand = MagickCore::NewMagickWandFromImage(imageInfo);
        MagickCore::DestroyImage(imageInfo);
        MagickCore::CompressionType compressType = MagickCore::MagickGetCompression(wand);
        NSLog(@"compressType - %s",JKCompressionType[compressType]);
        
        MagickCore::MagickSetImageCompressionQuality(wand, quality); //0-100
        MagickCore::MagickStripImage(wand);
        MagickCore::MagickWriteImage(wand, [aimPath UTF8String]);
//        [self testOutput:wand url:basePath];
        MagickCore::DestroyMagickWand(wand);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"HH:mm:ss";
            self.errInfo.stringValue = [NSString stringWithFormat:@"Finished:%@",[formatter stringFromDate:[NSDate date]]];
        });
    });
}

- (void)testOutput:(MagickCore::MagickWand *)wand url:(NSString *)urlStr
{
    for (int i = 0;i <= MagickCore::ZipSCompression; i++) {
        MagickCore::MagickBooleanType res = MagickCore::MagickSetImageCompression(wand, (MagickCore::CompressionType)i);
        NSLog(@"compress --- %s -- %d", JKCompressionType[i],res);
        
        NSString *formatStr = [NSString stringWithFormat:@"%s.png",JKCompressionType[i]];
        
        NSString *resStr = [urlStr stringByAppendingPathComponent:formatStr];
        MagickCore::MagickStripImage(wand);
        MagickCore::MagickWriteImage(wand, [resStr UTF8String]);
    }
    
}

@end
