//
//  JKLottieDragBoxView.h
//  MacDevelopTools
//
//  Created by jk on 2020/3/31.
//  Copyright © 2020 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKLottieDragBoxView : NSView

@property (nonatomic, strong) void (^OpenJsonLottieObjectBlock)(id jsonObj);
@property (nonatomic, strong) void (^MouseActionBlock)(BOOL isEnter);

-(void)openAnimationURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
