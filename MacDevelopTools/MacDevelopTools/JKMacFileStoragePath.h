//
//  JKMacFileStoragePath.h
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/2/28.
//  Copyright © 2023 JK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKMacFileStoragePath : NSObject

+ (NSString *)rootDirPath;

+ (NSString *)goServerDataDirPath;

+ (NSString *)shellManagerDataDirPath;

@end

