//
//  JKMeunPanelViewController.m
//  MacDevelopTools
//
//  Created by 曾坚 on 2018/12/13.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKMeunPanelViewController.h"

@interface JKMeunPanelViewController ()

@end

@implementation JKMeunPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


+ (JKMeunPanelViewController *)fromStoryBoard
{
    NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSViewController *vc = [sb instantiateControllerWithIdentifier:NSStringFromClass([JKMeunPanelViewController class])];
    return vc;
}

@end
