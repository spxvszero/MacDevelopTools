//
//  JKStatusIconManagerViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/25.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKStatusIconManagerViewController.h"
#import <ApplicationServices/ApplicationServices.h>

#import "AppDelegate.h"
extern AXError _AXUIElementGetWindow(AXUIElementRef, CGWindowID* out);

@interface JKStatusIconManagerViewController ()<NSTableViewDelegate,NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation JKStatusIconManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    
}
- (IBAction)buttonAction:(id)sender
{
    [(AppDelegate *)[NSApplication sharedApplication].delegate buildTestItem];
//    [self windows];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.dataArray.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"test" owner:nil];
    
    id obj = [self.dataArray objectAtIndex:row];
    cellView.textField.stringValue = [obj objectForKey:@"kCGWindowOwnerName"]?:@"Null";
    
    return cellView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSDictionary *dic = [self.dataArray objectAtIndex:self.tableView.selectedRow];
    NSLog(@"value -- %@",dic);

//    CGWindowID windowId;
    CFNumberRef pidRef =(__bridge CFNumberRef)([dic objectForKey:@"kCGWindowOwnerPID"]);
    NSNumber *pid = (__bridge NSNumber *)pidRef;
    AXUIElementRef ref = AXUIElementCreateApplication([pid intValue]);
    
//    NSDictionary *bounds = [dic objectForKey:@"kCGWindowBounds"];
//    AXUIElementRef ref = AXUIElementCreateApplication([[dic objectForKey:@"kCGWindowOwnerPID"] intValue]);
//
//    AXUIElementRef window;
//    CFNumberRef xObj = (__bridge CFNumberRef)([bounds objectForKey:@"X"]);
//    NSNumber *XValue = (__bridge NSNumber *)xObj;
//    CFNumberRef yObj = (__bridge CFNumberRef)([bounds objectForKey:@"Y"]);
//    NSNumber *YValue = (__bridge NSNumber *)yObj;
//    AXUIElementCopyElementAtPosition(ref, [XValue floatValue], [YValue floatValue], &window);
    
    NSLog(@"pid",ref);
//    NSWindow *testWindow = [[NSWindow alloc] initWithWindowRef:window];
    
//    NSValue *value = [NSValue valueWithSize:NSMakeSize(100, 100)];
//    AXValueGetValue(sizeValue, kAXValueCGSizeType, &size);
//    AXError error = AXUIElementSetAttributeValue(window, kAXSizeAttribute
//                                 , AXValueCreate(kAXValueTypeCGSize, (CFTypeRef*)&value));
    
//    NSLog(@"application %@ --\n error : %d",window,error);
    
}


- (void)windows
{
//    NSWindow *window = NSApplication.sharedApplication.windows.firstObject;
//    CFArrayRef windowsRef = CGWindowListCreateDescriptionFromArray(CGWindowListCreate(kCGWindowListOptionAll, kCGNullWindowID));
    CFArrayRef windowsRef = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
    if (windowsRef) {
        [self.dataArray removeAllObjects];
        NSArray *arr = (__bridge NSArray *)windowsRef;
        NSString *windowLayer = (__bridge NSString *)kCGWindowLayer;
        for (NSDictionary *dic in arr) {
            if ([[dic objectForKey:windowLayer] integerValue] == kCGStatusWindowLevel ) {
                [self.dataArray addObject:dic];
            }
        }
//        self.dataArray = (__bridge NSArray *)windowsRef;
    }
    
    id value = [[NSStatusBar systemStatusBar] performSelector:@selector(_statusItems) withObject:nil];
    [self.tableView reloadData];
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


- (void)applications
{
    id applications = [NSRunningApplication valueForKey:@"allApplications"];
    if (applications) {
        self.dataArray = (__bridge NSArray *)(__bridge CFArrayRef)applications;
    }
    [self.tableView reloadData];
}
@end
