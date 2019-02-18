//
//  JKJSONFormatHistoryViewController.h
//  MacDevelopTools
//
//  Created by 曾坚 on 2019/2/18.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKBaseViewController.h"

@interface JKJSONFormatHistoryViewController : JKBaseViewController

@property (nonatomic, strong) void (^SelectStrBlock)(JKJSONFormatHistoryViewController *vc ,NSString *historyStr);

- (void)addHistory:(NSString *)jsonStr;

- (void)reloadData;

@end
