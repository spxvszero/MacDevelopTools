//
//  JKGoServerSaveActionViewController.h
//  MacDevelopTools
//
//  Created by jk on 2022/6/9.
//  Copyright © 2022 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JKGoServerActionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKGoServerSaveActionViewController : NSViewController
	
@property(nonatomic, strong) JKGoServerActionModel *editModel;
@property(nonatomic, strong) void(^SaveActionBlock)(JKGoServerSaveActionViewController *controller, BOOL confirm);

@end

NS_ASSUME_NONNULL_END
