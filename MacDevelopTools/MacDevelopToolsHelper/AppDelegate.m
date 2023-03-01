//
//  AppDelegate.m
//  MacDevelopToolsHelper
//
//  Created by jacky Huang on 2023/3/1.
//  Copyright © 2023 JK. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    //check main app if running
    NSArray *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    BOOL isRunning =  false;
    for (NSRunningApplication *runningApp in runningApps) {
        if ([runningApp.bundleIdentifier isEqualToString:@"com.jacky.ccc.MacDevelopTools"]) {
            isRunning = true;
            break;
        }
    }
    
    if (!isRunning) {
        NSArray *pathComponents = [[[NSBundle mainBundle] bundlePath] pathComponents];
        pathComponents = [pathComponents subarrayWithRange:NSMakeRange(0, [pathComponents count] - 4)];
        NSString *path = [NSString pathWithComponents:pathComponents];
        [[NSWorkspace sharedWorkspace] launchApplication:path];
    }
    
    [NSApp terminate:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
