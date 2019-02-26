//
//  JKShellManagerViewController.m
//  MacDevelopTools
//
//  Created by jacky on 2019/2/19.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKShellManagerViewController.h"
#import "JKShellManagerCell.h"

@interface JKShellManagerViewController ()<NSOutlineViewDelegate,NSOutlineViewDataSource>

@property (weak) IBOutlet NSOutlineView *outlineView;

@property (nonatomic, strong) NSMutableDictionary *dataDic;
@property (nonatomic, strong) NSMutableDictionary *keysFromDic;

@end

@implementation JKShellManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.dataDic = [NSMutableDictionary dictionary];
    
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
}


#pragma mark - ouline delegate


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
        if (self.dataDic) {
            
            NSString *key = [NSString stringWithFormat:@"%p",self.dataDic];
            id obj = [self.keysFromDic objectForKey:key];
            
            if (obj) {
                if ([obj isKindOfClass:[NSArray class]]) {
                    return [(NSArray *)obj count];
                }else{
                    return [[(NSDictionary *)obj allKeys] count];
                }
            }else{
                if ([self.dataDic isKindOfClass:[NSArray class]]) {
                    [self.keysFromDic setObject:self.dataDic forKey:key];
                    return [(NSArray *)self.dataDic count];
                }else{
                    NSArray *arr = [(NSDictionary *)self.dataDic allKeys];
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
        item = self.dataDic;
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
        return [NSDictionary dictionaryWithObject:[(NSArray *)item objectAtIndex:index] forKey:[NSString stringWithFormat:@"[%ld]",(long)index]];;
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
    JKShellManagerCell *reuseView = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
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

- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
    
}


@end
