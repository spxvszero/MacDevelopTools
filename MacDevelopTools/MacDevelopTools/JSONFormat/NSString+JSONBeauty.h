//
//  NSString+JSONBeauty.h
//  MacDevelopTools
//
//  Created by jk on 2022/5/27.
//  Copyright © 2022 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (JSONBeauty)

- (NSString *)beautyJSON;
- (NSString *)unBeautyJSON;

@end

NS_ASSUME_NONNULL_END
