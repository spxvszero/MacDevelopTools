//
//  JKShellManagerCell.m
//  MacDevelopTools
//
//  Created by jacky on 2019/2/20.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKShellManagerCell.h"

@interface JKShellManagerCell ()<NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *nameTxtField;
@property (weak) IBOutlet NSImageView *statusImgView;



@end
@implementation JKShellManagerCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.nameTxtField.delegate = self;
}

- (void)setName:(NSString *)name
{
    _name = name;
    self.nameTxtField.stringValue = name;
}

- (void)setStatus:(BOOL)status
{
    _status = status;
    NSString *statusImgName = @"shell_status_off";
    if (status) {
        statusImgName = @"shell_status_on";
    }
    self.statusImgView.image = [NSImage imageNamed:statusImgName];
}

- (void)setShowStatus:(BOOL)showStatus
{
    _showStatus = showStatus;
    self.statusImgView.hidden = !showStatus;
}


#pragma mark - TxtFieldDelegate

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    if (obj.name == NSControlTextDidEndEditingNotification) {
        if (self.nameTxtField.stringValue == nil || self.nameTxtField.stringValue.length <= 0){
            self.nameTxtField.stringValue = self.name;
        }
        
        if (![self.nameTxtField.stringValue isEqualToString:self.name]) {
            //change
            if (self.NameUpdateBlock) {
                self.NameUpdateBlock(self.nameTxtField.stringValue);
            }
        }
    }
}

@end
