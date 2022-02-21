//
//  JKResizeImageExportViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/20.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKResizeImageExportViewController.h"
#import "Magick++.h"
#import "JKProgressIndicator.h"
#import "NSPanel+JK.h"

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
@property(nonatomic, assign) NSSize currentCustomSize;
@property (weak) IBOutlet NSButton *lockBtn;



@property (nonatomic, assign) NSSize currentImageSize;
@property (weak) IBOutlet NSTextField *imageSizeLabel;
@property (weak) IBOutlet JKProgressIndicator *loadingIndicator;

@property (nonatomic, assign) JKResizeSelectType currentSelectType;

@property (nonatomic, strong) NSArray *iconsSize;


@property(nonatomic, assign) MagickCore::ImageInfo *imageInfo;
@property(nonatomic, assign) MagickCore::Image *image;

@property(nonatomic, strong) NSURL *currentPanelUrl;

@end

@implementation JKResizeImageExportViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear
{
    [super viewDidDisappear];
    
    MagickCore::DestroyImage(self.image);
    MagickCore::DestroyImageInfo(self.imageInfo);
    self.image = nil;
    self.imageInfo = nil;
    self.currentImageSize = NSZeroSize;
    self.imageSizeLabel.stringValue = @"";
    self.currentCustomSize = NSZeroSize;
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

- (void)loadImage
{
    NSData *data = [NSData dataWithContentsOfFile:self.imageUrl];
    if (!data) {
        NSLog(@"Failed Loaded Image Data : %@",self.imageUrl);
        return;
    }
    const void *imageData = [data bytes];
    
    MagickCore::ImageInfo *info = MagickCore::AcquireImageInfo();
    MagickCore::ExceptionInfo *exception = MagickCore::AcquireExceptionInfo();
    MagickCore::Image *image = MagickCore::BlobToImage(info, imageData, data.length, exception);
    
    self.imageInfo = info;
    self.image = image;
    
    self.currentImageSize = [self imageSize];
    self.imageSizeLabel.stringValue = [NSString stringWithFormat:@"ImageSize: %ldx%ld px",(long)(self.currentImageSize.width),(long)(self.currentImageSize.height)];
    [self.loadingIndicator stopLoading];
    MagickCore::DestroyExceptionInfo(exception);
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
    }else{
        self.appIconButton.enabled = NO;
        self.androidAppIcon.enabled = NO;
        self.imageSizeLabel.stringValue = @"";
        if (self.currentSelectType == ResizeTypeIcon || self.currentSelectType == ResizeTypeAndroidIcon) {
            [self buttonSelectAction:self.button2x];
            self.button2x.state = NSControlStateValueOn;
        }
    }
    
    [self.loadingIndicator startLoading];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadImage];
    });
}


- (IBAction)exportAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    
    if (self.single) {
        switch (self.currentSelectType) {
            case ResizeTypeIcon:
            {
                [self.openPanel jk_beginWithCompletionHandler:^(NSModalResponse result) {
                    if (result == NSModalResponseOK) {
                        weakSelf.currentPanelUrl = weakSelf.openPanel.URL;
                        [weakSelf startTaskIfSingle:true];
                    }
                }];
            }
                break;
            case ResizeTypeAndroidIcon:
            {
                [self.openPanel jk_beginWithCompletionHandler:^(NSModalResponse result) {
                    if (result == NSModalResponseOK) {
                        weakSelf.currentPanelUrl = weakSelf.openPanel.URL;
                        [weakSelf startTaskIfSingle:true];
                    }
                }];
            }
                break;
            case ResizeType2x:
            {
                [self.savePanel jk_beginWithCompletionHandler:^(NSModalResponse result) {
                    NSLog(@"save 2x -- %@",weakSelf.savePanel.URL.relativePath);
                    if (result == NSModalResponseOK) {
                        weakSelf.currentPanelUrl = weakSelf.savePanel.URL;
                        [weakSelf startTaskIfSingle:true];
                    }
                }];
            }
                break;
            case ResizeTypeCustom:
            {
                [self.savePanel jk_beginWithCompletionHandler:^(NSModalResponse result) {
                    NSLog(@"save custom -- %@",weakSelf.savePanel.URL.relativePath);
                    if (result == NSModalResponseOK) {
                        if (![weakSelf hasBoxNumber]) {
                            return;
                        }
                        weakSelf.currentCustomSize = NSMakeSize(weakSelf.customWidthTxtField.stringValue.integerValue, weakSelf.customHeightTxtField.stringValue.integerValue);
                        weakSelf.currentPanelUrl = weakSelf.savePanel.URL;
                        [weakSelf startTaskIfSingle:true];
                    }
                }];
            }
                break;
            default:
                break;
        }
        
    }else{
        [self startTaskIfSingle:false];
    }
    

}

- (void)startTaskIfSingle:(BOOL)single
{
    [self.loadingIndicator startLoading];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        if (single) {
            [self startSingleTaskWithCurrentSelectedType];
        }else{
            [self startMultiTaskWithCurrentSelectedType];
        }
    });
}

- (void)finishTask
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicator stopLoading];
    });
}

- (void)startSingleTaskWithCurrentSelectedType
{
    
    switch (self.currentSelectType) {
        case ResizeTypeIcon:
        {
            [self appIconExport];
        }
            break;
        case ResizeType2x:
        {
            [self save2xImage:self.imageUrl toPath:[self.currentPanelUrl relativePath]];
        }
            break;
        case ResizeTypeAndroidIcon:
        {
            [self androidAppIconExport:[self.currentPanelUrl relativePath]];
        }
            break;
        case ResizeTypeCustom:
        {
            [self customImage:self.imageUrl toPath:[self.currentPanelUrl relativePath]];
        }
            break;
        default:
            break;
    }
    
}

- (void)startMultiTaskWithCurrentSelectedType
{
    switch (self.currentSelectType) {
        case ResizeTypeIcon:
        {
            
        }
            break;
        case ResizeType2x:
        {
            NSString *outputPath = [self.imageUrl stringByAppendingPathComponent:@"output"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            
            [self enumImageFilesWithPath:self.imageUrl block:^(NSString *subName) {
                [self save2xImage:[self.imageUrl stringByAppendingPathComponent:subName] toPath:[outputPath stringByAppendingPathComponent:subName]];
            }];
            
            self.imageSizeLabel.stringValue = [self finishString];
        }
            break;
        case ResizeTypeAndroidIcon:
        {
           
        }
            break;
        case ResizeTypeCustom:
        {
            if (![self hasBoxNumber]) {
                return;
            }
            
            NSString *outputPath = [self.imageUrl stringByAppendingPathComponent:@"output"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            
            [self enumImageFilesWithPath:self.imageUrl block:^(NSString *subName) {
                [self customImage:[self.imageUrl stringByAppendingPathComponent:subName] toPath:[outputPath stringByAppendingPathComponent:subName]];
            }];
            
            self.imageSizeLabel.stringValue = [self finishString];
        }
            break;
        default:
            break;
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
    for (NSNumber *size in self.iconsSize) {
        int intValue = [size intValue];
        [self resizeImageWithWidth:intValue height:intValue image:self.image name:[NSString stringWithFormat:@"%dx%d.png",intValue,intValue]];
    }
}

- (void)androidAppIconExport:(NSString *)path
{
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
        [self resizeImageWithWidth:intValue height:intValue image:self.image path:[dirPath stringByAppendingPathComponent:@"ic_launcher.png"]];
    }];
}

- (void)save2xImage:(NSString *)imageUrl toPath:(NSString *)path
{
    [self resizeImageWithWidth:(self.image->columns * 2 / 3.f) height:(self.image->rows * 2 / 3.f) image:self.image path:path];
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
    [self resizeImageWithWidth:self.currentCustomSize.width height:self.currentCustomSize.height image:self.image path:path];
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
    MagickCore::ExceptionInfo *exception = MagickCore::AcquireExceptionInfo();
    MagickCore::Image *outPutimageInfo = MagickCore::ResizeImage(imageInfo, width, height, MagickCore::UndefinedFilter, exception);
    
    NSString *outputPath = [self.currentPanelUrl relativePath];
    [self outputData:outPutimageInfo withUrl:[outputPath stringByAppendingPathComponent:nameStr]];
    
    MagickCore::DestroyImage(outPutimageInfo);
    MagickCore::DestroyExceptionInfo(exception);
}

- (void)resizeImageWithWidth:(size_t)width height:(size_t)height image:(MagickCore::Image *)imageInfo path:(NSString *)path
{
    MagickCore::ExceptionInfo *exception = MagickCore::AcquireExceptionInfo();
    MagickCore::Image *outPutimageInfo = MagickCore::ResizeImage(imageInfo, width, height, MagickCore::UndefinedFilter, exception);
    
    [self outputData:outPutimageInfo withUrl:path];
    
    MagickCore::DestroyImage(outPutimageInfo);
    MagickCore::DestroyExceptionInfo(exception);
}


- (NSSize)imageSize
{
    NSLog(@"imageInfo -- %zu,%zu",self.image->columns,self.image->rows);
    
    NSSize size = NSMakeSize(self.image->columns, self.image->rows);
    
    return size;
}

- (void)outputData:(MagickCore::Image *)imageInfo withUrl:(NSString *)urlStr
{
    NSLog(@"output url -- %@",urlStr);
    size_t outputSize;
    MagickCore::ImageInfo *info = MagickCore::AcquireImageInfo();
    MagickCore::ExceptionInfo *exception = MagickCore::AcquireExceptionInfo();
    const void *outputData = MagickCore::ImageToBlob(info, imageInfo, &outputSize, exception);
    
    NSData *resData = [[NSData alloc] initWithBytes:outputData length:outputSize];
    
    [resData writeToFile:urlStr atomically:YES];
    
    MagickCore::DestroyImageInfo(info);
    MagickCore::DestroyExceptionInfo(exception);
    
    [self finishTask];
}

- (NSArray *)iconsSize
{
    if (!_iconsSize) {
        _iconsSize = @[@(1024),@(180),@(120),@(80),@(60),@(58),@(40),@(20)];
    }
    return _iconsSize;
}

@end
