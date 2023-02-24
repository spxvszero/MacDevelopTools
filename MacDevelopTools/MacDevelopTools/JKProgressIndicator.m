//
//  JKProgressIndicator.m
//  MacDevelopTools
//
//  Created by jk on 2022/1/7.
//  Copyright © 2022 JK. All rights reserved.
//

#import "JKProgressIndicator.h"

@implementation JKProgressIndicator

- (void)startLoading
{
    [self startAnimation:nil];
    self.hidden = false;
}

- (void)stopLoading
{
    [self stopAnimation:nil];
    self.hidden = true;
}

@end
