//
//  JKDragableOutlineView.m
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/2/26.
//  Copyright © 2023 JK. All rights reserved.
//

#import "JKDragableOutlineView.h"

@interface JKDragableOutlineView ()

@property (nonatomic, strong) NSView *lineView;

@end
@implementation JKDragableOutlineView

- (NSDraggingSession *)beginDraggingSessionWithItems:(NSArray<NSDraggingItem *> *)items event:(NSEvent *)event source:(id<NSDraggingSource>)source
{
    NSDraggingItem *item = items.firstObject;;
    item.draggingFrame = NSMakeRect(item.draggingFrame.origin.x, item.draggingFrame.origin.y+item.draggingFrame.size.height, item.draggingFrame.size.width, item.draggingFrame.size.height);
    
    return [super beginDraggingSessionWithItems:items event:event source:source];
}

- (void)draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)screenPoint
{
    NSPoint windowP = [self.window convertPointFromScreen:screenPoint];
    NSPoint convertP = [self convertPoint:windowP fromView:nil];
    NSInteger row = [self rowAtPoint:convertP];
    [self filterWithRowHeight:convertP row:row];
    [self scrollFitting:windowP.y];
}

//- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
//{
//    NSPoint windowP = [self.window convertPointFromScreen:screenPoint];
//    NSPoint convertP = [self convertPoint:windowP fromView:nil];
//    NSInteger row = [self rowAtPoint:convertP];
//    [self filterWithRowHeight:convertP row:row];
//}

- (void)filterWithRowHeight:(NSPoint)point row:(NSInteger)row
{
    if (row < 0) {
        return;
    }
    
    NSInteger actualRow = row;
    
    NSRect curRowFrame = [[self rowViewAtRow:row makeIfNecessary:true] frame];
    
    CGFloat offset = (point.y - curRowFrame.origin.y) - 0.5 * curRowFrame.size.height;
    CGFloat y = 0;
    
    if (self.enableCombine) {
        CGFloat combineOffset = ABS(offset) - 0.25 * curRowFrame.size.height;
        if (combineOffset < 0) {
            self.lineView.hidden = false;
            self.lineView.alphaValue = 0.35;
            self.lineView.frame = NSMakeRect(0, curRowFrame.origin.y, self.bounds.size.width, curRowFrame.size.height);
            
            if (self.DragUpdateRowBlock) {
                self.DragUpdateRowBlock(actualRow, JKDragableRowPositionCenter);
            }
            return;
        }
    }
    
    JKDragableRowPosition position = JKDragableRowPositionBottom;
    if (offset > 0) {
        y = curRowFrame.origin.y + curRowFrame.size.height;
        position = JKDragableRowPositionTop;
        actualRow += 1;
    }else{
        y = curRowFrame.origin.y;
    }
    if ((actualRow + 1) == self.numberOfRows) {
        y -= 2;
    }
    self.lineView.hidden = false;
    self.lineView.alphaValue = 1;
    self.lineView.frame = NSMakeRect(0, y, self.bounds.size.width, 2);
    
    if (self.DragUpdateRowBlock) {
        self.DragUpdateRowBlock(actualRow, position);
    }
}

- (void)scrollFitting:(CGFloat)y
{
    
    if (y < 0) {
        //scroll bottom
        if (self.NeedUpdateScrollViewBlock) {
            self.NeedUpdateScrollViewBlock(false);
        }
    }
    
    CGFloat frameHeight = self.superview.frame.size.height;
    if (y > frameHeight) {
        //scroll top
        if (self.NeedUpdateScrollViewBlock) {
            self.NeedUpdateScrollViewBlock(true);
        }
    }
}


- (void)endDragging
{
    self.lineView.hidden = YES;
}


- (NSView *)lineView
{
    if (!_lineView) {
        _lineView = [[NSView alloc] init];
        _lineView.wantsLayer = YES;
        _lineView.layer.backgroundColor = [NSColor blueColor].CGColor;
        _lineView.layer.zPosition = 1;
        [self addSubview:_lineView];
    }
    return _lineView;
}

@end
