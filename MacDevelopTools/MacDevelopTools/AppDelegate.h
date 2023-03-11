//
//  AppDelegate.h
//  MacDevelopTools
//
//  Created by jk on 2018/12/12.
//  Copyright © 2018年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (void)buildTestItem;

- (void)closePopOver;

//this NSStatusBarButton using for some view to show their position related to app icon in status bar.
- (id)mainItemViewObject;

@end

