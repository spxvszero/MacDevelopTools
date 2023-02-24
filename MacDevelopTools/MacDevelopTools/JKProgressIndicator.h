//
//  JKProgressIndicator.h
//  MacDevelopTools
//
//  Created by jk on 2022/1/7.
//  Copyright © 2022 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKProgressIndicator : NSProgressIndicator

- (void)startLoading;
- (void)stopLoading;

@end

NS_ASSUME_NONNULL_END
