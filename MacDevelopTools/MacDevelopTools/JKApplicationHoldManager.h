//
//  JKApplicationHoldManager.h
//  MacDevelopTools
//
//  Created by 曾坚 on 2018/12/13.
//  Copyright © 2018年 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKApplicationHoldManager : NSObject

- (void)addObject:(id)obj;
- (BOOL)hasObject:(id)obj;
- (BOOL)hasObjectClass:(NSString *)className;
- (id)getAnyObjWithClass:(NSString *)className;

@end
