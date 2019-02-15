//
//  JKResizeImageExportViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/20.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKResizeImageExportViewController.h"
#import "Magick++.h"

typedef enum : NSInteger {
    ResizeTypeIcon = 0,
    ResizeType2x,
    ResizeTypeCustom,
} JKResizeSelectType;

@interface JKResizeImageExportViewController ()

@property (nonatomic, strong) NSSavePanel *savePanel;
@property (nonatomic, strong) NSOpenPanel *openPanel;

@property (weak) IBOutlet NSButton *appIconButton;
@property (weak) IBOutlet NSButton *customButton;
@property (weak) IBOutlet NSButton *button2x;



@property (weak) IBOutlet NSBox *customInputBox;
@property (weak) IBOutlet NSTextField *imageSizeLabel;

@property (nonatomic, assign) JKResizeSelectType currentSelectType;

@property (nonatomic, strong) NSArray *iconsSize;

@end

@implementation JKResizeImageExportViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.appIconButton.tag = ResizeTypeIcon;
    self.customButton.tag = ResizeTypeCustom;
    self.button2x.tag = ResizeType2x;
    
    self.appIconButton.state = NSControlStateValueOn;
    
    [self buttonSelectAction:self.appIconButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusItemClose) name:kJKStatusItemPopOverCloseNotification object:nil];
    
//    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
//    Magick::InitializeMagick([arguments[1] cStringUsingEncoding:NSASCIIStringEncoding]);
}

- (void)statusItemClose
{
    [self cancelAction:nil];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
//    self.imageSizeLabel.stringValue = [NSString stringWithFormat:@"ImageSize: %ldx%ld px",(long)(self.image.size.width),(long)(self.image.size.height)];
}


- (IBAction)exportAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    if (self.currentSelectType == ResizeTypeIcon) {
        [self.openPanel beginWithCompletionHandler:^(NSModalResponse result) {
            if (result == NSModalResponseOK) {
                [self appIconExport];
            }
        }];
    }else{
        [self.savePanel beginWithCompletionHandler:^(NSModalResponse result) {
            NSLog(@"save -- %@",weakSelf.savePanel.URL);
        }];
    }
}

- (IBAction)cancelAction:(id)sender
{
    [self.openPanel cancel:self];
    [self.savePanel cancel:self];
    if (self.presentingViewController) {
        [self dismissViewController:self];        
    }
}

- (IBAction)buttonSelectAction:(NSButton *)sender
{
    self.currentSelectType = (JKResizeSelectType)sender.tag;
    
    switch (self.currentSelectType) {
        case ResizeTypeIcon:
        {
            self.customInputBox.hidden = YES;
        }
            break;
        case ResizeTypeCustom:
        {
            self.customInputBox.hidden = NO;
        }
            break;
        case ResizeType2x:
        {
            self.customInputBox.hidden = YES;
        }
            break;
            
        default:
            break;
    }
    
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

- (NSOpenPanel *)openPanel
{
    if (!_openPanel) {
        _openPanel = [NSOpenPanel openPanel];
        _openPanel.canChooseFiles = NO;
        _openPanel.canChooseDirectories = YES;
        _openPanel.showsHiddenFiles = YES;
        _openPanel.canCreateDirectories = YES;
        _openPanel.showsResizeIndicator = YES;
    }
    return _openPanel;
}

- (void)appIconExport
{
    NSData *data = [NSData dataWithContentsOfFile:self.imageUrl];
    const void *imageData = [data bytes];
    
    MagickCore::Image *imageInfo = MagickCore::BlobToImage(MagickCore::AcquireImageInfo(), imageData, data.length, MagickCore::AcquireExceptionInfo());
    
    for (NSNumber *size in self.iconsSize) {
        int intValue = [size intValue];
        [self resizeImageWithWidth:intValue height:intValue image:imageInfo name:[NSString stringWithFormat:@"%dx%d.png",intValue,intValue]];
    }
    NSLog(@"finish");
    
    MagickCore::DestroyImage(imageInfo);
}



- (void)resizeImageWithWidth:(size_t)width height:(size_t)height image:(MagickCore::Image *)imageInfo name:(NSString *)nameStr
{
    MagickCore::Image *outPutimageInfo = MagickCore::ResizeImage(imageInfo, width, height, MagickCore::UndefinedFilter, MagickCore::AcquireExceptionInfo());
//    MagickCore::ConvertImageCommand(outPutimageInfo, 2, {"",""}, NULL, MagickCore::AcquireExceptionInfo());
//    MagickCore::ImageInfo
    
    NSString *outputPath = [[self.openPanel directoryURL] relativePath];
    [self outputData:outPutimageInfo withUrl:[outputPath stringByAppendingPathComponent:nameStr]];
    
    MagickCore::DestroyImage(outPutimageInfo);
}


- (NSSize)imageSize
{
    NSData *data = [NSData dataWithContentsOfFile:self.imageUrl];
    const void *imageData = [data bytes];
    MagickCore::ImageInfo *info = MagickCore::AcquireImageInfo();
    
    MagickCore::Image *imageInfo = MagickCore::BlobToImage(info, imageData, data.length, MagickCore::AcquireExceptionInfo());
    
    NSLog(@"imageInfo -- %zu,%zu",imageInfo->columns,imageInfo->rows);
    
    MagickCore::Image *outPutimageInfo = MagickCore::ResizeImage(imageInfo, 20, 20, MagickCore::UndefinedFilter, MagickCore::AcquireExceptionInfo());
    
    [self outputData:outPutimageInfo withUrl:@"/Users/jason/Desktop/magic/resxxx"];
    
    return NSZeroSize;
}

- (void)outputData:(MagickCore::Image *)imageInfo withUrl:(NSString *)urlStr
{
    NSLog(@"output url -- %@",urlStr);
    size_t outputSize;
    const void *outputData = MagickCore::ImageToBlob(MagickCore::AcquireImageInfo(), imageInfo, &outputSize, MagickCore::AcquireExceptionInfo());
    
    NSData *resData = [[NSData alloc] initWithBytes:outputData length:outputSize];
    
    [resData writeToFile:urlStr atomically:YES];
}

- (NSArray *)iconsSize
{
    if (!_iconsSize) {
        _iconsSize = @[@(1024),@(180),@(120),@(80),@(60),@(58),@(40),@(20)];
    }
    return _iconsSize;
}

@end
