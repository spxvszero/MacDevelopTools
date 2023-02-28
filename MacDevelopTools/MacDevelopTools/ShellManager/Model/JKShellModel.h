//
//  JKShellModel.h
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/2/26.
//  Copyright © 2023 JK. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKShellModel : NSObject<NSCoding, NSSecureCoding>

@property (nonatomic, assign) NSInteger shellId;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) void (^UpdateStringBlock)(NSString *contentStr);

+ (instancetype)modelWithName:(NSString *)name;

//cmd
- (void)startShell;
- (void)closeShell;
- (BOOL)isRunning;

- (void)writeString:(NSString *)str;
- (void)updateStorageStrToTxtView;

@end

NS_ASSUME_NONNULL_END
