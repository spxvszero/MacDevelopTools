//
//  JKQRCodeViewController.m
//  MacDevelopTools
//
//  Created by jacky on 2019/2/16.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKQRCodeViewController.h"
#import "NSImage+JKConvert.h"
#import <CoreImage/CoreImage.h>
#import "JKInfoImageView.h"

@interface JKQRCodeViewController ()<NSTextViewDelegate>
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet JKInfoImageView *imgView;
@property (weak) IBOutlet NSButton *saveBtn;
@property (weak) IBOutlet NSButton *autoLoadBtn;

@property (nonatomic, strong) NSSavePanel *savePanel;


@end

@implementation JKQRCodeViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.textView.delegate = self;
    
    self.imgView.editable = YES;
    __weak typeof(self) weakSelf = self;
    self.imgView.ImageDidChangeBlock = ^(JKInfoImageView *imageView, NSURL *fileUrl, NSImage *image) {
        weakSelf.textView.string = [weakSelf stringFromFileImage:image];
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusItemClose) name:kJKStatusItemPopOverCloseNotification object:nil];
}

- (void)statusItemClose
{
    [self.savePanel cancel:nil];
}

- (IBAction)saveAsAction:(id)sender
{
    if (!self.imgView.image) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.savePanel beginWithCompletionHandler:^(NSModalResponse result) {
         if (result == NSModalResponseOK) {
             NSLog(@"save -- %@",weakSelf.savePanel.URL);
             NSImage *image = weakSelf.imgView.image;
             [image lockFocus] ;
             NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, [image size].width, [image size].height)] ;
             [image unlockFocus] ;
             NSData *data = [bitmapRep representationUsingType:NSPNGFileType properties:@{}];
             [data writeToURL:weakSelf.savePanel.URL atomically:NO];
         }
    }];
}

- (void)textDidChange:(NSNotification *)notification
{
    if (notification.object == self.textView) {
        if (self.autoLoadBtn.state == NSControlStateValueOn) {
            if (self.textView.string && self.textView.string.length > 0) {
                [self startGenerateCode];
            }else{
                [self.imgView setImageWithNoBlock:nil];
            }
        }
    }
}

/**
 * 将二维码图片转化为字符
 */
- (NSString *)stringFromFileImage:(NSImage *)img {
    CIImage *cImg = [img jk_CIImage];
    CIDetector *det = [CIDetector detectorOfType:@"CIDetectorTypeQRCode" context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    
    NSArray *arr = [det featuresInImage:cImg];
    
    CIQRCodeFeature *qrStr = arr.firstObject;
    //只返回第一个扫描到的二维码
    return qrStr.messageString;
}

/**
 * 将字符转化为二维码图片
 */
- (void)startGenerateCode
{
    //    NSArray *filenames = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    //    NSLog(@"%@", filenames);
    //使用系统自带的生成器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    NSData *data = [self.textView.string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    
    CIImage *cImage = [filter outputImage];
    CGAffineTransform scale = CGAffineTransformMakeScale(10, 10);
    CIImage *cSImage = [cImage imageByApplyingTransform:scale];
    
    //将生成的图片显示出来
    NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:cSImage];
    NSImage *nsImage = [[NSImage alloc] initWithSize:NSMakeSize(1024, 1024)];
    [nsImage addRepresentation:rep];
    [self.imgView setImageWithNoBlock:nsImage];
}

- (NSSavePanel *)savePanel
{
    if (!_savePanel) {
        _savePanel = [NSSavePanel savePanel];
        _savePanel.title = @"Export";
        _savePanel.showsResizeIndicator = YES;
        _savePanel.canCreateDirectories = YES;
        _savePanel.showsHiddenFiles = YES;
        _savePanel.allowedFileTypes = @[@"png"];
    }
    return _savePanel;
}


@end
