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
#import <objc/runtime.h>

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
    if (self.popOver.isShown) {
        [self closePopOver:self];
    }
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

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            if (strlen(attribute) <= 4) {
                break;
            }
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "@";
}

- (void)myMethod {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([NSStatusBar class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithCString:propName
                                                        encoding:[NSString defaultCStringEncoding]];
            NSString *propertyType = [NSString stringWithCString:propType
                                                        encoding:[NSString defaultCStringEncoding]];
            NSLog(@"propertyName %@ type %@",propertyName,propertyType);
        }
    }
    free(properties);
}

- (void)showPopOver:(id)sender
{
    [self.popOver showRelativeToRect:self.statusBarItem.button.bounds ofView:self.statusBarItem.button preferredEdge:NSRectEdgeMinY];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJKStatusItemPopOverShowNotification object:nil];
}

- (void)closePopOver:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kJKStatusItemPopOverCloseNotification object:nil];
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
