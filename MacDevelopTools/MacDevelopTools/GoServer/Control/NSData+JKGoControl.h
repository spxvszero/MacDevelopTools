//
//  NSData+JKGoControl.h
//  jkgocontrol
//
//  Created by jk on 2022/5/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (JKGoControl)

+ (NSData *)capData:(NSData *)srcData withLength:(NSInteger)length;

@end

NS_ASSUME_NONNULL_END
