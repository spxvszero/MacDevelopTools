//
//  JKDragableTableView.h
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/2/26.
//  Copyright © 2023 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKDragableTableView : NSTableView

@property (nonatomic, strong) void (^DragUpdateRowBlock)(NSInteger targetRow);
@property (nonatomic, strong) void (^NeedUpdateScrollViewBlock)(BOOL up);


//not support yet
@property (nonatomic, assign) BOOL enableCombine;
@property (nonatomic, strong) void (^CombineRowsBlock)(NSInteger targetRow);


- (void)endDragging;

@end

NS_ASSUME_NONNULL_END
