//
//  JKImageInfoInspectorViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/29.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKImageInfoInspectorViewController.h"
#import "JKImageInfoCellView.h"

@interface JKKeyItemObject : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) id value;

+ (instancetype)itemWithKey:(NSString *)key value:(id)value;

@end
@implementation JKKeyItemObject
+ (instancetype)itemWithKey:(NSString *)key value:(id)value
{
    JKKeyItemObject *obj = [[JKKeyItemObject alloc] init];
    obj.key = key;
    obj.value = value;
    return obj;
}
@end


@interface JKImageInfoInspectorViewController ()<NSOutlineViewDelegate,NSOutlineViewDataSource>

@property (weak) IBOutlet NSOutlineView *outlineView;

@property (nonatomic, strong) NSMutableDictionary *keysFromDic;

@end

@implementation JKImageInfoInspectorViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.outlineView.delegate = self;
    self.outlineView.dataSource = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.keysFromDic = [NSMutableDictionary dictionary];
    
}

- (void)reloadData
{
    [self.keysFromDic removeAllObjects];
    [self.outlineView reloadData];
}


- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    if (item) {
        if ([item isKindOfClass:[JKKeyItemObject class]] && [[(JKKeyItemObject *)item value] isKindOfClass:[NSDictionary class]]) {
            NSString *key = [NSString stringWithFormat:@"%p",[(JKKeyItemObject *)item value]];
            if ([self.keysFromDic objectForKey:key]) {
                return [[self.keysFromDic objectForKey:key] count];
            }else{
                NSArray *allkeys = [[(JKKeyItemObject *)item value] allKeys];
                [self.keysFromDic setObject:allkeys forKey:key];
                return [allkeys count];
            }
        }else{
            return 0;
        }
    }else{
        if (self.dic) {
            NSString *key = [NSString stringWithFormat:@"%p",self.dic];
            if ([self.keysFromDic objectForKey:key]) {
                return [[self.keysFromDic objectForKey:key] count];
            }else{
                NSArray *allkeys = [self.dic allKeys];
                [self.keysFromDic setObject:allkeys forKey:key];
                return [allkeys count];
            }
        }else{
            return 0;
        }
    }
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    if ([item isKindOfClass:[JKKeyItemObject class]] && [[(JKKeyItemObject *)item value] isKindOfClass:[NSDictionary class]]) {
        NSString *arrayKey = [NSString stringWithFormat:@"%p",[(JKKeyItemObject *)item value]];
        NSString *key = [[self.keysFromDic objectForKey:arrayKey] objectAtIndex:index];
        id obj = [(NSDictionary *)[(JKKeyItemObject *)item value] objectForKey:key];
        return [JKKeyItemObject itemWithKey:key value:obj];
    }else{
        NSString *arrayKey = [NSString stringWithFormat:@"%p",self.dic];
        NSString *key = [[self.keysFromDic objectForKey:arrayKey] objectAtIndex:index];
        id obj = [self.dic objectForKey:key];
        return [JKKeyItemObject itemWithKey:key value:obj];
    }
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[JKKeyItemObject class]]) {
        JKKeyItemObject *itemObj = (JKKeyItemObject *)item;
        if ([itemObj.value isKindOfClass:[NSDictionary class]] && [[itemObj.value allKeys] count] > 0) {
            return YES;
        }
    }
    return NO;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(JKKeyItemObject *)item
{
    JKImageInfoCellView *reuseView = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if ([tableColumn.identifier isEqualToString:@"Key"]) {
        reuseView.textField.stringValue = item.key?:@"No Key";
    }else{
        if ([item.value isKindOfClass:[NSDictionary class]]) {
            reuseView.textField.stringValue = @"Dictionary";
        }else{
            reuseView.textField.stringValue = item.value?[NSString stringWithFormat:@"%@",item.value]:@"Null";
        }
    }
    
    [reuseView.textField sizeToFit];
    
    return reuseView;
}




@end
