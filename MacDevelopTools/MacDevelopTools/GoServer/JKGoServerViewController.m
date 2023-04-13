//
//  JKGoServerViewController.m
//  MacDevelopTools
//
//  Created by jk on 2022/5/25.
//  Copyright © 2022 JK. All rights reserved.
//

#import "JKGoServerViewController.h"
#import "JKGoServerEditViewController.h"
#import "JKGoServerDataModel.h"
#import "JKGoServerDataStorage.h"
#import "YYModel.h"
#import <objc/runtime.h>
#import "Masonry.h"
#import "JKGoControlNetworkManager.h"
#import "JKGoControlRequestParamsMaker.h"
#import "NSData+YYAdd.h"
#import "NSString+JSONBeauty.h"
#import "JKGoServerSaveActionViewController.h"
#import "JKGoControlNetworkRoute.h"

#define kButtonEdit     222
#define kButtonAdd      223
#define kButtonDelete   224
#define kButtonReload   225
#define kButtonLink     226
#define kButtonSave     227
#define kButtonClear    228
#define kButtonCopy     229
#define kButtonImport   230
#define kButtonBeauty   231
#define kButtonUnbeauty 232


@interface JKGoServerViewController ()<NSOutlineViewDelegate,NSOutlineViewDataSource,NSTextViewDelegate>

@property (weak) IBOutlet NSBox *serverListBox;
@property (weak) IBOutlet NSOutlineView *serverListView;
@property (weak) IBOutlet NSStackView *serverBtnsView;

@property (weak) IBOutlet NSBox *scriptsListBox;
@property (weak) IBOutlet NSOutlineView *scriptsListView;
@property (weak) IBOutlet NSStackView *scriptsBtnsView;

@property (weak) IBOutlet NSBox *inputBox;
@property (unsafe_unretained) IBOutlet NSTextView *inputDataView;


@property (weak) IBOutlet NSStackView *actionBtnsView;
@property (weak) IBOutlet NSPopUpButton *actionTemplateItemsView;
@property (weak) IBOutlet NSButton *optionCheckBox;

@property (weak) IBOutlet NSPopUpButton *actionListItemsView;

@property (weak) IBOutlet NSBox *outputBox;
@property (unsafe_unretained) IBOutlet NSTextView *outputDataView;



@property (weak) IBOutlet NSTextField *currentServerTitleLabel;


//data
@property(nonatomic, strong) NSMutableArray<JKGoServerDataModel *> *serverList;
@property(nonatomic, strong) NSMutableArray<JKGoServerActionModel *> *actionsList;
@property(nonatomic, strong) JKGoServerEditViewController *serverEditVC;
@property(nonatomic, strong) JKGoControlNetworkManager *networkManager;

@end

@implementation JKGoServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.inputDataView.enabledTextCheckingTypes = 0;
    self.outputDataView.enabledTextCheckingTypes = 0;
    
    self.serverList = [NSMutableArray arrayWithArray:[JKGoServerDataStorage serverListFromDisk]];
    self.actionsList = [NSMutableArray arrayWithArray:[JKGoServerDataStorage actionsListFromDisk]];
    [self setupServerListView];
    [self setupScriptsListView];
    [self setupPopUpItemsAction];
}

- (void)setupServerListView
{
    NSArray *keys = [JKGoServerDataModel sortMemberKeysArr];
    for (NSString *key in keys) {
        NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:key];
        col.minWidth = 40;
        col.width = 60;
        col.title = key;
        col.editable = false;
        [self.serverListView addTableColumn:col];
    }
    self.serverListView.allowsMultipleSelection = true;
    self.serverListView.delegate = self;
    self.serverListView.dataSource = self;
    [self reloadServerListView];
}

- (void)setupScriptsListView
{
    NSArray *keys = [JKGoServerActionModel sortMemberKeysArr];
    for (NSString *key in keys) {
        NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:key];
        col.minWidth = 40;
        col.width = 60;
        col.title = key;
        col.editable = false;
        [self.scriptsListView addTableColumn:col];
    }
    self.scriptsListView.delegate = self;
    self.scriptsListView.dataSource = self;
    [self reloadScriptsListView];
}

- (void)setupPopUpItemsAction
{
    [self.actionListItemsView removeAllItems];
    [self.actionListItemsView addItemsWithTitles:@[
        [JKGoControlRequestParamsMaker describeNameForActionType:ActionTypeGet],
        [JKGoControlRequestParamsMaker describeNameForActionType:ActionTypeModify],
        [JKGoControlRequestParamsMaker describeNameForActionType:ActionTypeDelete],
        ]
    ];
    
    
    [self.actionTemplateItemsView removeAllItems];
    [self.actionTemplateItemsView addItemsWithTitles:@[
        [JKGoControlRequestParamsMaker describeNameForActionCategory:ActionCategoryVersion],
        [JKGoControlRequestParamsMaker describeNameForActionCategory:ActionCategoryConfig],
        [JKGoControlRequestParamsMaker describeNameForActionCategory:ActionCategoryCmd],
        [JKGoControlRequestParamsMaker describeNameForActionCategory:ActionCategoryUpdate],
        ]
    ];
}


#pragma mark - Buttons Actions


- (IBAction)serverListBtnAction:(NSButton *)sender {
    switch (sender.tag) {
        case kButtonAdd:
        {
            [self.serverEditVC clearData];
            [self presentViewControllerAsSheet:self.serverEditVC];
        }
            break;
        case kButtonEdit:
        {
            if (!(self.serverListView.selectedRow < 0 || self.serverListView.selectedRow > self.serverList.count)) {
                self.serverEditVC.serverModel = [self.serverList objectAtIndex:self.serverListView.selectedRow];
            }
            [self presentViewControllerAsSheet:self.serverEditVC];
        }
            break;
        case kButtonDelete:
        {
            if (self.serverListView.selectedRow < 0 || self.serverListView.selectedRow > self.serverList.count) {
                [self showAlertWithTitle:@"未选中项目"];
                return;
            }
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"确定移除该信息？";
            NSButton *cancelBtn = [alert addButtonWithTitle:@"Cancel"];
            cancelBtn.tag = NSModalResponseCancel;
            NSButton *okBtn = [alert addButtonWithTitle:@"Ok"];
            okBtn.tag = NSModalResponseOK;
            __weak typeof(self) weakSelf = self;
            [alert beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSModalResponseOK && !(weakSelf.serverListView.selectedRow < 0 || weakSelf.serverListView.selectedRow > weakSelf.serverList.count)) {
                    [weakSelf.serverList removeObjectAtIndex:weakSelf.serverListView.selectedRow];
                    [JKGoServerDataStorage saveServerListInDisk:weakSelf.serverList];
                    [weakSelf reloadServerListView];
                }
            }];
            
        }
        case kButtonReload:
        {
            [self reloadServerListView];
        }
            break;
        case kButtonLink:
        {
            if (self.serverListView.selectedRowIndexes.count > 1) {
                
                [self.serverListView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    JKGoServerDataModel *server = [self.serverList objectAtIndex:idx];
                    [self checkAuthRequestWithModel:server successBlock:nil];
                }];
                
            }else{
                if (self.serverListView.selectedRow < 0 || self.serverListView.selectedRow > self.serverList.count) {
                    [self showAlertWithTitle:@"未选中项目"];
                    return;
                }
                JKGoServerDataModel *selectedModel = [self.serverList objectAtIndex:[self.serverListView selectedRow]];
                [self checkAuthRequestWithModel:selectedModel successBlock:nil];
            }
        }
            break;
        default:
            break;
    }
}

- (IBAction)scriptsListBtnAction:(NSButton *)sender {
    NSLog(@"Action -- %@",sender);
    switch (sender.tag) {
        case kButtonDelete:
        {
            if (self.scriptsListView.selectedRow < 0 || self.scriptsListView.selectedRow > self.actionsList.count) {
                [self showAlertWithTitle:@"未选中项目"];
                return;
            }
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"确定移除该信息？";
            NSButton *cancelBtn = [alert addButtonWithTitle:@"Cancel"];
            cancelBtn.tag = NSModalResponseCancel;
            NSButton *okBtn = [alert addButtonWithTitle:@"Ok"];
            okBtn.tag = NSModalResponseOK;
            __weak typeof(self) weakSelf = self;
            [alert beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSModalResponseOK && !(weakSelf.scriptsListView.selectedRow < 0 || weakSelf.scriptsListView.selectedRow > weakSelf.actionsList.count)) {
                    [weakSelf.actionsList removeObjectAtIndex:weakSelf.scriptsListView.selectedRow];
                    [JKGoServerDataStorage saveActionsListInDisk:weakSelf.actionsList];
                    [weakSelf reloadScriptsListView];
                }
            }];
        }
            break;
        case kButtonImport:
        {
            if (self.scriptsListView.selectedRow < 0 || self.scriptsListView.selectedRow > self.actionsList.count) {
                [self showAlertWithTitle:@"未选中项目"];
                return;
            }
            JKGoServerActionModel *model = [self.actionsList objectAtIndex:self.scriptsListView.selectedRow];
            self.inputDataView.string = model.content?:@"";
            self.optionCheckBox.state = model.isQuickCMD ? NSControlStateValueOn : NSControlStateValueOff;
            [self.actionListItemsView selectItemAtIndex:model.action];
            [self.actionTemplateItemsView selectItemAtIndex:model.actionPath];
        }
            break;
        case kButtonReload:
        {
            [self reloadScriptsListView];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)inputViewBtnAction:(NSButton *)sender {
    switch (sender.tag) {
        case kButtonSave:
        {
            [self showSaveActionPanel];
        }
            break;
        case kButtonClear:
        {
            self.inputDataView.string = @"";
        }
            break;
        case kButtonCopy:
        {
            [[NSPasteboard generalPasteboard] clearContents];
            [[NSPasteboard generalPasteboard] writeObjects:@[self.inputDataView.string?:@""]];
        }
            break;
        default:
            break;
    }
}

- (IBAction)outputViewBtnAction:(NSButton *)sender {
    switch (sender.tag) {
        case kButtonBeauty:
        {
            self.outputDataView.string = self.outputDataView.string?[self.outputDataView.string beautyJSON]:@"";
        }
            break;
        case kButtonUnbeauty:
        {
            self.outputDataView.string = self.outputDataView.string?[self.outputDataView.string unBeautyJSON]:@"";
        }
            break;
        case kButtonClear:
        {
            self.outputDataView.string = @"";
        }
            break;
        case kButtonCopy:
        {
            [[NSPasteboard generalPasteboard] clearContents];
            [[NSPasteboard generalPasteboard] writeObjects:@[self.outputDataView.string?:@""]];
        }
            break;
        default:
            break;
    }
}

- (IBAction)actionTemplateAction:(id)sender {
    NSLog(@"Action -- %@",sender);
    JKGoControlActionCategory currentCategory = [self getCategory];
    NSString *templateStr = nil;
    switch (currentCategory) {
        case ActionCategoryCmd:
        {
            templateStr = @"{\"cmd\":\"ls\",\"params\":[\"-l\"]}";
        }
            break;
            
        default:
            break;
    }
    if (templateStr) {
        if ((!self.inputDataView.string || self.inputDataView.string.length <= 0)) {
            self.inputDataView.string = [templateStr beautyJSON];
        }else{
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"当前分类可以加载模板，是否覆盖并加载";
            NSButton *cancelBtn = [alert addButtonWithTitle:@"Cancel"];
            cancelBtn.tag = NSModalResponseCancel;
            NSButton *okBtn = [alert addButtonWithTitle:@"Ok"];
            okBtn.tag = NSModalResponseOK;
            __weak typeof(self) weakSelf = self;
            [alert beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSModalResponseOK) {
                    weakSelf.inputDataView.string = [templateStr beautyJSON];
                }
            }];
        }
    }
}


- (IBAction)actionListItemsAction:(id)sender {
    NSLog(@"Action -- %@",sender);
}

- (IBAction)sendRequestBtnAction:(id)sender {
    
    if (self.serverListView.selectedRowIndexes.count > 1) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"该操作会对列表所选择的目标执行，确认么？";
        NSButton *cancelBtn = [alert addButtonWithTitle:@"Cancel"];
        cancelBtn.tag = NSModalResponseOK;
        NSButton *okBtn = [alert addButtonWithTitle:@"Ok"];
        okBtn.tag = NSModalResponseCancel;
        __weak typeof(self) weakSelf = self;
        [alert beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSModalResponseCancel) {
                [weakSelf sendToMultiServerRequest];
            }
        }];
        
    }else{
        
        if (self.serverListView.selectedRow < 0 || self.serverListView.selectedRow > self.serverList.count) {
            [self showAlertWithTitle:@"未选中项目"];
            return;
        }
        JKGoServerDataModel *selectedModel = [self.serverList objectAtIndex:[self.serverListView selectedRow]];
        if (!selectedModel.reqIdentify || selectedModel.reqIdentify.length <= 0) {
            [self showAlertWithTitle:@"当前项目无法发起请求"];
            return;
        }
        
        [self sendRequestWithModel:selectedModel appendResult:false];
        
    }
}


#pragma mark - Action Request Helper

- (void)sendToMultiServerRequest
{
    __weak typeof(self) weakSelf = self;
    void (^ActionBlock)(JKGoServerDataModel *) = ^(JKGoServerDataModel *server){
        [weakSelf sendRequestWithModel:server appendResult:true];
    };
    
    //Clear before request, because result will append to OutputDataView.
    self.outputDataView.string = @"";
    
    [self.serverListView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        JKGoServerDataModel *server = [self.serverList objectAtIndex:idx];
        if (server.linkStatus == JKGoServerLinkStatusOn) {
            ActionBlock(server);
        }else{
            [self checkAuthRequestWithModel:server successBlock:^{
                ActionBlock(server);
            }];
        }
    }];
}

- (void)checkAuthRequestWithModel:(JKGoServerDataModel *)model successBlock:(void (^)(void))successBlock
{
    __weak typeof(self) weakSelf = self;
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    model.reqIdentify = [self.networkManager authRequestWithRequest:model.req success:^(BOOL res, NSInteger errCode) {
        model.lastFailedCode = errCode;
        model.timeInterval = [[NSDate date] timeIntervalSince1970] - currentTime;
        if (res && errCode == JKGoControlResponseCode_Suc) {
            [weakSelf getVersionWithModel:model successBlock:successBlock];
        }else{
            model.lastFailedCode = JKGoControlResponseCode_SecretDeny;
        }
        [weakSelf reloadServerListView];
    } failed:^(NSError * _Nonnull err) {
        model.lastFailedCode = -1;
        model.timeInterval = [[NSDate date] timeIntervalSince1970] - currentTime;
        [weakSelf reloadServerListView];
    }];
}

- (void)getVersionWithModel:(JKGoServerDataModel *)model successBlock:(void (^)(void))successBlock
{
    __weak typeof(self) weakSelf = self;
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    [self.networkManager requestWithIdentify:model.reqIdentify
                                      params:[JKGoControlRequestParamsMaker makeAction:ActionCategoryVersion
                                                                                  type:ActionTypeGet
                                                                                  data:nil]
                                     success:^(BOOL res, NSInteger errCode, id  _Nonnull dataObject) {
        model.lastFailedCode = errCode;
        model.timeInterval = [[NSDate date] timeIntervalSince1970] - currentTime;
        if (res && dataObject) {
            model.version = [NSString stringWithFormat:@"%@",dataObject];
            [weakSelf reloadServerListView];
        }
        if (res) {
            if (successBlock) {
                successBlock();
            }
        }
    } failed:^(NSError * _Nonnull err) {
        model.lastFailedCode = -1;
        model.timeInterval = [[NSDate date] timeIntervalSince1970] - currentTime;
    }];
}

- (void)sendRequestWithModel:(JKGoServerDataModel *)model appendResult:(BOOL)appendResult
{
    NSString *reqDataStr = nil;
    NSString *inputStr = self.inputDataView.string;
    JKGoControlActionCategory catagory = [self getCategory];
    if (catagory == ActionCategoryCmd && self.optionCheckBox.state == NSControlStateValueOn) {
        //Quick Command Check, this will bind in bash command
        reqDataStr = [NSString stringWithFormat:@"{\"cmd\":\"bash\",\"params\":[\"-c\",\"%@\"]}",inputStr];
    }else{
        if (inputStr) {
            reqDataStr = [inputStr unBeautyJSON];
            self.inputDataView.string = [inputStr beautyJSON];
        }
    }
   
    
    __weak typeof(self) weakSelf = self;
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    [self.networkManager requestWithIdentify:model.reqIdentify
                                      params:[JKGoControlRequestParamsMaker makeAction:[self getCategory]
                                                                                  type:[self getAction]
                                                                                  data:reqDataStr]
                                     success:^(BOOL res, NSInteger errCode, id  _Nonnull dataObject) {
        if (appendResult) {
            NSString *responseStr = [[NSString alloc] initWithFormat:@"Response For %@ :\n%@",model.nick?:model.host, dataObject];
            if (weakSelf.outputDataView.string && weakSelf.outputDataView.string.length > 0) {
                weakSelf.outputDataView.string = [NSString stringWithFormat:@"%@\n\n%@",weakSelf.outputDataView.string, responseStr];
            }else{
                weakSelf.outputDataView.string = responseStr;
            }
        }else{
            weakSelf.outputDataView.string = [NSString stringWithFormat:@"%@",dataObject];
        }
        
        model.lastFailedCode = errCode;
        model.timeInterval = [[NSDate date] timeIntervalSince1970] - currentTime;
        [weakSelf reloadServerListView];
    } failed:^(NSError * _Nonnull err) {
        model.lastFailedCode = -1;
        model.timeInterval = [[NSDate date] timeIntervalSince1970] - currentTime;
        [weakSelf reloadServerListView];
    }];
}


- (void)updateCurrentServerTitleLabel
{
    if (self.serverListView.selectedRowIndexes.count > 1) {
        self.currentServerTitleLabel.stringValue = @"Multi Selection";
    }else{
        if (!(self.serverListView.selectedRow < 0 || self.serverListView.selectedRow > self.serverList.count)) {
            JKGoServerDataModel *model = [self.serverList objectAtIndex:self.serverListView.selectedRow];
            NSString *title = model.host;
            if (!title || title.length <= 0) {
                title = model.host;
            }
            self.currentServerTitleLabel.stringValue = title;
        }else {
            self.currentServerTitleLabel.stringValue = @"Unselected";
        }
    }
}

- (JKGoControlActionCategory)getCategory
{
    return (JKGoControlActionCategory)self.actionTemplateItemsView.indexOfSelectedItem;
}

- (JKGoControlActionType)getAction
{
    return (JKGoControlActionType)self.actionListItemsView.indexOfSelectedItem + ActionTypeGet;
}

- (NSString *)timeFormat:(NSTimeInterval)time
{
    return [NSString stringWithFormat:@"%.2fms",time * 1000];
}

- (NSString *)reasonOfLastErrorCode:(JKGoControlResponseCode)code
{
    switch (code) {
        case JKGoControlResponseCode_Suc:
            return @"成功";
            break;
        case JKGoControlResponseCode_UnexpectedException:
            return @"服务器出错了";
            break;
        case JKGoControlResponseCode_SecretDeny:
            return @"密钥出错";
            break;
        case JKGoControlResponseCode_AuthDeny:
            return @"未授权";
            break;
        case JKGoControlResponseCode_AuthSeqDeny:
            return @"请求序列出错";
            break;
        case JKGoControlResponseCode_DataStruct:
            return @"数据结构错误";
            break;
        case JKGoControlResponseCode_NoSuchActionPath:
            return @"不存在的操作";
            break;
        case JKGoControlResponseCode_UnsupportAction:
            return @"不允许该操作";
            break;
        case JKGoControlResponseCode_LocalNetworkError:
            return @"网络异常";
            break;
        case JKGoControlResponseCode_LocalNotRequestYet:
            return @"";
            break;
        default:
            return @"未知错误";
            break;
    }
}

#pragma mark - Save Action

- (void)showSaveActionPanel
{
    NSStoryboard *sb = [NSStoryboard storyboardWithName:@"GoServer" bundle:nil];
    JKGoServerSaveActionViewController *c = [sb instantiateControllerWithIdentifier:@"JKGoServerSaveActionViewController"];
    if (!c) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    JKGoServerActionModel *actionModel;
//    if (!(self.scriptsListView.selectedRow < 0 || self.scriptsListView.selectedRow > self.actionsList.count)) {
//        actionModel = [self.actionsList objectAtIndex:[self.scriptsListView selectedRow]];
//        c.SaveActionBlock = ^(JKGoServerSaveActionViewController * _Nonnull controller, BOOL confirm) {
//            if (confirm) {
//                [JKGoServerDataStorage saveActionsListInDisk:weakSelf.actionsList];
//            }
//        };
//    }else{
        actionModel = [[JKGoServerActionModel alloc] init];
        actionModel.actionPath = self.actionTemplateItemsView.indexOfSelectedItem;
        actionModel.action = self.actionListItemsView.indexOfSelectedItem;
        actionModel.isQuickCMD = (self.optionCheckBox.state == NSControlStateValueOn);
        actionModel.content = [self.inputDataView.string copy];
        c.SaveActionBlock = ^(JKGoServerSaveActionViewController * _Nonnull controller, BOOL confirm) {
            if (confirm) {
                [weakSelf.actionsList addObject:controller.editModel];
                [JKGoServerDataStorage saveActionsListInDisk:weakSelf.actionsList];
                [weakSelf reloadScriptsListView];
            }
        };
//    }
    c.editModel = actionModel;
    [self presentViewControllerAsSheet:c];
}

#pragma mark - Reload Action


- (void)reloadServerListView
{
    BOOL maintainSelection = false;
    if (self.serverList.count == self.serverListView.numberOfRows) {
        maintainSelection = true;
    }
    NSIndexSet *selectedRowIndexSet = nil;
    if (maintainSelection) {
        selectedRowIndexSet = self.serverListView.selectedRowIndexes;
    }
    [self.serverListView reloadData];
    if (maintainSelection && selectedRowIndexSet) {
        [self.serverListView selectRowIndexes:selectedRowIndexSet byExtendingSelection:false];
    }
    [self updateCurrentServerTitleLabel];
}

- (void)reloadScriptsListView
{
    BOOL maintainSelection = false;
    if (self.actionsList.count == self.scriptsListView.numberOfRows) {
        maintainSelection = true;
    }
    NSInteger selectedRow = -1;
    if (maintainSelection) {
        selectedRow = self.scriptsListView.selectedRow;
    }
    [self.scriptsListView reloadData];
    if (maintainSelection) {
        [self.scriptsListView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:false];
    }
}

#pragma mark - Alert

- (void)showAlertWithTitle:(NSString *)title
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = title;
    [alert beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

#pragma mark - OutlineView Delegate

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (outlineView == self.serverListView) {
        return [self.serverList objectAtIndex:index];
    }
    if (outlineView == self.scriptsListView) {
        return [self.actionsList objectAtIndex:index];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return false;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (outlineView == self.serverListView) {
        return self.serverList.count;
    }
    if (outlineView == self.scriptsListView) {
        return self.actionsList.count;
    }
    return 0;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)itemObj
{
    NSTableCellView *reuseView = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if (!reuseView) {
        reuseView = [[NSTableCellView alloc] init];
        reuseView.identifier = tableColumn.identifier;
        
        NSTextField *textField = [[NSTextField alloc] init];
        textField.backgroundColor = NSColor.clearColor;
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.bordered = false;
        textField.controlSize = NSControlSizeSmall;
        textField.editable = false;
        reuseView.textField = textField;
        [reuseView addSubview:textField];
        [textField bind:NSValueBinding toObject:reuseView withKeyPath:@"objectValue" options:nil];
        
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(reuseView);
        }];
        
    }
    
    if (outlineView == self.serverListView) {
        JKGoServerDataModel *item = (JKGoServerDataModel *)itemObj;
        NSString *identifier = tableColumn.identifier;
        if ([identifier isEqualToString:@"host"]) {
            reuseView.textField.stringValue = item.host;
        }else if ([identifier isEqualToString:@"secret"]){
            reuseView.textField.stringValue = item.secret;
        }else if ([identifier isEqualToString:@"iv"]){
            reuseView.textField.stringValue = item.iv;
        }else if ([identifier isEqualToString:@"linkStatus"]){
            NSString *statusStr = @"Unknown";
            switch (item.linkStatus) {
                case JKGoServerLinkStatusOn:
                    statusStr = @"On";
                    break;
                case JKGoServerLinkStatusOff:
                    statusStr = @"Off";
                    break;
                case JKGoServerLinkStatusConnecting:
                    statusStr = @"Connecting";
                    break;
                case JKGoServerLinkStatusFailed:
                    statusStr = [self reasonOfLastErrorCode:item.lastFailedCode];
                    break;
                default:
                    break;
            }
            reuseView.textField.stringValue = statusStr;
        }else if ([identifier isEqualToString:@"location"]){
            reuseView.textField.stringValue = item.location;
        }else if ([identifier isEqualToString:@"nick"]){
            reuseView.textField.stringValue = item.nick;
        }else if ([identifier isEqualToString:@"version"]){
            reuseView.textField.stringValue = item.version?:@"Unknown";
        }else if ([identifier isEqualToString:@"lastRequest"]){
            reuseView.textField.stringValue = [self reasonOfLastErrorCode:item.lastFailedCode];
        }else if ([identifier isEqualToString:@"time"]){
            reuseView.textField.stringValue = [self timeFormat:item.timeInterval];
        }else{
            reuseView.textField.stringValue = @"Unknown";
        }
        
        [reuseView.textField sizeToFit];
        
        return reuseView;
    }else if (outlineView == self.scriptsListView){
        JKGoServerActionModel *item = (JKGoServerActionModel *)itemObj;
        NSString *identifier = tableColumn.identifier;
        if ([identifier isEqualToString:@"name"]) {
            reuseView.textField.stringValue = item.nickName;
        }else if ([identifier isEqualToString:@"action"]){
            reuseView.textField.stringValue = [NSString stringWithFormat:@"%@-%@",
                                               [JKGoControlRequestParamsMaker describeNameForActionCategory:item.actionPath],
                                               [JKGoControlRequestParamsMaker describeNameForActionType:item.action + ActionTypeMin]];
        }else{
            reuseView.textField.stringValue = @"Unknown";
        }
        [reuseView.textField sizeToFit];
        
        return reuseView;
    }else{
        return nil;
    }
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    if (notification.object == self.serverListView) {
        [self updateCurrentServerTitleLabel];
    }
}


- (JKGoServerEditViewController *)serverEditVC
{
    if (!_serverEditVC) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"GoServer" bundle:nil];
        _serverEditVC = [sb instantiateControllerWithIdentifier:@"JKGoServerEditViewController"];
        __weak typeof(self) weakSelf = self;
        _serverEditVC.FinishUpdatedWithResultBlock = ^(JKGoServerDataModel * _Nonnull serverModel, BOOL isUpdate) {
            if (isUpdate) {
                if (weakSelf.serverEditVC.serverModel) {
                    //edit Model
                    [weakSelf checkAuthRequestWithModel:weakSelf.serverEditVC.serverModel successBlock:nil];
                }else{
                    //add Model
                    [weakSelf.serverList addObject:serverModel];
                    [weakSelf checkAuthRequestWithModel:serverModel successBlock:nil];
                }
                [JKGoServerDataStorage saveServerListInDisk:weakSelf.serverList];
                [weakSelf.serverListView reloadData];
            }
        };
    }
    return _serverEditVC;
}

- (JKGoControlNetworkManager *)networkManager
{
    if (!_networkManager) {
        _networkManager = [[JKGoControlNetworkManager alloc] init];
    }
    return _networkManager;
}

@end
