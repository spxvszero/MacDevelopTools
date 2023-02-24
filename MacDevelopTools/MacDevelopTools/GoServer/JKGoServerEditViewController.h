//
//  JKGoServerEditViewController.h
//  MacDevelopTools
//
//  Created by jk on 2022/5/25.
//  Copyright © 2022 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JKGoServerDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKGoServerEditViewController : NSViewController

@property(nonatomic, strong) JKGoServerDataModel *serverModel;
@property(nonatomic, strong) void(^FinishUpdatedWithResultBlock)(JKGoServerDataModel *serverModel, BOOL isUpdate);

- (void)clearData;

@end

NS_ASSUME_NONNULL_END
