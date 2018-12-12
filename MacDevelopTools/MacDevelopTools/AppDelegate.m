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

@interface AppDelegate ()
@property (weak) IBOutlet NSMenu *fileMenu;

@property (nonatomic, strong) JKIconMenu *iconMenu;

@property (nonatomic, strong) NSStatusItem *statusBarItem;

@end

@implementation AppDelegate

- (void) initStatusBarItem {
    
    self.statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    // NSStatusItem doesn't have the "button" property on OS X 10.9.
    BOOL buttonAvailable = (floor(NSAppKitVersionNumber) >= NSAppKitVersionNumber10_10);
    
    // Set the title/tooltip to "Background Music".
    self.statusBarItem.title = [NSRunningApplication currentApplication].localizedName;
    self.statusBarItem.toolTip = self.statusBarItem.title;
    
    if (buttonAvailable) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
        self.statusBarItem.button.accessibilityLabel = self.statusBarItem.title;
#pragma clang diagnostic pop
    }
    
    // Set the icon.
    NSImage* icon = [NSImage imageNamed:@"FermataIcon"];
    
    if (icon != nil) {
        NSRect statusBarItemFrame;
        
        if (buttonAvailable) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
            statusBarItemFrame = self.statusBarItem.button.frame;
#pragma clang diagnostic pop
        } else {
            // OS X 10.9 fallback. I haven't tested this (or anything else on 10.9).
            statusBarItemFrame = self.statusBarItem.view.frame;
        }
        
        CGFloat lengthMinusPadding = statusBarItemFrame.size.height * (1 - kStatusBarIconPadding);
        [icon setSize:NSMakeSize(lengthMinusPadding, lengthMinusPadding)];
        
        // Make the icon a "template image" so it gets drawn colour-inverted when it's highlighted or the status
        // bar's in dark mode
        [icon setTemplate:YES];
        
        if (buttonAvailable) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
            self.statusBarItem.button.image = icon;
#pragma clang diagnostic pop
        } else {
            self.statusBarItem.image = icon;
        }
    } else {
        // If our icon is missing for some reason, fallback to a fermata character (1D110)
        if (buttonAvailable) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
            self.statusBarItem.button.title = @"";
#pragma clang diagnostic pop
        } else {
            self.statusBarItem.title = @"";
        }
    }
    
    self.iconMenu = [[JKIconMenu alloc] initWithTitle:@"hi"];
    __weak typeof(self) weakSelf = self;
    self.iconMenu.MenuClickBlock = ^(NSInteger index) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"SmartPush" bundle:nil];
        NSWindowController *windowController = [sb instantiateInitialController];
        [windowController showWindow:weakSelf];
    };
    // Set the main menu
    self.statusBarItem.menu = self.iconMenu;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self initStatusBarItem];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
