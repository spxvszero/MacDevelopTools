//
//  JKJSONFormatHistoryViewController.m
//  MacDevelopTools
//
//  Created by 曾坚 on 2019/2/18.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKJSONFormatHistoryViewController.h"
#import "JKJSONFormatCell.h"

@interface JKJSONFormatHistoryViewController ()<NSOutlineViewDelegate,NSOutlineViewDataSource>

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, strong) NSMutableDictionary *historyDic;

@property (nonatomic, strong) NSMutableDictionary *keysFromDic;

@property (nonatomic, weak) NSEvent *localEvent;

@end

@implementation JKJSONFormatHistoryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.outlineView.delegate = self;
    self.outlineView.dataSource = self;
    self.outlineView.target = self;
    self.outlineView.doubleAction = @selector(oulineViewClickAction);
    
    self.keysFromDic = [NSMutableDictionary dictionary];
    
}

- (void)reloadData
{
    [self.keysFromDic removeAllObjects];
    [self.outlineView reloadData];
}

- (void)oulineViewClickAction
{
    id clickItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    
    if (clickItem && [clickItem isKindOfClass:[NSDictionary class]]) {
        
        NSString *key = [[(NSDictionary *)clickItem allKeys] firstObject];
        
        if ([key isEqualToString:@"value"]) {
            if (self.SelectStrBlock) {
                self.SelectStrBlock(self, [(NSDictionary *)clickItem objectForKey:key]);
            }
        }
    }
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    __weak typeof(self) weakSelf = self;
    self.localEvent = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent *evt) {
        
        if ([[[NSApplication sharedApplication] keyWindow] firstResponder] == weakSelf.outlineView) {
            
            if (evt.keyCode == 0x33) {
                
                if (weakSelf.outlineView.selectedRow >= 0) {
                    
                    id obj = [weakSelf.outlineView itemAtRow:[weakSelf.outlineView selectedRow]];
                    
                    if (obj && ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]])) {
                        
                        if ([weakSelf.outlineView isExpandable:obj]) {
                            [weakSelf removeHistory:obj index:-1];
                        }else{
                            id parentObj = [weakSelf.outlineView parentForItem:obj];
                            
                            NSInteger childIndex = [weakSelf.outlineView childIndexForItem:obj];
                            
                            [weakSelf removeHistory:parentObj index:childIndex];
                            
                        }
                    }
                }
            }
        }
        
        return evt;
    }];
        
}

- (void)viewWillDisappear
{
    [super viewWillDisappear];
    
    [NSEvent removeMonitor:self.localEvent];
}


- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    if (item) {
        
        id value = [[(NSDictionary *)item allValues] firstObject];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            
            NSString *key = [NSString stringWithFormat:@"%p",value];
            if ([self.keysFromDic objectForKey:key]) {
                return [[self.keysFromDic objectForKey:key] count];
            }else{
                NSArray *allkeys = [(NSDictionary *)value allKeys];
                [self.keysFromDic setObject:allkeys forKey:key];
                return [allkeys count];
            }
        }
        
        if ([value isKindOfClass:[NSArray class]]) {
            return [(NSArray *)value count];
        }
        
        return 0;
        
        
    }else{
        if (self.historyDic) {
            
            NSString *key = [NSString stringWithFormat:@"%p",self.historyDic];
            id obj = [self.keysFromDic objectForKey:key];
            
            if (obj) {
                if ([obj isKindOfClass:[NSArray class]]) {
                    return [(NSArray *)obj count];
                }else{
                    return [[(NSDictionary *)obj allKeys] count];
                }
            }else{
                if ([self.historyDic isKindOfClass:[NSArray class]]) {
                    [self.keysFromDic setObject:self.historyDic forKey:key];
                    return [(NSArray *)self.historyDic count];
                }else{
                    NSArray *arr = [(NSDictionary *)self.historyDic allKeys];
                    [self.keysFromDic setObject:arr forKey:key];
                    return [arr count];
                }
            }
        }else{
            return 0;
        }
    }
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    if (!item) {
        item = self.historyDic;
    }else{
        item = [[(NSDictionary *)item allValues] firstObject];
    }
    
    if ([item isKindOfClass:[NSDictionary class]]) {
        NSString *arrayKey = [NSString stringWithFormat:@"%p",item];
        NSString *key = [[self.keysFromDic objectForKey:arrayKey] objectAtIndex:index];
        /////return dictionary
        return [NSDictionary dictionaryWithObject:[item objectForKey:key] forKey:key];
    }
    
    if ([item isKindOfClass:[NSArray class]]) {
//        return [NSDictionary dictionaryWithObject:[(NSArray *)item objectAtIndex:index] forKey:[NSString stringWithFormat:@"[%ld]",(long)index]];;
        return [NSDictionary dictionaryWithObject:[(NSArray *)item objectAtIndex:index] forKey:[NSString stringWithFormat:@"value"]];;
    }
    
    return @"";
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(NSDictionary *)item
{
    id value = [[item allValues] firstObject];
    
    if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    return NO;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(NSDictionary *)item
{
    JKJSONFormatCell *reuseView = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    id key = [[item allKeys] firstObject];
    id value = [[item allValues] firstObject];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        reuseView.textField.stringValue = @"Dictionary";
    }else if([value isKindOfClass:[NSArray class]]){
        reuseView.textField.stringValue = key?:@"NO KEY";
    }else{
        reuseView.textField.stringValue = value?[NSString stringWithFormat:@"%@",value]:@"Null";
    }
    
    [reuseView.textField sizeToFit];
    
    return reuseView;
}

#pragma mark - history

- (void)addHistory:(NSString *)jsonStr
{
    NSMutableArray *historyArr = [self obtainHistoryArr];
    
    BOOL duplicate = NO;
    
    for (NSString *str in historyArr) {
        if ([str isEqualToString:jsonStr]) {
            duplicate = YES;
        }
    }
    
    if (!duplicate) {
        [historyArr addObject:jsonStr];
    }
}

- (void)removeHistory:(id)obj index:(NSInteger)index
{
    id value = [[(NSDictionary *)obj allValues] firstObject];
    if (index < 0) {
        NSArray *allKeys = [self.historyDic allKeys];
        for (NSString *key in allKeys) {
            id innervalue = [self.historyDic objectForKey:key];
            if (value == innervalue) {
                [self.historyDic removeObjectForKey:key];
                break;
            }
        }
    }else{
        if ([value isKindOfClass:[NSArray class]]) {
            if ([(NSArray *)value count] > 1 && (index < [(NSArray *)value count])) {
                
                [(NSMutableArray *)value removeObjectAtIndex:index];
                
            }else{
                NSArray *allKeys = [self.historyDic allKeys];
                for (NSString *key in allKeys) {
                    id innervalue = [self.historyDic objectForKey:key];
                    if (value == innervalue) {
                        [self.historyDic removeObjectForKey:key];
                        break;
                    }
                }
            }
        }
    }
    
    [self reloadData];
}

- (NSMutableArray *)obtainHistoryArr
{
    NSString *key = [self dateStr];
    
    NSMutableArray *arr = [self.historyDic objectForKey:key];
    if (!arr) {
        arr = [NSMutableArray array];
        [self.historyDic setObject:arr forKey:key];
    }
    
    return arr;
}

- (NSString *)dateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:[NSDate date]];
}

- (NSMutableDictionary *)historyDic
{
    if (!_historyDic) {
        _historyDic = [NSMutableDictionary dictionary];
    }
    return _historyDic;
}

@end
