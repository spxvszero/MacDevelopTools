//
//  NSButton+JKRightAction.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/18.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "NSButton+JKRightAction.h"
#import <objc/runtime.h>

@implementation NSButton (JKRightAction)

@dynamic rightClickTarget;
@dynamic rightClickAction;

- (void)setRightClickAction:(SEL)rightClickAction
{
    objc_setAssociatedObject(self, @selector(rightClickAction), NSStringFromSelector(rightClickAction), OBJC_ASSOCIATION_RETAIN);
}

- (SEL)rightClickAction
{
    NSString *selName = objc_getAssociatedObject(self, @selector(rightClickAction));
    return NSSelectorFromString(selName);
}

- (void)setRightClickTarget:(id)rightClickTarget
{
    objc_setAssociatedObject(self, @selector(rightClickTarget), rightClickTarget, OBJC_ASSOCIATION_ASSIGN);
}

- (id)rightClickTarget
{
    return objc_getAssociatedObject(self, @selector(rightClickTarget));
}

@end


@implementation NSStatusBarButton (JK)

- (void)rightMouseDown:(NSEvent *)event
{
    NSLog(@"right mouse down");
    NSEvent *newEvent = event;
    BOOL mouseInBounds = NO;
    
    while (YES)
    {
        mouseInBounds = NSPointInRect([newEvent locationInWindow], [self convertRect:[self frame] fromView:nil]);
        [self highlight:NO];
        
        newEvent = [[self window] nextEventMatchingMask:NSEventMaskRightMouseDragged | NSEventMaskRightMouseUp];
        
        if (NSEventTypeRightMouseUp == [newEvent type])
        {
            break;
        }
    }
    if (mouseInBounds)
    {
        [self rightMouseAction];
    }
}

- (void)rightMouseAction
{
    if (self.rightClickTarget && [self.rightClickTarget respondsToSelector:self.rightClickAction]) {
        [self.rightClickTarget performSelector:self.rightClickAction withObject:nil];
    }
}
@end

