//
//  JKCollectionMenuPanelItem.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/14.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKCollectionMenuPanelItem.h"

@interface JKCollectionMenuPanelItem ()

@property (weak) IBOutlet NSImageView *panelImageView;
@property (weak) IBOutlet NSButton *toolTipsButton;

@end

@implementation JKCollectionMenuPanelItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    if (self.selected) {
        self.panelImageView.image = [NSImage imageNamed:@"bug_fill"];
    }else{
        self.panelImageView.image = [NSImage imageNamed:@"bug"];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        self.panelImageView.image = [NSImage imageNamed:@"bug_fill"];
    }else{
        self.panelImageView.image = [NSImage imageNamed:@"bug"];
    }
}

- (void)setToolTips:(NSString *)toolTips
{
    _toolTips = toolTips;
    
    self.toolTipsButton.toolTip = toolTips;
}

@end
