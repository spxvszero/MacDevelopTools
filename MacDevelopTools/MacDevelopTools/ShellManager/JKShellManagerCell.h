//
//  JKShellManagerCell.h
//  MacDevelopTools
//
//  Created by jacky on 2019/2/20.
//  Copyright © 2019年 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JKShellManagerCell : NSTableCellView

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL status;
@property (nonatomic, assign) BOOL showStatus;

@property (nonatomic, strong) void (^NameUpdateBlock)(NSString *nName);

@end
