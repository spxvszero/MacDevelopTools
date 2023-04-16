//
//  JKBaseViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/29.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKBaseViewController.h"

@interface JKBaseViewController ()

@end

@implementation JKBaseViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusItemClose) name:kJKStatusItemPopOverCloseNotification object:nil];
}

- (void)statusItemClose
{
    
}

@end
