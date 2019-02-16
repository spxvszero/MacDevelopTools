//
//  JKAutoPackViewController.m
//  MacDevelopTools
//
//  Created by 曾坚 on 2019/2/15.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKAutoPackViewController.h"

@interface JKAutoPackViewController ()
@property (weak) IBOutlet NSButton *ipaBtn;
@property (weak) IBOutlet NSButton *frameworkBtn;
@property (weak) IBOutlet NSButton *debugBtn;
@property (weak) IBOutlet NSButton *releaseBtn;

@property (weak) IBOutlet NSTextField *projectDirTextField;
@property (weak) IBOutlet NSButton *selectDirBtn;
@property (weak) IBOutlet NSComboBox *schemeTargetBox;
@property (weak) IBOutlet NSTextField *optionsPlistTextField;
@property (weak) IBOutlet NSButton *optionsPlistChooseBtn;

@property (weak) IBOutlet NSButton *buildBtn;


@property (nonatomic, strong) NSOpenPanel *openPanel;
@property (nonatomic, strong) NSMutableArray *comboxArr;
@property (weak) IBOutlet NSProgressIndicator *progressIcon;

@end

@implementation JKAutoPackViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.comboxArr = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusItemClose) name:kJKStatusItemPopOverCloseNotification object:nil];
}

- (void)statusItemClose
{
    [self.openPanel cancel:nil];
}

- (IBAction)packTypeAction:(id)sender
{
    if (self.frameworkBtn.state == NSControlStateValueOn) {
        
        self.optionsPlistChooseBtn.enabled = NO;
        self.optionsPlistTextField.enabled = NO;
        
    }else{
        
        self.optionsPlistChooseBtn.enabled = YES;
        self.optionsPlistTextField.enabled = YES;
    }
}



- (IBAction)complieTypeAction:(id)sender {
}


- (IBAction)projectDirSelectAction:(id)sender
{
    
    if (self.openPanel.visible) {
        return;
    }
    
    self.openPanel.canChooseFiles = NO;
    self.openPanel.canChooseDirectories = YES;
    
    __weak typeof(self) weakSelf = self;
    [self.openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            weakSelf.projectDirTextField.stringValue = weakSelf.openPanel.URL.relativePath;
            [weakSelf readTargets:weakSelf.openPanel.URL.relativePath];
        }
    }];
}

- (void)readTargets:(NSString *)dirPath
{
    [self.comboxArr removeAllObjects];
    [self resetSchemeBox];
    
    NSArray *contentsPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    
    NSString *projectPath = nil;
    for (NSString *subPath in contentsPaths) {
        if ([subPath hasSuffix:@".xcodeproj"]) {
            projectPath = subPath;
            break;
        }
    }
    
    if (!projectPath) {
        return;
    }
    
    NSString *configPath = [[dirPath stringByAppendingPathComponent:projectPath] stringByAppendingPathComponent:@"project.pbxproj"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
        return;
    }
    
    NSString *configStr = [[NSString alloc] initWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:nil];
    
    
//    NSArray *result = [[NSRegularExpression regularExpressionWithPattern:@"\/\\* Begin PBXProject section \\*\/.*targets = .*\/\\* (\\w+) \\*\/.*\/\\* End PBXProject section \\*\/" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:configStr options:0 range:NSMakeRange(0, configStr.length)];
    NSArray *result = [[NSRegularExpression regularExpressionWithPattern:@"\/\\* Begin PBXProject section \\*\/.*targets = \((.*)\);.*\/\\* End PBXProject section \\*\/" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:configStr options:0 range:NSMakeRange(0, configStr.length)];
    
    for (NSTextCheckingResult *match in result ) {
        NSRange range = [match rangeAtIndex:1];
//        捕获则是用[match rangeAtIndex:1];
        NSString *mStr = [configStr substringWithRange:range];
        
        NSArray *secResult = [[NSRegularExpression regularExpressionWithPattern:@"\/\\* (\\w+) \\*\/" options:NSRegularExpressionCaseInsensitive error:nil] matchesInString:mStr options:0 range:NSMakeRange(0, mStr.length)];
        
        for (NSTextCheckingResult *secMatch in secResult ) {
            NSRange secRange = [secMatch rangeAtIndex:1];
            //        捕获则是用[match rangeAtIndex:1];
            NSString *secStr = [mStr substringWithRange:secRange];
            
            [self.comboxArr addObject:secStr];
            NSLog(@"regular : %@", secStr);
        }
    }
    if (self.comboxArr.count <= 0) {
    }else{
        [self.schemeTargetBox addItemsWithObjectValues:self.comboxArr];
    }
}

- (void)resetSchemeBox
{
    [self.schemeTargetBox removeAllItems];
    self.schemeTargetBox.stringValue = @"";
}

- (NSOpenPanel *)openPanel
{
    if (!_openPanel) {
        _openPanel = [NSOpenPanel openPanel];
        _openPanel.showsHiddenFiles = YES;
        _openPanel.canCreateDirectories = YES;
        _openPanel.showsResizeIndicator = YES;
    }
    return _openPanel;
}


- (IBAction)optionsPlistSelectAction:(id)sender
{
    if (self.openPanel.visible) {
        return;
    }
    
    self.openPanel.canChooseFiles = YES;
    self.openPanel.canChooseDirectories = NO;
    
    __weak typeof(self) weakSelf = self;
    [self.openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            weakSelf.optionsPlistTextField.stringValue = weakSelf.openPanel.URL.relativePath;
        }
    }];
}

- (IBAction)buildAction:(id)sender {
    
    if (!self.progressIcon.hidden) {
        NSLog(@"progress is running,please wait until finished");
        return;
    }
    
    NSString *projectPath = self.projectDirTextField.stringValue;
    if (![[NSFileManager defaultManager] fileExistsAtPath:projectPath]) {
        NSLog(@"project file not found");
        return;
    }
    
    if (self.schemeTargetBox.stringValue && self.schemeTargetBox.stringValue.length > 0 && [self.comboxArr containsObject:self.schemeTargetBox.stringValue]) {}else{
        NSLog(@"scheme target not exist");
        return;
    }
    
    if (self.ipaBtn.state == NSControlStateValueOn) {
        if (!self.optionsPlistTextField.stringValue || self.optionsPlistTextField.stringValue.length <= 0 || ![[NSFileManager defaultManager] fileExistsAtPath:self.optionsPlistTextField.stringValue]) {
            NSLog(@"archieve info plist does not exist");
            return;
        }
    }
    
    if (self.openPanel.visible) {
        return;
    }
    
    self.openPanel.canChooseFiles = NO;
    self.openPanel.canChooseDirectories = YES;
    
    __weak typeof(self) weakSelf = self;
    [self.openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            [weakSelf buildToPath:weakSelf.openPanel.URL.relativePath];
        }
    }];
}

- (void)buildToPath:(NSString *)pathDir
{
    NSArray *contentsPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.projectDirTextField.stringValue error:nil];
    
    NSString *workspace = nil;
    for (NSString *subPath in contentsPaths) {
        if ([subPath hasSuffix:@".xcworkspace"]) {
            workspace = subPath;
            break;
        }
    }
    
    NSString *cmdFile = [[NSBundle mainBundle] pathForResource:@"projectPackage" ofType:@"sh"];
    
    NSString *cmd = [NSString stringWithFormat:@"sh %@ %@ -o %@ -p %@ -s %@ -w %@ %@",
                     cmdFile,
                     self.debugBtn.state == NSControlStateValueOn ?@"-d":@"-r",
                     pathDir,
                     self.projectDirTextField.stringValue,
                     self.schemeTargetBox.stringValue,
                     workspace,
                     self.ipaBtn.state == NSControlStateValueOn ?[NSString stringWithFormat:@"-i %@",self.optionsPlistTextField.stringValue]:@"-f"
                     ];
    
    self.progressIcon.hidden = NO;
    self.buildBtn.enabled = NO;
    [self.progressIcon startAnimation:nil];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.progressIcon stopAnimation:nil];
            weakSelf.progressIcon.hidden = YES;
            weakSelf.buildBtn.enabled = YES;
        });
    });
}

@end
