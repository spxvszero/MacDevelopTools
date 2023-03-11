//
//  JKClockNotificationViewController.h
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/3/11.
//  Copyright © 2023 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JKClockScheduleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKClockNotificationViewController : NSViewController

@property (nonatomic, strong) JKClockScheduleModel *model;

@property (nonatomic, strong) void (^RemindMeLaterActionBlock)(JKClockNotificationViewController *vc, NSInteger minutes);
@property (nonatomic, strong) void (^CloseActionBlock)(void);

@end

NS_ASSUME_NONNULL_END
