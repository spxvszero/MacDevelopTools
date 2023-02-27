//
//  JKShellManagerCell.m
//  MacDevelopTools
//
//  Created by jacky on 2019/2/20.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKShellManagerCell.h"

@interface JKShellManagerCell ()

@property (weak) IBOutlet NSTextField *nameTxtField;
@property (weak) IBOutlet NSImageView *statusImgView;



@end
@implementation JKShellManagerCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setName:(NSString *)name
{
    _name = name;
    self.nameTxtField.stringValue = name;
}

@end
