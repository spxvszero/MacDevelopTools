//
//  JKStatusIconManagerViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/25.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKStatusIconManagerViewController.h"
#import <ApplicationServices/ApplicationServices.h>


extern AXError _AXUIElementGetWindow(AXUIElementRef, CGWindowID* out);

@interface JKStatusIconManagerViewController ()<NSTableViewDelegate,NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

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
    [self windows];
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
//    _AXUIElementGetWindow((__bridge AXUIElementRef)NSApp.keyWindow, &windowId);
    
    NSDictionary *bounds = [dic objectForKey:@"kCGWindowBounds"];
    AXUIElementRef ref = AXUIElementCreateApplication([[dic objectForKey:@"kCGWindowOwnerPID"] intValue]);
    
    AXUIElementRef window;
    AXUIElementCopyElementAtPosition(ref, [[bounds objectForKey:@"X"] floatValue], [[bounds objectForKey:@"Y"] floatValue], &window);
    
    
    NSWindow *testWindow = [[NSWindow alloc]initWithWindowRef:window];
    
//    NSValue *value = [NSValue valueWithSize:NSMakeSize(100, 100)];
//    AXValueGetValue(sizeValue, kAXValueCGSizeType, &size);
//    AXError error = AXUIElementSetAttributeValue(window, kAXSizeAttribute
//                                 , AXValueCreate(kAXValueTypeCGSize, (CFTypeRef*)&value));
    
//    NSLog(@"application %@ --\n error : %d",window,error);
    
}


- (void)windows
{
    CFArrayRef windowsRef = CGWindowListCreateDescriptionFromArray(CGWindowListCreate(kCGWindowListOptionAll, kCGNullWindowID));
//    CFArrayRef windowsRef = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
    if (windowsRef) {
        self.dataArray = (__bridge NSArray *)windowsRef;
    }
    [self.tableView reloadData];
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
