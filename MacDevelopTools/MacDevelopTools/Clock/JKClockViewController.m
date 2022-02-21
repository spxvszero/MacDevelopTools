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

@interface JKClockScheduleModel : NSObject

@property (nonatomic, strong) NSDate *fireDate;
@property (nonatomic, strong) NSString *textAlert;
@property (nonatomic, strong) NSUserNotification *notification;

@end
@implementation JKClockScheduleModel
@end

static NSInteger JKUserNotificationIdentify = 0;

@interface JKClockViewController ()<NSTableViewDataSource,NSTableViewDelegate,NSUserNotificationCenterDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet JKDatePicker *datePicker;
@property (weak) IBOutlet NSTextField *inputTxtField;
@property (weak) IBOutlet NSButton *removeBtn;
@property (weak) IBOutlet NSButton *addBtn;
@property (weak) IBOutlet NSTableView *contentTableView;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL followTimer;

@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSArray *tableColTitle;
@property (nonatomic, strong) NSMutableArray<JKClockScheduleModel *> *scheduleArr;

@end

@implementation JKClockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
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
    JKClockScheduleModel *model = [[JKClockScheduleModel alloc] init];
    model.fireDate = self.datePicker.dateValue;
    model.textAlert = self.inputTxtField.stringValue;
    
    [self addScheduleModel:model];
    
    self.inputTxtField.stringValue = @"";
    
    [self.tableView reloadData];
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
}

- (void)timeCheck
{
    JKClockScheduleModel *model = [self obtainTimeTopSchedule];
    if (model) {
        [self postNotificationWithModel:model];
        [self timeCheck];
    }
}

- (JKClockScheduleModel *)obtainTimeTopSchedule
{
    if (self.scheduleArr.count <= 0) {
        return nil;
    }
    
    JKClockScheduleModel *model = [self.scheduleArr firstObject];
    
    NSString *scheduleTime = [self.formatter stringFromDate:model.fireDate];
    NSString *curTime = [self.formatter stringFromDate:[NSDate date]];
    if ([scheduleTime isEqualToString:curTime]) {
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
        content.title = [NSString localizedUserNotificationStringForKey:@"Wake up!" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:@"Rise and shine! It's morning time!"
                arguments:nil];
         
//        // Configure the trigger for a 7am wakeup.
//        NSDateComponents* date = [[NSDateComponents alloc] init];
//        date.hour = 7;
//        date.minute = 0;
//        UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger
//               triggerWithDateMatchingComponents:date repeats:NO];
         
        // Create the request object.
//        UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"MorningAlarm" content:content trigger:trigger];
        
        UNTimeIntervalNotificationTrigger *timeIntervalTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:false];
        
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"test" content:content trigger:timeIntervalTrigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request
                                                                       withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"Notification : %@",error);
        }] ;
        

        
    }else{
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"Your Schedule Alert";
        notification.subtitle = [self.formatter stringFromDate:model.fireDate];
        notification.informativeText = model.textAlert;
        notification.deliveryDate = model.fireDate;
        notification.identifier = [NSString stringWithFormat:@"%ld",JKUserNotificationIdentify++];
        
        model.notification = notification;
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
    }
}

- (void)removeNotificationWithModel:(JKClockScheduleModel *)model
{
    if (model.notification) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeScheduledNotification:model.notification];
    }
}

#pragma mark - notification delegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    for (JKClockScheduleModel *model in self.scheduleArr) {
        if ([model.notification.identifier isEqualToString:notification.identifier]) {
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
@end
