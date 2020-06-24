//
//  JKLive2dHelper.m
//  MacDevelopTools
//
//  Created by jk on 2020/6/2.
//  Copyright © 2020 JK. All rights reserved.
//

#import "JKLive2dHelper.h"
#include "LAppDelegate.hpp"
#import <AppKit/NSEvent.h>
#import <AppKit/NSScreen.h>

static BOOL live2d_isRunning = false;
static int screen_height = 0;
static id mouseTrackMonitor = nil;

@implementation JKLive2dHelper

+ (void)start
{
    if (LAppDelegate::GetInstance()->Initialize() == GL_FALSE)
    {
        NSLog(@"Failed Start Live2d");
        return;
    }
    
    live2d_isRunning = true;
    [JKLive2dHelper registMouseTracking];
    
    LAppDelegate::GetInstance()->Run();
    
    [JKLive2dHelper unregistMouseTracking];
    live2d_isRunning = false;
    
    NSLog(@"Finish Running");
}

+ (void)stop
{
    LAppDelegate::GetInstance()->AppEnd();
}


+ (BOOL)isRunning
{
    return live2d_isRunning;
}

+ (void)nextScene
{
    LAppDelegate::GetInstance()->NextScene();
}

+ (void)resizeWindowWithWidth:(int)width height:(int)height
{
    LAppDelegate::GetInstance()->SetWindowSize(width, height);
}

+ (void)registMouseTracking
{
    NSRect rec = [[NSScreen mainScreen] frame];
    screen_height = rec.size.height;
    mouseTrackMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskMouseMoved handler:^(NSEvent * _Nonnull evt) {
        if (evt) {
            NSPoint point = evt.locationInWindow;
            if (live2d_isRunning && !LAppDelegate::GetInstance()->GetIsEnd() ) {
                LAppDelegate::GetInstance()->OnMouseMovedCallBack(LAppDelegate::GetInstance()->GetWindow(), point.x, screen_height - point.y);
            }
        }
    }];
}

+ (void)unregistMouseTracking
{
    if (mouseTrackMonitor) {
        [NSEvent removeMonitor:mouseTrackMonitor];
        mouseTrackMonitor = nil;
    }
}

@end
