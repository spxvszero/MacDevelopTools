//
//  JKClockScheduleModel.h
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/3/11.
//  Copyright © 2023 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKClockScheduleModel : NSObject

@property (nonatomic, strong) NSDate *fireDate;
@property (nonatomic, strong) NSString *textAlert;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSUserNotification *notification;

@end

NS_ASSUME_NONNULL_END
