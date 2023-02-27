//
//  JKDragableOutlineView.h
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/2/26.
//  Copyright © 2023 JK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    JKDragableRowPositionTop,
    JKDragableRowPositionBottom,
    JKDragableRowPositionCenter,
} JKDragableRowPosition;

@interface JKDragableOutlineView : NSOutlineView

@property (nonatomic, strong) void (^DragUpdateRowBlock)(NSInteger targetRow, JKDragableRowPosition position);
@property (nonatomic, strong) void (^NeedUpdateScrollViewBlock)(BOOL up);

@property (nonatomic, assign) BOOL enableCombine;

- (void)endDragging;

@end

NS_ASSUME_NONNULL_END
