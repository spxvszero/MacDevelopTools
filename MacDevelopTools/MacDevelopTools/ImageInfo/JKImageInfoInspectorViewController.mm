//
//  JKImageInfoInspectorViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/29.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKImageInfoInspectorViewController.h"

@interface JKImageInfoInspectorViewController ()<NSOutlineViewDelegate,NSOutlineViewDataSource>

@property (weak) IBOutlet NSOutlineView *outlineView;

@property (nonatomic, strong) NSDictionary *dic;

@end

@implementation JKImageInfoInspectorViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.dic = @{@"root":@{@"child":@"1",@"child":@"2",@"child":@"3",@"child":@"4"},@"root2":@"???"};
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.outlineView.delegate = self;
    self.outlineView.dataSource = self;
    
    
    
}

- (void)reloadData
{
    [self.outlineView reloadData];
}


/* NOTE: it is not acceptable to call reloadData or reloadItem from the implementation of any of the following four methods, and doing so can cause corruption in NSOutlineViews internal structures.
 */

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    if (item) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            return [[(NSDictionary *)item allKeys] count];
        }else{
            return 0;
        }
    }else{
        return [[self.dic allKeys] count];
    }
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    if ([item isKindOfClass:[NSDictionary class]]) {
        NSString *key = [[item allKeys] objectAtIndex:index];
        return [(NSDictionary *)item objectForKey:key];
    }else{
        NSString *key = [[self.dic allKeys] objectAtIndex:index];
        return [self.dic objectForKey:key];
    }
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[NSDictionary class]]) {
        return YES;
    }else{
        return NO;
    }
}

/* NOTE: this method is optional for the View Based OutlineView.
 */
- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item
{
    NSTableCellView *reuseView = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];

    if ([tableColumn.identifier isEqualToString:@"Key"]) {
        reuseView.textField.stringValue = @"key";
    }else{
        reuseView.textField.stringValue = @"value";
    }
    
    [reuseView.textField sizeToFit];
    
//    NSTextField *tf = [[NSTextField alloc] init];
//    tf.editable = NO;
//    tf.stringValue = @"asdfffff";
//    tf.textColor = [NSColor blackColor];
    
    return reuseView;
}


@end
