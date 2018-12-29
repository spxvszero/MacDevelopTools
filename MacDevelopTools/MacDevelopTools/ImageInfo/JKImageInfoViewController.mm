//
//  JKImageInfoViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/29.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKImageInfoViewController.h"
#import "JKImageInfoInspectorViewController.h"

@interface JKImageInfoViewController ()

@property (weak) IBOutlet NSImageView *imageView;

@property (weak) IBOutlet NSButton *expandButton;

@property (weak) IBOutlet NSView *containView;

@property (nonatomic, strong) JKImageInfoInspectorViewController *inspectorViewController;

@end

@implementation JKImageInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.containView addSubview:self.inspectorViewController.view];
}


- (IBAction)expandButtonAction:(NSButton *)sender
{
    [self.inspectorViewController reloadData];
}


- (JKImageInfoInspectorViewController *)inspectorViewController
{
    if (!_inspectorViewController) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"ImageInfo" bundle:nil];
        _inspectorViewController = [sb instantiateControllerWithIdentifier:@"JKImageInfoInspectorViewController"];
    }
    return _inspectorViewController;
}

@end
