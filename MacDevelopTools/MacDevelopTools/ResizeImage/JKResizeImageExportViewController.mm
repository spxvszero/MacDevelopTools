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
    ResizeTypeAndroidIcon,
} JKResizeSelectType;

@interface JKResizeImageExportViewController ()<NSTextFieldDelegate>

@property (nonatomic, strong) NSSavePanel *savePanel;
@property (nonatomic, strong) NSOpenPanel *openPanel;

@property (weak) IBOutlet NSButton *appIconButton;
@property (weak) IBOutlet NSButton *customButton;
@property (weak) IBOutlet NSButton *button2x;
@property (weak) IBOutlet NSButton *androidAppIcon;



@property (weak) IBOutlet NSBox *customInputBox;
@property (weak) IBOutlet NSTextField *customWidthTxtField;
@property (weak) IBOutlet NSTextField *customHeightTxtField;
@property (weak) IBOutlet NSButton *lockBtn;



@property (nonatomic, assign) NSSize currentImageSize;
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
    self.androidAppIcon.tag = ResizeTypeAndroidIcon;
    
    self.customWidthTxtField.delegate = self;
    self.customHeightTxtField.delegate = self;
    
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
    
    if (self.single) {
        self.appIconButton.enabled = YES;
        self.androidAppIcon.enabled = YES;
        self.currentImageSize = [self imageSize];
        self.imageSizeLabel.stringValue = [NSString stringWithFormat:@"ImageSize: %ldx%ld px",(long)(self.currentImageSize.width),(long)(self.currentImageSize.height)];
    }else{
        self.appIconButton.enabled = NO;
        self.androidAppIcon.enabled = NO;
        self.imageSizeLabel.stringValue = @"";
        if (self.currentSelectType == ResizeTypeIcon || self.currentSelectType == ResizeTypeAndroidIcon) {
            [self buttonSelectAction:self.button2x];
            self.button2x.state = NSControlStateValueOn;
        }
    }
    
}


- (IBAction)exportAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    
    if (self.single) {
        switch (self.currentSelectType) {
            case ResizeTypeIcon:
            {
                [self.openPanel beginWithCompletionHandler:^(NSModalResponse result) {
                    if (result == NSModalResponseOK) {
                        [weakSelf appIconExport];
                    }
                }];
            }
                break;
            case ResizeTypeAndroidIcon:
            {
                [self.openPanel beginWithCompletionHandler:^(NSModalResponse result) {
                    if (result == NSModalResponseOK) {
                        [weakSelf androidAppIconExport:weakSelf.openPanel.URL.relativePath];
                    }
                }];
            }
                break;
            case ResizeType2x:
            {
                [self.savePanel beginWithCompletionHandler:^(NSModalResponse result) {
                    NSLog(@"save 2x -- %@",weakSelf.savePanel.URL.relativePath);
                    if (result == NSModalResponseOK) {
                        [weakSelf save2xImage:weakSelf.imageUrl toPath:weakSelf.savePanel.URL.relativePath];
                    }
                }];
            }
                break;
            case ResizeTypeCustom:
            {
                [self.savePanel beginWithCompletionHandler:^(NSModalResponse result) {
                    NSLog(@"save custom -- %@",weakSelf.savePanel.URL.relativePath);
                    if (result == NSModalResponseOK) {
                        [weakSelf customImage:weakSelf.imageUrl toPath:weakSelf.savePanel.URL.relativePath];
                    }
                }];
            }
                break;
            default:
                break;
        }
        
    }else{
        switch (self.currentSelectType) {
            case ResizeType2x:
            {
                NSString *outputPath = [weakSelf.imageUrl stringByAppendingPathComponent:@"output"];
                if (![[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:NO attributes:nil error:nil];
                }
                
                [weakSelf enumImageFilesWithPath:weakSelf.imageUrl block:^(NSString *subName) {
                    [weakSelf save2xImage:[weakSelf.imageUrl stringByAppendingPathComponent:subName] toPath:[outputPath stringByAppendingPathComponent:subName]];
                }];
                
                weakSelf.imageSizeLabel.stringValue = [weakSelf finishString];
            }
                break;
            case ResizeTypeCustom:
            {
                if (![self hasBoxNumber]) {
                    return;
                }
                
                NSString *outputPath = [weakSelf.imageUrl stringByAppendingPathComponent:@"output"];
                if (![[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:NO attributes:nil error:nil];
                }
                
                [weakSelf enumImageFilesWithPath:weakSelf.imageUrl block:^(NSString *subName) {
                    [weakSelf customImage:[weakSelf.imageUrl stringByAppendingPathComponent:subName] toPath:[outputPath stringByAppendingPathComponent:subName]];
                }];
                
                weakSelf.imageSizeLabel.stringValue = [weakSelf finishString];
            }
                break;
            default:
                break;
        }
    }
    

}

- (NSString *)finishString
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm:ss";
    return [[fmt stringFromDate:[NSDate date]] stringByAppendingString:@" Finished!"];
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

- (void)androidAppIconExport:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfFile:self.imageUrl];
    const void *imageData = [data bytes];
    
    MagickCore::Image *imageInfo = MagickCore::BlobToImage(MagickCore::AcquireImageInfo(), imageData, data.length, MagickCore::AcquireExceptionInfo());
    
    /*
     192   mipmap-xxxhdpi
     144   -xxhdpi
     96     -xhdpi
     72     -hdpi
     48     -mdpi
     */
    NSArray *androidIconSize = @[@(192),@(144),@(96),@(72),@(48)];
    NSArray *androidIconPath = @[@"-xxxhdpi",@"-xxhdpi",@"-xhdpi",@"-hdpi",@"-mdpi"];
    
    [androidIconSize enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int intValue = [obj intValue];
        NSString *dirName = [NSString stringWithFormat:@"mipmap%@",[androidIconPath objectAtIndex:idx]];
        NSString *dirPath = [path stringByAppendingPathComponent:dirName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        [self resizeImageWithWidth:intValue height:intValue image:imageInfo path:[dirPath stringByAppendingPathComponent:@"ic_launcher.png"]];
    }];
    
    NSLog(@"finish");
    
    MagickCore::DestroyImage(imageInfo);
}

- (void)save2xImage:(NSString *)imageUrl toPath:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfFile:imageUrl];
    if (!data) {
        return;
    }
    const void *imageData = [data bytes];
    
    MagickCore::Image *imageInfo = MagickCore::BlobToImage(MagickCore::AcquireImageInfo(), imageData, data.length, MagickCore::AcquireExceptionInfo());
    
    [self resizeImageWithWidth:(imageInfo->columns * 2 / 3.f) height:(imageInfo->rows * 2 / 3.f) image:imageInfo path:path];
    
    MagickCore::DestroyImage(imageInfo);
}

- (BOOL)hasBoxNumber
{
    NSInteger width = [self.customWidthTxtField.stringValue integerValue];
    NSInteger height = [self.customHeightTxtField.stringValue integerValue];
    if (width * height <= 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"size should not less than 0";
        [alert beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return NO;
    }
    
    return YES;
}

- (void)customImage:(NSString *)imageUrl toPath:(NSString *)path
{
    if (![self hasBoxNumber]) {
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:imageUrl];
    const void *imageData = [data bytes];
    
    if (!data) {
        return;
    }
    
    MagickCore::Image *imageInfo = MagickCore::BlobToImage(MagickCore::AcquireImageInfo(), imageData, data.length, MagickCore::AcquireExceptionInfo());
    
    NSInteger width = [self.customWidthTxtField.stringValue integerValue];
    NSInteger height = [self.customHeightTxtField.stringValue integerValue];
    
    [self resizeImageWithWidth:width height:height image:imageInfo path:path];
    
    MagickCore::DestroyImage(imageInfo);
}

- (void)enumImageFilesWithPath:(NSString *)path block:(void (^)(NSString *))enumBlock
{
    NSFileManager *fileM = [NSFileManager defaultManager];
    if (![fileM fileExistsAtPath:path]) {
        return;
    }
    NSArray *filePaths = [fileM subpathsAtPath:path];
    
    for (NSString *filePath in filePaths) {
        if ([filePath hasSuffix:@"png"] || [filePath hasSuffix:@"jpg"]) {
            if (enumBlock) {
                enumBlock(filePath);
            }
        }
    }
    
}

#pragma mark - lock action

- (void)controlTextDidChange:(NSNotification *)obj
{
    NSTextField *txtField = [obj object];
    if (self.single && self.lockBtn.state == NSControlStateValueOn) {
        if (self.currentImageSize.width * self.currentImageSize.height <= 0) {
            return;
        }
        CGFloat whRadio = self.currentImageSize.width / self.currentImageSize.height;
        if (txtField == self.customHeightTxtField) {
            CGFloat height = [self.customHeightTxtField.stringValue integerValue];
            CGFloat width = height * whRadio;
            self.customWidthTxtField.stringValue = [NSString stringWithFormat:@"%zd",(NSInteger)width];
        }
        
        if (txtField == self.customWidthTxtField) {
            CGFloat width = [self.customWidthTxtField.stringValue integerValue];
            CGFloat height = width / whRadio;
            self.customHeightTxtField.stringValue = [NSString stringWithFormat:@"%zd",(NSInteger)height];
        }
        
    }
}

- (IBAction)lockBtnAction:(id)sender {
    
    if (NSControlStateValueOn == self.lockBtn.state) {
        [self changeLockBtnState:YES];
    }else{
        [self changeLockBtnState:NO];
    }
}

- (void)changeLockBtnState:(BOOL)on
{
    if (on) {
        self.lockBtn.image = [NSImage imageNamed:@"lock_lock"];
    }else{
        self.lockBtn.image = [NSImage imageNamed:@"lock_unlock"];
    }
}

#pragma mark - resize

- (void)resizeImageWithWidth:(size_t)width height:(size_t)height image:(MagickCore::Image *)imageInfo name:(NSString *)nameStr
{
    MagickCore::Image *outPutimageInfo = MagickCore::ResizeImage(imageInfo, width, height, MagickCore::UndefinedFilter, MagickCore::AcquireExceptionInfo());
//    MagickCore::ConvertImageCommand(outPutimageInfo, 2, {"",""}, NULL, MagickCore::AcquireExceptionInfo());
//    MagickCore::ImageInfo
    
    NSString *outputPath = [[self.openPanel directoryURL] relativePath];
    [self outputData:outPutimageInfo withUrl:[outputPath stringByAppendingPathComponent:nameStr]];
    
    MagickCore::DestroyImage(outPutimageInfo);
}

- (void)resizeImageWithWidth:(size_t)width height:(size_t)height image:(MagickCore::Image *)imageInfo path:(NSString *)path
{
    MagickCore::Image *outPutimageInfo = MagickCore::ResizeImage(imageInfo, width, height, MagickCore::UndefinedFilter, MagickCore::AcquireExceptionInfo());
    
    [self outputData:outPutimageInfo withUrl:path];
    
    MagickCore::DestroyImage(outPutimageInfo);
}


- (NSSize)imageSize
{
    NSData *data = [NSData dataWithContentsOfFile:self.imageUrl];
    if (!data) {
        return NSZeroSize;
    }
    const void *imageData = [data bytes];
    
    MagickCore::ImageInfo *info = MagickCore::AcquireImageInfo();
    
    MagickCore::Image *imageInfo = MagickCore::BlobToImage(info, imageData, data.length, MagickCore::AcquireExceptionInfo());
    
    NSLog(@"imageInfo -- %zu,%zu",imageInfo->columns,imageInfo->rows);
    
//    MagickCore::Image *outPutimageInfo = MagickCore::ResizeImage(imageInfo, 20, 20, MagickCore::UndefinedFilter, MagickCore::AcquireExceptionInfo());
    
//    [self outputData:outPutimageInfo withUrl:@"/Users/jason/Desktop/magic/resxxx"];
    
    return NSMakeSize(imageInfo->columns, imageInfo->rows);
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
