//
//  JKSVGADragBoxView.h
//  MacDevelopTools
//
//  Created by jk on 2022/2/22.
//  Copyright © 2022 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKSVGADragBoxView : NSView

@property (nonatomic, strong) void (^OpenSVGAObjectBlock)(NSString *svgaPath);
@property (nonatomic, strong) void (^MouseActionBlock)(BOOL isEnter);

-(void)openAnimationURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
