//
//  JKShellManagerViewController.m
//  MacDevelopTools
//
//  Created by jacky on 2019/2/19.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKShellManagerViewController.h"
#import "JKShellManagerCell.h"
#import "JKDragableOutlineView.h"
#import "JKShellManagerViewModel.h"
#include <util.h>
#import <objc/runtime.h>

@interface JKShellManagerViewController ()<NSOutlineViewDelegate,NSOutlineViewDataSource,NSTextViewDelegate>

@property (weak) IBOutlet JKDragableOutlineView *outlineView;
@property (weak) IBOutlet NSButton *addShellBtn;
@property (weak) IBOutlet NSButton *removeShellBtn;

@property (nonatomic, strong) JKShellManagerViewModel *dataViewModel;

@property (weak) IBOutlet NSView *containerView;

@property (nonatomic, weak) NSScrollView *scrollTextView;
@property (nonatomic, weak) NSTextView *textView;
@property (nonatomic, weak) NSTextView *inputTextView;

@property (nonatomic, weak) id beginItem;
@property (nonatomic, assign) NSInteger tempAimRow;
@property (nonatomic, assign) JKDragableRowPosition dragOperate;

@property (nonatomic, weak) JKShellModel *currentRunningModel;

@end

@implementation JKShellManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
//    self.dataViewModel = [self fakeData];
    self.dataViewModel = [JKShellManagerViewModel readFromDisk];
    if (!self.dataViewModel) {
        self.dataViewModel = [[JKShellManagerViewModel alloc] initWithGroup];
    }
    
    
    
    [self.outlineView setAction:@selector(outlineViewClicked:)];
    self.outlineView.enableCombine = true;
    self.outlineView.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleGap;
    __weak typeof(self) weakSelf = self;
    self.outlineView.DragUpdateRowBlock = ^(NSInteger targetRow, JKDragableRowPosition position) {
        weakSelf.tempAimRow = targetRow;
        weakSelf.dragOperate = position;
        NSLog(@"desitination -- %ld",targetRow);
    };
    self.outlineView.NeedUpdateScrollViewBlock = ^(BOOL up){
//        [weakSelf.outlineView scrollPoint:NSMakePoint(0, weakSelf.scrollView.contentView.bounds.origin.y + (up?-1:1))];
        //do not use scrollview.contentview.scrollToPoint
        //this will change the position of clipview but contentOffset
    };
    
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    
    [self setupSubviews];
}

- (void)setupSubviews
{
    CGFloat heightInputView = 30;
    
    NSScrollView *scrollview = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, heightInputView + 5, self.containerView.bounds.size.width, self.containerView.bounds.size.height - heightInputView - 5)];
    self.scrollTextView = scrollview;
    NSSize contentSize = [scrollview contentSize];
     
    [scrollview setBorderType:NSNoBorder];
    [scrollview setHasVerticalScroller:YES];
    [scrollview setHasHorizontalScroller:NO];
    [scrollview setAutoresizingMask:NSViewWidthSizable |
                NSViewHeightSizable];
    
    NSTextView *txtView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
    
    [txtView setMinSize:NSMakeSize(0.0, contentSize.height)];
    [txtView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [txtView setVerticallyResizable:YES];
    [txtView setHorizontallyResizable:NO];
    [txtView setAutoresizingMask:NSViewWidthSizable];
     
    [[txtView textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
    [[txtView textContainer] setWidthTracksTextView:YES];
    
    [scrollview setDocumentView:txtView];

    [[txtView enclosingScrollView] setHasHorizontalScroller:YES];
    [txtView setHorizontallyResizable:YES];
    [txtView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [[txtView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[txtView textContainer] setWidthTracksTextView:NO];
    
    txtView.editable = false;
    　
    [self.containerView addSubview:scrollview];
    self.textView = txtView;
    NSTextView *inputTxtView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, self.containerView.bounds.size.width, heightInputView)];
//    [self.containerView addSubview:inputTxtView];
    
    [self.containerView addSubview:inputTxtView];
    self.inputTextView.backgroundColor = [NSColor lightGrayColor];
    self.inputTextView.drawsBackground = true;
    self.inputTextView = inputTxtView;
    self.inputTextView.delegate = self;
}

- (JKShellManagerViewModel *)fakeData
{
    JKShellManagerViewModel *list = [[JKShellManagerViewModel alloc] initWithGroup];
    [list addModel:[[JKShellManagerViewModel alloc] initWithModel:[JKShellModel modelWithName:@"test1"]] atIndex:0];
    [list addModel:[[JKShellManagerViewModel alloc] initWithModel:[JKShellModel modelWithName:@"test2"]] atIndex:0];
    [list addModel:[[JKShellManagerViewModel alloc] initWithModel:[JKShellModel modelWithName:@"test3"]] atIndex:0];
    [list addModel:[[JKShellManagerViewModel alloc] initWithModel:[JKShellModel modelWithName:@"test4"]] atIndex:0];
    
    JKShellManagerViewModel *list2 = [[JKShellManagerViewModel alloc] initWithGroup];
    [list2 addModel:[[JKShellManagerViewModel alloc] initWithModel:[JKShellModel modelWithName:@"inner1"]] atIndex:0];
    [list2 addModel:[[JKShellManagerViewModel alloc] initWithModel:[JKShellModel modelWithName:@"inner2"]] atIndex:0];
    [list2 addModel:[[JKShellManagerViewModel alloc] initWithModel:[JKShellModel modelWithName:@"inner3"]] atIndex:0];
    [list2 renameGroupName:@"XXX"];
    [list addModel:list2 atIndex:3];
    
    return list;
}

- (void)reloadOutLineView
{
    [self.outlineView reloadData];
}

#pragma mark - Shell Btn Action

- (IBAction)addShellBtnClick:(id)sender {
    [self.dataViewModel addModel:[[JKShellManagerViewModel alloc] initWithModel:[JKShellModel modelWithName:@"Untitled"]] atIndex:0];
    [self.dataViewModel saveToDisk];
    [self reloadOutLineView];
}
- (IBAction)removeShellBtnClick:(id)sender {
    
    JKShellManagerViewModel *item = [self.outlineView itemAtRow:self.outlineView.selectedRow];
    if (item && [item isKindOfClass:[JKShellManagerViewModel class]]) {

        //Alert Warning
        NSString *warning = @"";
        if (item.isGroup) {
            if (item.numberOfCount > 0) {
                warning = @"This Group Contains Multiple Items, Would you remove them all ? ";
            }else{
                warning = @"This is an empty Group, Would you remove it ? ";
            }
        }else{
            warning = @"This is a normal shell item, Would you remove it ? ";
        }

        __weak typeof(item) weakItem = item;
        __weak typeof(self) weakSelf = self;
        [self showAlertWithTitle:warning okAction:^{
            [weakItem.superModel removeModel:weakItem];
            [weakSelf.dataViewModel saveToDisk];
            [weakSelf reloadOutLineView];
        }];
    }
}

- (void)showAlertWithTitle:(NSString *)title okAction:(void (^)(void))OKActionBlock
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = title;
    NSButton *cancelBtn = [alert addButtonWithTitle:@"Cancel"];
    cancelBtn.tag = NSModalResponseCancel;
    if (OKActionBlock) {
        NSButton *okBtn = [alert addButtonWithTitle:@"OK"];
        okBtn.tag = NSModalResponseOK;
    }
    [alert beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            if (OKActionBlock) {
                OKActionBlock();
            }
        }
    }];
}


#pragma mark - outline delegate

#pragma mark - drag
- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item
{
    return @"testoutline";
    
    
}

- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)draggedItems
{
    if (draggedItems.count > 0) {
        id item = draggedItems.firstObject;
        NSLog(@"Drag Item : %p -- %@", item, item);
        self.beginItem = item;
        self.tempAimRow = [self.outlineView rowForItem:item];
        NSLog(@"row for item -- %ld", self.tempAimRow);
    }
}

- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
    [self.outlineView endDragging];

    JKShellManagerViewModel *sourceItem = self.beginItem;
    JKShellManagerViewModel *targetItem = [self.outlineView itemAtRow:self.tempAimRow];
    if ([sourceItem isKindOfClass:[JKShellManagerViewModel class]] && [targetItem isKindOfClass:[JKShellManagerViewModel class]]) {
        if (self.dragOperate == JKDragableRowPositionCenter) {
            //combine new group or add in exist group
            if (targetItem.isGroup) {
                [sourceItem.superModel removeModel:sourceItem];
                [targetItem addModel:sourceItem atIndex:0];
            }else{
                JKShellManagerViewModel *superModel = targetItem.superModel;
                NSInteger idx = [targetItem.superModel idxOfModel:targetItem];
                if (idx == NSNotFound) {
                    idx = 0;
                }
                
                [targetItem.superModel removeModel:targetItem];
                [sourceItem.superModel removeModel:sourceItem];
                //new group create
                JKShellManagerViewModel *group = [[JKShellManagerViewModel alloc] initWithGroup];
                [group addModel:sourceItem atIndex:0];
                [group addModel:targetItem atIndex:0];
                
                [superModel addModel:group atIndex:idx];
            }

        }else{
            if (sourceItem.superModel == targetItem.superModel) {
                NSInteger superRow = MAX(0, [self.outlineView rowForItem:sourceItem.superModel]);
                NSInteger sourceRow = [self.outlineView rowForItem:sourceItem] - superRow - (superRow > 0?1:0);
                NSInteger targetRow = [self.outlineView rowForItem:targetItem] - superRow - (superRow > 0?1:0);
                
                [sourceItem.superModel moveModelFromIdx:sourceRow toIdx:targetRow];
                
                NSLog(@"end drag in %@ from %ld-%@ to %ld",sourceItem.superModel.displayName, sourceRow, sourceItem.displayName, targetRow);
            }else{
                [sourceItem.superModel removeModel:sourceItem];
                
                NSInteger targetSuperRow = MAX(0, [self.outlineView rowForItem:targetItem.superModel]);
                NSInteger targetRow = [self.outlineView rowForItem:targetItem] - targetSuperRow - (targetSuperRow > 0?1:0);
                [targetItem.superModel addModel:sourceItem atIndex:targetRow];
            }
        }
        
        [self.dataViewModel saveToDisk];
    }else{
        NSLog(@"Operation not permit.");
    }
    
    [self reloadOutLineView];
}


#pragma mark - datasource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    if (item && [item isKindOfClass:[JKShellManagerViewModel class]]) {
        return [(JKShellManagerViewModel *)item numberOfCount];
    }else{
        if (self.dataViewModel) {
            return self.dataViewModel.numberOfCount;
        }else{
            return 0;
        }
    }
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    if (item && [item isKindOfClass:[JKShellManagerViewModel class]]) {
        return [(JKShellManagerViewModel *)item modelAtIdex:index];
    }else{
        return [self.dataViewModel modelAtIdex:index];
    }
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (item && [item isKindOfClass:[JKShellManagerViewModel class]]) {
        return [(JKShellManagerViewModel *)item isGroup];
    }
    return NO;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    JKShellManagerCell *reuseView = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if (item && [item isKindOfClass:[JKShellManagerViewModel class]]) {
        JKShellManagerViewModel *model = (JKShellManagerViewModel *)item;
        
        reuseView.name = model.displayName;
        __weak typeof(model) weakModel = model;
        __weak typeof(self) weakSelf = self;
        reuseView.NameUpdateBlock = ^(NSString *nName) {
            [weakModel updateName:nName];
            //re-save
            [weakSelf.dataViewModel saveToDisk];
        };
        if (model.isGroup) {
            reuseView.showStatus = false;
            reuseView.status = false;
        }else{
            reuseView.showStatus = true;
            reuseView.status = model.attachModel.isRunning;
        }
    }
    
    return reuseView;
}

- (void)outlineViewClicked:(NSOutlineView *)sender
{
    JKShellManagerViewModel *clickItem = [sender itemAtRow:[self.outlineView clickedRow]];
    if (clickItem && [clickItem isKindOfClass:[JKShellManagerViewModel class]])
    {
        NSLog(@"click");
        if (clickItem.isGroup) {
            return;
        }
        
        if (clickItem.attachModel == self.currentRunningModel) {
            return;
        }
        
        self.currentRunningModel = clickItem.attachModel;
        if (!self.currentRunningModel.isRunning) {
            [self.currentRunningModel startShell];
        }
    
        [self.outlineView reloadItem:clickItem];
    }
}

- (void)setCurrentRunningModel:(JKShellModel *)currentRunningModel
{
    _currentRunningModel.UpdateStringBlock = nil;
    _currentRunningModel = currentRunningModel;
    __weak typeof(self) weakSelf = self;
    _currentRunningModel.UpdateStringBlock = ^(NSString * _Nonnull contentStr) {
        weakSelf.textView.string = contentStr;
        [weakSelf.textView scrollToEndOfDocument:nil];
    };
    
    //update textView
    [_currentRunningModel updateStorageStrToTxtView];
    
}


#pragma mark TextViewDelegate

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    NSLog(@"User typed input: %@", replacementString);
    if ([replacementString isEqualToString:@"\n"]) {
        NSString *txt = [textView.string stringByAppendingString:@"\n"];
        NSLog(@"input -- %@", txt);
        
        if (self.currentRunningModel) {
            if (self.currentRunningModel.isRunning) {
                [self.currentRunningModel writeString:txt];
            }else{
                [self showAlertWithTitle:@"This Shell is not running." okAction:nil];
            }
        }else{
            [self showAlertWithTitle:@"Shell is Not Exist." okAction:nil];
        }
        
        
        textView.string = @"";
        return NO;
    }
    
    return YES;
}


@end
