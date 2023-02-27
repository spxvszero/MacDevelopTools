//
//  JKDragableTableView.m
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/2/26.
//  Copyright © 2023 JK. All rights reserved.
//

#import "JKDragableTableView.h"

@interface JKDragableTableView ()

@property (nonatomic, strong) NSView *lineView;

@end

@implementation JKDragableTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSDraggingSession *)beginDraggingSessionWithItems:(NSArray<NSDraggingItem *> *)items event:(NSEvent *)event source:(id<NSDraggingSource>)source
{
//    NSLog(@"tableview drag session -- %@ %@ %@",items,event,source);
    
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

- (void)filterWithRowHeight:(NSPoint)point row:(NSInteger)row
{
    if (row < 0) {
        return;
    }
    
    NSInteger actualRow = row;
    
    NSRect curRowFrame = [[self rowViewAtRow:row makeIfNecessary:true] frame];
    
    CGFloat offset = (point.y - curRowFrame.origin.y) - 0.5 * curRowFrame.size.height;
    CGFloat y = 0;
    if (offset > 0) {
        y = curRowFrame.origin.y + curRowFrame.size.height;
    }else{
        y = curRowFrame.origin.y;
        actualRow -= 1;
    }
    if ((actualRow + 1) == self.numberOfRows) {
        y -= 2;
    }
    self.lineView.hidden = false;
    self.lineView.frame = NSMakeRect(0, y, self.bounds.size.width, 2);
    
    if (self.DragUpdateRowBlock) {
        self.DragUpdateRowBlock(MAX(actualRow, 0));
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
