//
//  JKAboutViewController.m
//  MacDevelopTools
//
//  Created by jk on 2020/3/23.
//  Copyright © 2020 JK. All rights reserved.
//

#import "JKAboutViewController.h"

@interface JKAboutViewController ()
@property (weak) IBOutlet NSTextField *aboutTxtField;

@end

@implementation JKAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.aboutTxtField.stringValue = @"此作者很懒，不知道说明什么\n开源地址：https://github.com/spxvszero/MacDevelopTools\n欢迎提出意见和反馈～～~\(≧▽≦)/~\n邮箱：jkp.issue@gmail.com";
}

@end
