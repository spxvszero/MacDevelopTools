//
//  JKManageListItemsViewController.m
//  MacDevelopTools
//
//  Created by jk on 2020/3/23.
//  Copyright © 2020 JK. All rights reserved.
//

#import "JKManageListItemsViewController.h"
#import "JKItemsManager.h"

@interface JKManageListItemCell : NSTableCellView

@property (weak) IBOutlet NSButton *checkBtn;
@property (nonatomic, strong) void (^ChangeCheckStateBlock)(JKManageListItemCell *innerCell, BOOL on);
@property (nonatomic, assign) NSInteger curRow;

@property (nonatomic, assign) BOOL isDragging;

@end
@implementation JKManageListItemCell

- (void)setObjectValue:(JKItemsObject *)objectValue
{
    self.checkBtn.title = objectValue.toolTip;
    self.checkBtn.state = objectValue.visable?NSControlStateValueOn:NSControlStateValueOff;
}

- (IBAction)checkBtnClickAction:(NSButton *)sender
{
    if (self.ChangeCheckStateBlock) {
        self.ChangeCheckStateBlock(self,sender.state == NSControlStateValueOn);
    }
}

- (void)setIsDragging:(BOOL)isDragging
{
    _isDragging = isDragging;
    
    if (isDragging) {
        self.checkBtn.hidden = YES;
        self.layer.backgroundColor = [NSColor blueColor].CGColor;
    }else{
        self.checkBtn.hidden = false;
        self.layer.backgroundColor = [NSColor whiteColor].CGColor;
    }
}

- (NSDraggingSession *)beginDraggingSessionWithItems:(NSArray<NSDraggingItem *> *)items event:(NSEvent *)event source:(id<NSDraggingSource>)source
{
    NSLog(@"drag session -- %@ %@ %@",items,event,source);
    return [super beginDraggingSessionWithItems:items event:event source:source];
}


@end


@interface JKManageListItemTableView : NSTableView

@property (nonatomic, strong) void (^DragUpdateRowBlock)(NSInteger row);
@property (nonatomic, strong) NSView *lineView;

@end
@implementation JKManageListItemTableView

- (NSDraggingSession *)beginDraggingSessionWithItems:(NSArray<NSDraggingItem *> *)items event:(NSEvent *)event source:(id<NSDraggingSource>)source
{
//    NSLog(@"tableview drag session -- %@ %@ %@",items,event,source);
    
    NSDraggingItem *item = items.firstObject;;
    item.draggingFrame = NSMakeRect(item.draggingFrame.origin.x, item.draggingFrame.origin.y+item.draggingFrame.size.height, item.draggingFrame.size.width, item.draggingFrame.size.height);
    
    return [super beginDraggingSessionWithItems:items event:event source:source];
}

- (void)draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)screenPoint
{
    NSPoint convertP = [self convertPoint:[self.window convertPointFromScreen:screenPoint] fromView:nil];
    NSInteger row = [self rowAtPoint:convertP];
    [self filterWithRowHeight:convertP row:row];
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
    self.lineView.hidden = false;
    self.lineView.frame = NSMakeRect(0, y, self.bounds.size.width, 1);
    
    if (self.DragUpdateRowBlock) {
        self.DragUpdateRowBlock(actualRow);
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
        [self addSubview:_lineView];
    }
    return _lineView;
}

@end



@interface JKManageListItemsViewController ()<NSTableViewDataSource,NSTableViewDelegate>
@property (weak) IBOutlet JKManageListItemTableView *tableview;

@property (nonatomic, assign) NSInteger beginRow;
@property (nonatomic, assign) NSInteger tempAimRow;


@end

@implementation JKManageListItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleGap;
    [self.tableview setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    __weak typeof(self) weakSelf = self;
    self.tableview.DragUpdateRowBlock = ^(NSInteger row) {
        weakSelf.tempAimRow = row;
    };
    
}

#pragma mark - table delegate

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
    JKItemsObject *itemObj = [[[JKItemsManager defaultManager] obtainItemsList] objectAtIndex:row];
    return itemObj.toolTip;
}


- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes
{
    self.beginRow = rowIndexes.firstIndex;
    self.tempAimRow = self.beginRow;
}

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
    if (self.tempAimRow < self.beginRow) {
        self.tempAimRow += 1;
    }
    if (self.tempAimRow == self.beginRow) {
        return;
    }
    
    NSMutableArray *dataArr = [[JKItemsManager defaultManager] obtainItemsList];
    id obj = [dataArr objectAtIndex:self.beginRow];
    [dataArr removeObjectAtIndex:self.beginRow];
    [dataArr insertObject:obj atIndex:self.tempAimRow];
    
    [self.tableview moveRowAtIndex:self.beginRow toIndex:self.tempAimRow];
    
    [self.tableview endDragging];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJKStatusItemListChangeNotification object:nil];
}

#pragma mark - data delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [JKItemsManager defaultManager].obtainItemsList.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    JKManageListItemCell *cell = [tableView makeViewWithIdentifier:@"JKManageListItemCell" owner:self];
    __weak typeof(self) weakSelf = self;
    cell.ChangeCheckStateBlock = ^(JKManageListItemCell *innerCell, BOOL on) {
        NSInteger row = [weakSelf.tableview rowForView:innerCell];
        JKItemsObject *obj = [[[JKItemsManager defaultManager] obtainItemsList] objectAtIndex:row];
        obj.visable = on;
        [[NSNotificationCenter defaultCenter] postNotificationName:kJKStatusItemListChangeNotification object:nil];
    };
    return cell;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    JKItemsObject *itemObj = [[[JKItemsManager defaultManager] obtainItemsList] objectAtIndex:row];
    
    return itemObj;
}


@end
