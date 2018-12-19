//
//  AppDelegate.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/12.
//  Copyright © 2018年 JK. All rights reserved.
//

static float const     kStatusBarIconPadding = 0.25;

#import "AppDelegate.h"
#import "JKIconMenu.h"
#import "JKApplicationHoldManager.h"
#import "JKMeunPanelViewController.h"
#import "NSButton+JKRightAction.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSMenu *fileMenu;

@property (nonatomic, strong) JKApplicationHoldManager *holdManager;

//@property (nonatomic, strong) JKIconMenu *iconMenu;

@property (nonatomic, strong) NSMenu *rightMenu;
@property (nonatomic, strong) NSStatusItem *statusBarItem;

@property (nonatomic, strong) NSPopover *popOver;

@end

@implementation AppDelegate

- (void) initStatusBarItem {
    
    self.statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    
    self.statusBarItem.title = [NSRunningApplication currentApplication].localizedName;
    self.statusBarItem.toolTip = self.statusBarItem.title;
    
    self.statusBarItem.button.accessibilityLabel = self.statusBarItem.title;
    
    // Set the icon
    NSImage* icon = [NSImage imageNamed:@"icon"];
    
    if (icon != nil) {
        NSRect statusBarItemFrame;
        statusBarItemFrame = self.statusBarItem.button.frame;
        
        CGFloat lengthMinusPadding = statusBarItemFrame.size.height * (1 - kStatusBarIconPadding);
        [icon setSize:NSMakeSize(lengthMinusPadding, lengthMinusPadding)];
        
        [icon setTemplate:YES];
        
        self.statusBarItem.button.image = icon;
    }else{
        self.statusBarItem.button.title = @"";
    }
    
//    self.iconMenu = [[JKIconMenu alloc] initWithTitle:@"hi"];
//    __weak typeof(self) weakSelf = self;
//    self.iconMenu.MenuClickBlock = ^(NSInteger index) {
//
//        NSWindowController *windowController;
//        if ([weakSelf.holdManager hasObjectClass:@"PushViewController"]) {
//            NSViewController *pushVC = [weakSelf.holdManager getAnyObjWithClass:@"PushViewController"];
//            windowController = [[NSWindowController alloc] initWithWindow:[NSApplication sharedApplication].keyWindow];
//            windowController.contentViewController = pushVC;
//            NSLog(@"reload pushVC");
//        }else{
//            NSStoryboard *sb = [NSStoryboard storyboardWithName:@"SmartPush" bundle:nil];
//            windowController = [sb instantiateInitialController];
//            [weakSelf.holdManager addObject:windowController.contentViewController];
//        }
//        [windowController showWindow:weakSelf];
//    };
    // Set the main menu
//    self.statusBarItem.menu = self.iconMenu;
    
    
//    self.statusBarItem.button.menu = self.iconMenu;
    self.statusBarItem.button.action = @selector(popOverAction:);
    self.statusBarItem.button.rightClickTarget = self;
    self.statusBarItem.button.rightClickAction = @selector(popUpMenu);
}

- (void)popUpMenu
{
    [self.statusBarItem popUpStatusItemMenu:self.rightMenu];
}

- (void)popOverAction:(id)sender
{
    if (self.popOver.isShown) {
        [self closePopOver:sender];
    }else{
        [self showPopOver:sender];
    }
}

- (void)showPopOver:(id)sender
{
    [self.popOver showRelativeToRect:self.statusBarItem.button.bounds ofView:self.statusBarItem.button preferredEdge:NSRectEdgeMinY];
}

- (void)closePopOver:(id)sender
{
    [self.popOver performClose:sender];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.holdManager = [[JKApplicationHoldManager alloc] init];
    [self initStatusBarItem];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)quitApp
{
    [NSApp terminate:self];
}

#pragma mark - getter

- (NSMenu *)rightMenu
{
    if (!_rightMenu) {
        _rightMenu = [[NSMenu alloc] init];
        
        //quit Item
        NSMenuItem *quitItem = [[NSMenuItem alloc] init];
        quitItem.action = @selector(quitApp);
        quitItem.target = self;
        quitItem.title = @"Quit";
        
        [_rightMenu addItem:quitItem];
    }
    return _rightMenu;
}

- (NSPopover *)popOver
{
    if (!_popOver) {
        _popOver = [[NSPopover alloc] init];
        JKMeunPanelViewController *menuVC = [JKMeunPanelViewController fromStoryBoard];
        __weak typeof(self) weakSelf = self;
        menuVC.MeunSizeChangeBlock = ^(NSSize size) {
            weakSelf.popOver.contentSize = size;
        };
        _popOver.contentViewController = menuVC;
    }
    return _popOver;
}

@end
