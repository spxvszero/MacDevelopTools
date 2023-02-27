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

@property (nonatomic, strong) NSPipe *inputPipe;

@property (nonatomic, assign) int master_fd;
@property (nonatomic, assign) int slave_fd;
@property (nonatomic, strong) dispatch_queue_t cmdQueue;

@property (nonatomic, assign) int testNum;


@property (nonatomic, weak) id beginItem;
@property (nonatomic, assign) NSInteger tempAimRow;
@property (nonatomic, assign) JKDragableRowPosition dragOperate;

@property (nonatomic, strong) JKShellModel *currentRunningModel;

@end

@implementation JKShellManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.dataViewModel = [self fakeData];
    
    
    
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
    self.testNum ++;
    [self.dataViewModel addModel:[[JKShellManagerViewModel alloc] initWithModel:[JKShellModel modelWithName:@"tmp"]] atIndex:0];
    [self reloadOutLineView];
}
- (IBAction)removeShellBtnClick:(id)sender {
    
    NSString *txt = @"\033[?2004l\n";
    NSLog(@"write test str : %@",txt);
    [self.currentRunningModel writeString:txt];
    
//    [self reloadOutLineView];
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

- (void)buildCMD
{
    
//    self.cmdQueue = dispatch_queue_create("com.example.taskQueue", DISPATCH_QUEUE_SERIAL);
    __weak typeof(self) weakSelf = self;
//    dispatch_async(self.cmdQueue, ^{
        // 创建一个新的伪终端
        char slave_name[255];
        Ivar masterFdIvar = class_getInstanceVariable([self class], "_master_fd");
        int *masterFdPtr = (int *)((__bridge void *)weakSelf + ivar_getOffset(masterFdIvar));
        Ivar slaveFdIvar = class_getInstanceVariable([self class], "_slave_fd");
        int *slaveFdPtr = (int *)((__bridge void *)weakSelf + ivar_getOffset(slaveFdIvar));
        
        int res = openpty(masterFdPtr, slaveFdPtr, slave_name, NULL, NULL);
            if (res == -1) {
                NSLog(@"Failed to open pseudo-terminal");
                return;
            }else{
                NSLog(@"master -- %d",weakSelf.master_fd);
                NSLog(@"slave -- %d",weakSelf.slave_fd);
            }
            
        //    struct termios attr;
        //    tcgetattr(_slave_fd, &attr);
        //    attr.c_lflag &= ~ECHO;
        //    tcsetattr(_slave_fd, TCSANOW, &attr);
        
    pid_t pid;
    switch (pid = forkpty(masterFdPtr, NULL, NULL, NULL)) {
            case -1:
        {
                NSLog(@"Failed to forkpty: %s", strerror(errno));
            NSLog(@"Run In MainProcess. ");
            NSTask *task = [[NSTask alloc] init];
                    //    [task setLaunchPath:@"/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal"];
                        [task setLaunchPath:@"/bin/zsh"];
                    //    [task setArguments:@[@"-c", @"echo Hello World"]];
                        
                    //    NSPipe *pipe = [NSPipe pipe];
            //            NSPipe *inputPipe = [NSPipe pipe];
            //            self.inputPipe = inputPipe;

                        // 将伪终端设为标准输入、输出和错误
                    NSFileHandle *fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:weakSelf.slave_fd];
                    //    task.standardInput = [[NSFileHandle alloc] initWithFileDescriptor:self.slave_fd];
                    //    [task setStandardInput:inputPipe];
                        task.standardInput = fileHandle;
                        task.standardOutput = fileHandle;
                        task.standardError = fileHandle;
                    //    [task setStandardOutput:pipe];
                    //    [task setStandardInput:inputPipe];
                    //    NSFileHandle *file = [pipe fileHandleForReading];
                    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReady:) name:NSFileHandleReadCompletionNotification object:file];
                    //    [file readInBackgroundAndNotify];
                        
                        // 将伪终端从文件句柄中读取输入并显示在文本视图中
                    NSFileHandle *mfileHandle = [[NSFileHandle alloc] initWithFileDescriptor:weakSelf.master_fd];
                        [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(dataReady:) name:NSFileHandleReadCompletionNotification object:mfileHandle];
                        [mfileHandle readInBackgroundAndNotify];
                    //    [fileHandle setReadabilityHandler:^(NSFileHandle *fh) {
                    //        NSData *data = fh.availableData;
                    //        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    //        dispatch_async(dispatch_get_main_queue(), ^{
                    //           [self.textView insertText:string replacementRange:NSMakeRange(0, 0)];
                    //        });
                    //    }];

                        
                        [task launch];
        }
            break;
            case 0:
        {
                // In child process, execute ssh command.
               const char* cmd = "/bin/zsh";
                const char* args[] = { cmd, NULL };
                execvp(cmd, (char* const*)args);
                _exit(127);
        }
            break;
            default:
        {
            //close slave handler, or will cause dead loop.
            close(weakSelf.slave_fd);
                // In parent process, read output from child.
            weakSelf.slave_fd = weakSelf.master_fd;
            
            if (login_tty(pid) < 0) {
                NSLog(@"Try Login Failed. Some device may could not work fine.");
            }
            
            NSFileHandle *mfileHandle = [[NSFileHandle alloc] initWithFileDescriptor:weakSelf.master_fd];
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(dataReady:) name:NSFileHandleReadCompletionNotification object:mfileHandle];
            [mfileHandle readInBackgroundAndNotify];
        }
                break;
    }

            
            
//    });
    
    
    
}


- (void)dataReady:(NSNotification *)notification {
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if ([data length]) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textView insertText:string replacementRange:NSMakeRange(0, 0)];
        });
        NSLog(@"output -- %@",string);
        [[notification object] readInBackgroundAndNotify];
    } else {
        NSLog(@"finish cmd");
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[notification object]];
    }
}



#pragma mark TextViewDelegate

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    NSLog(@"User typed input: %@", replacementString);
    if ([replacementString isEqualToString:@"\n"]) {
        NSString *txt = [textView.string stringByAppendingString:@"\n"];
        NSLog(@"input -- %@", txt);
        
        [self.currentRunningModel writeString:txt];

//        // 获取输入管道的文件句柄
//        NSFileHandle *fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:_master_fd];
////        NSFileHandle *fileHandle = [self.inputPipe fileHandleForWriting];
//        // 将输入文本写入输入管道
//        NSData *inputData = [txt dataUsingEncoding:NSUTF8StringEncoding];
//        [fileHandle writeData:inputData];
        // 输入管道以便命令行进程知道输入已完成
//        [fileHandle synchronizeFile];
        
        textView.string = @"";
        return NO;
    }
    
    return YES;
}


@end
