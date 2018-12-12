//
//  JKIconMenu.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/12.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKIconMenu.h"

#define kButtonTag 1999

@implementation JKIconMenu

- (instancetype)initWithTitle:(NSString *)title
{
    if (self = [super initWithTitle:title]) {
        [self setupSubItems];
    }
    return self;
}

- (void)setupSubItems
{
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"you" action:nil keyEquivalent:@""];
    NSView *itemV = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 400, 20)];
    NSButton *btn1 = [self createButton:@"J" tag:kButtonTag];
    btn1.frame = NSMakeRect(0, 0, 20, 20);
    [itemV addSubview:btn1];
    item.view = itemV;
    itemV.layer.backgroundColor = [NSColor colorWithWhite:1 alpha:1].CGColor;
    
    [self addItem:item];
}

- (NSButton *)createButton:(NSString *)title tag:(NSInteger)tag
{
    NSButton *btn = [[NSButton alloc] init];
    [btn setTitle:title];
    btn.tag = tag;
    btn.target = self;
    btn.action = @selector(btnAction:);
    return btn;
}

- (void)btnAction:(NSButton *)button
{
    if (self.MenuClickBlock) {
        self.MenuClickBlock(button.tag - kButtonTag);
    }
}

@end
