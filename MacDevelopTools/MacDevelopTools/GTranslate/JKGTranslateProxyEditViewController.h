//
//  JKGTranslateProxyEditViewController.h
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/4/15.
//  Copyright © 2023 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JKProxyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKGTranslateProxyEditViewController : NSViewController

@property (nonatomic, strong) JKProxyModel *currentProxy;
@property (nonatomic, strong) void (^FinishEditActionBlock)(BOOL ok,  JKProxyModel * _Nullable nPorxy);

@end

NS_ASSUME_NONNULL_END