//
//  JKClockViewController.m
//  MacDevelopTools
//
//  Created by jk on 2019/9/2.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKClockViewController.h"
#import "JKDatePicker.h"
#import <UserNotifications/UserNotifications.h>
#import "JKClockScheduleModel.h"
#import "JKClockNotificationViewController.h"
#import "Appdelegate.h"

static NSInteger JKUserNotificationIdentify = 0;

@interface JKClockViewController ()<NSTableViewDataSource,NSTableViewDelegate,NSUserNotificationCenterDelegate,UNUserNotificationCenterDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet JKDatePicker *datePicker;
@property (weak) IBOutlet NSTextField *additionalMinutes;
@property (weak) IBOutlet NSTextField *inputTxtField;
@property (weak) IBOutlet NSButton *removeBtn;
@property (weak) IBOutlet NSButton *addBtn;
@property (weak) IBOutlet NSTableView *contentTableView;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL followTimer;

@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSArray *tableColTitle;
@property (nonatomic, strong) NSMutableArray<JKClockScheduleModel *> *scheduleArr;

@property (nonatomic, strong) NSPopover *popOver;
@property (nonatomic, strong) JKClockNotificationViewController *notifyViewController;

@end

@implementation JKClockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    if (@available(macOS 10.14, *)) {
         [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    }else{
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    }
    
    self.followTimer = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
    
    self.tableColTitle = @[@"Schedule",@"Content"];
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    for (NSUInteger i = 0; i < self.tableView.tableColumns.count; i++){
        NSTableColumn *col = [self.tableView.tableColumns objectAtIndex:i];
        if (i < self.tableColTitle.count){
            col.title = [self.tableColTitle objectAtIndex:i];
        }else{
            col.title = @"NULL";
        }
    }
    
    self.removeBtn.enabled = NO;
    self.inputTxtField.placeholderString = @"Content For Schedule";
    __weak typeof(self) weakSelf = self;
    self.datePicker.MouseDownBlock = ^{
        [weakSelf datePickAction];
    };

//    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-Hans"];
//    [self.datePicker setLocale:locale];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
- (IBAction)addBtnAction:(id)sender
{
    NSDate *fireDate = self.datePicker.dateValue;
    if (self.additionalMinutes.stringValue && self.additionalMinutes.stringValue.length > 0) {
        NSInteger minutes = [self.additionalMinutes.stringValue integerValue];
        fireDate = [fireDate dateByAddingTimeInterval:minutes * 60];
    }
    
    if ([fireDate timeIntervalSinceNow] <= 0) {
        NSLog(@"Time Interval should not be a nagetive number.");
        return;
    }
    
    JKClockScheduleModel *model = [[JKClockScheduleModel alloc] init];
    model.fireDate = fireDate;
    model.textAlert = self.inputTxtField.stringValue;
    

    
    [self addScheduleModel:model];
    
    self.inputTxtField.stringValue = @"";
}

- (void)addScheduleModel:(JKClockScheduleModel *)model
{
    NSInteger index = 0;
    for (JKClockScheduleModel *curModel in self.scheduleArr) {
        NSComparisonResult result = [curModel.fireDate compare:model.fireDate];
        
        if (result == NSOrderedDescending) {
            break;
        }
        
        index ++;
    }
    [self postNotificationWithModel:model];
    [self.scheduleArr insertObject:model atIndex:index];
    
    [self.tableView reloadData];
}

- (IBAction)removeBtnAction:(id)sender
{
    if (self.tableView.selectedRow >= 0) {
        if (self.tableView.selectedRow < self.scheduleArr.count) {
            JKClockScheduleModel *model = [self.scheduleArr objectAtIndex:self.tableView.selectedRow];
            [self removeNotificationWithModel:model];
            [self.scheduleArr removeObjectAtIndex:self.tableView.selectedRow];
            
            [self.tableView beginUpdates];
            [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.tableView.selectedRow] withAnimation:NSTableViewAnimationEffectGap];
            [self.tableView endUpdates];
        }
    }
}

- (IBAction)resetBtnAction:(id)sender
{
    self.datePicker.dateValue = [NSDate date];
    self.additionalMinutes.stringValue = @"0";
    self.followTimer = YES;
    [self.datePicker.window makeFirstResponder:nil];
}

- (void)datePickAction
{
    self.followTimer = NO;
}

- (void)timerFire
{
    if (self.followTimer) {
        self.datePicker.dateValue = [NSDate date];
    }
    [self timeCheck];
}

- (void)timeCheck
{
    JKClockScheduleModel *model = [self obtainTimeTopSchedule];
    if (model) {
        [self showNotifyWithModel:model];
        NSLog(@"Action for model : %@",model.textAlert);
        [self timeCheck];
    }
}

- (void)showNotifyWithModel:(JKClockScheduleModel *)model
{
    if (!self.popOver) {
        //this method only for quick build view
        return;
    }
    self.notifyViewController.model = model;
    AppDelegate *del = [[NSApplication sharedApplication] delegate];
    NSStatusBarButton *btn = [del mainItemViewObject];
    [self.popOver showRelativeToRect:btn.bounds ofView:btn preferredEdge:NSRectEdgeMinY];
}

- (JKClockScheduleModel *)obtainTimeTopSchedule
{
    if (self.scheduleArr.count <= 0) {
        return nil;
    }
    
    JKClockScheduleModel *model = [self.scheduleArr firstObject];
    
    NSTimeInterval time = [model.fireDate timeIntervalSinceNow];
    if (ABS(time) < 1) {
        [self.scheduleArr removeObject:model];
        [self.tableView reloadData];
        return model;
    }
    return nil;
}

- (void)mouseDown:(NSEvent *)event
{
    [self.view.window makeFirstResponder:nil];
}

- (void)postNotificationWithModel:(JKClockScheduleModel *)model
{
    if (@available(macOS 10.14, *)) {
        
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"Alert" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:model.textAlert
                arguments:nil];
        
        NSTimeInterval interval = [model.fireDate timeIntervalSinceNow];
        
        UNTimeIntervalNotificationTrigger *timeIntervalTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:interval repeats:false];
        NSString *identifier = [NSString stringWithFormat:@"%ld",JKUserNotificationIdentify++];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                              content:content
                                                                              trigger:timeIntervalTrigger];
        model.identifier = identifier;
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request
                                                                       withCompletionHandler:^(NSError * _Nullable error) {
            if (error == nil) {
                NSLog(@"Notification add success.");
            }else{
                NSLog(@"Notification add failed: %@",error);
            }
        }] ;
        
    }else{
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"Your Schedule Alert";
        notification.subtitle = [self.formatter stringFromDate:model.fireDate];
        notification.informativeText = model.textAlert;
        notification.deliveryDate = model.fireDate;
        notification.identifier = [NSString stringWithFormat:@"%ld",JKUserNotificationIdentify++];
        
        model.identifier = notification.identifier;
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
    }
}

- (void)removeNotificationWithModel:(JKClockScheduleModel *)model
{
    if (!model || !model.identifier || model.identifier.length <= 0) {
        return;
    }
    if (@available(macOS 10.14, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[model.identifier]];
        [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[model.identifier]];
    }else{
        if (model.notification) {
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeScheduledNotification:model.notification];
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:model.notification];
        }
    }
}

#pragma mark - UNUserNotificationCenter Delegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
API_AVAILABLE(macos(10.14))
{
    NSLog(@"%s",__func__);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
API_AVAILABLE(macos(10.14))
{
    NSLog(@"%s",__func__);
}

#pragma mark - NSUserNotification delegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    for (JKClockScheduleModel *model in self.scheduleArr) {
        if ([model.identifier isEqualToString:notification.identifier]) {
            [self.scheduleArr removeObject:model];
            break;
        }
    }
    [self.tableView reloadData];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

#pragma mark - table delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if (self.tableView.selectedRow >= 0) {
        self.removeBtn.enabled = YES;
    }else{
        self.removeBtn.enabled = NO;
    }
}


#pragma mark - data delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.scheduleArr.count;
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (row >= self.scheduleArr.count) {
        return nil;
    }
    JKClockScheduleModel *scheduleM = [self.scheduleArr objectAtIndex:row];
    
    if ([tableColumn.title isEqualToString:[self.tableColTitle objectAtIndex:0]]){
        return [self.formatter stringFromDate:scheduleM.fireDate];
    }
    
    if ([tableColumn.title isEqualToString:[self.tableColTitle objectAtIndex:1]]){
        return (scheduleM.textAlert || scheduleM.textAlert.length > 0)?scheduleM.textAlert:@"Empty";
    }
    
    return nil;
}

#pragma mark - getter
- (NSMutableArray<JKClockScheduleModel *> *)scheduleArr
{
    if (!_scheduleArr){
        _scheduleArr = [NSMutableArray array];
    }
    return _scheduleArr;
}

- (NSPopover *)popOver
{
    if (!_popOver) {
        _popOver = [[NSPopover alloc] init];
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Clock" bundle:nil];
        JKClockNotificationViewController *vc = [sb instantiateControllerWithIdentifier:NSStringFromClass([JKClockNotificationViewController class])];
        self.notifyViewController = vc;
        __weak typeof(self) weakSelf = self;
        vc.CloseActionBlock = ^{
            [weakSelf.popOver performClose:nil];
        };
        vc.RemindMeLaterActionBlock = ^(JKClockNotificationViewController * _Nonnull vc, NSInteger minutes) {
            if (minutes <= 0) {
                return;
            }
            vc.model.fireDate = [[NSDate date] dateByAddingTimeInterval:minutes * 60];
            [weakSelf addScheduleModel:vc.model];
        };
        _popOver.contentViewController = vc;
    }
    return _popOver;
}
@end
