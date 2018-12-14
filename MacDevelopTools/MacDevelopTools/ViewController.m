//
//  ViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/12.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "ViewController.h"
#import "JKApplicationHoldManager.h"
#import "TestObjectClass.h"

@interface ViewController ()

@property (nonatomic, strong) JKApplicationHoldManager *manager;

@end

@implementation ViewController

- (void)dealloc
{
    NSLog(@"viewController dealloc");
}
- (IBAction)pushBtnAction:(NSButton *)sender
{
    [self.manager addObject:[TestObjectClass new]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewController did load");
    // Do any additional setup after loading the view.
    self.manager = [[JKApplicationHoldManager alloc] init];
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
