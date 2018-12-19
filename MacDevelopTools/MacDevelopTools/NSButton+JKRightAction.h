//
//  NSButton+JKRightAction.h
//  MacDevelopTools
//
//  Created by 曾坚 on 2018/12/18.
//  Copyright © 2018年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSButton (JKRightAction)

@property (nonatomic, weak) id rightClickTarget;
@property (nonatomic) SEL rightClickAction;

@end
