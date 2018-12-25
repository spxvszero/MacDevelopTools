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
    
    self.imageUrl = @"/Users/jason/Desktop/123.png";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusItemClose) name:kJKStatusItemPopOverCloseNotification object:nil];
}

- (void)statusItemClose
{
    [self cancelAction:nil];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    self.imageSizeLabel.stringValue = [NSString stringWithFormat:@"ImageSize: %ldx%ld px",(long)(self.image.size.width),(long)(self.image.size.height)];
}


- (IBAction)exportAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    if (self.currentSelectType == ResizeTypeIcon) {
        [self.openPanel beginWithCompletionHandler:^(NSModalResponse result) {

        }];
    }else{
        [self.savePanel beginWithCompletionHandler:^(NSModalResponse result) {
            NSLog(@"save -- %@",weakSelf.savePanel.URL);
        }];
    }
    
//    [self resizeImageWithSize:NSZeroSize];
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


- (NSImage *)resizeImageWithSize:(NSSize)size
{
   NSData *data = [NSData dataWithContentsOfFile:self.imageUrl];
   const void *imageData = [data bytes];

   NSArray *arguments = [[NSProcessInfo processInfo] arguments];
   Magick::InitializeMagick([arguments[1] cStringUsingEncoding:NSASCIIStringEncoding]);

   MagickCore::Image *imageInfo = MagickCore::BlobToImage(MagickCore::AcquireImageInfo(), imageData, data.length, MagickCore::AcquireExceptionInfo());

   MagickCore::Image *outPutimageInfo = MagickCore::AutoOrientImage(imageInfo, MagickCore::LeftBottomOrientation, MagickCore::AcquireExceptionInfo());

   size_t outputSize;
   const void *outputData = MagickCore::ImageToBlob(MagickCore::AcquireImageInfo(), outPutimageInfo, &outputSize, MagickCore::AcquireExceptionInfo());

   NSData *resData = [[NSData alloc] initWithBytes:outputData length:outputSize];

   [resData writeToFile:@"/Users/jason/Desktop/magic/res" atomically:YES];
    
    return nil;
}

@end
