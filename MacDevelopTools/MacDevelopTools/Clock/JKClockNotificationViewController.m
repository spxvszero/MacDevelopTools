//
//  JKClockNotificationViewController.m
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/3/11.
//  Copyright © 2023 JK. All rights reserved.
//

#import "JKClockNotificationViewController.h"

@interface JKClockNotificationViewController ()
@property (weak) IBOutlet NSTextField *minutesInputTxtField;
@property (weak) IBOutlet NSTextField *contentTxtField;

@end

@implementation JKClockNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (IBAction)closeBtnAction:(id)sender
{
    if (self.CloseActionBlock) {
        self.CloseActionBlock();
    }
}
- (IBAction)remindMeLaterBtnAction:(id)sender
{
    if (self.RemindMeLaterActionBlock) {
        self.RemindMeLaterActionBlock(self, [self.minutesInputTxtField.stringValue integerValue]);
    }
    [self closeBtnAction:nil];
}


- (void)setModel:(JKClockScheduleModel *)model
{
    _model = model;
    
    if (!self.contentTxtField) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contentTxtField.stringValue = self.model.textAlert;
        });
    }else{
         self.contentTxtField.stringValue = model.textAlert;
    }
}
@end
