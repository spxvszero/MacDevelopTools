//
//  JKJSONFormatViewController.m
//  MacDevelopTools
//
//  Created by 曾坚 on 2019/2/18.
//  Copyright © 2019年 JK. All rights reserved.
//

#import "JKJSONFormatViewController.h"
#import "JKJSONFormatCell.h"
#import "JKJSONFormatHistoryViewController.h"

@interface JKJSONFormatViewController ()<NSOutlineViewDelegate,NSOutlineViewDataSource,NSTextViewDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *txtView;
@property (weak) IBOutlet NSButton *formatBtn;
@property (weak) IBOutlet NSButton *historyBtn;

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, strong) JKJSONFormatHistoryViewController *historyVC;

@property (nonatomic, strong) id jsonModel;
@property (nonatomic, strong) NSString *originStr;
@property (nonatomic, strong) NSMutableDictionary *keysFromDic;

@property (nonatomic, weak) NSEvent *localEvent;

@end

@implementation JKJSONFormatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.outlineView.delegate = self;
    self.outlineView.dataSource = self;
    
    [self.outlineView setTarget:self]; // Needed if not done in IB
    [self.outlineView setAction:@selector(outlineViewClicked:)];
    [self.outlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    
    self.txtView.delegate = self;
    
    self.keysFromDic = [NSMutableDictionary dictionary];
    
    
    NSStoryboard *sb = [NSStoryboard storyboardWithName:@"JSONFormat" bundle:nil];
    self.historyVC = [sb instantiateControllerWithIdentifier:NSStringFromClass([JKJSONFormatHistoryViewController class])];
    [self.view addSubview:self.historyVC.view];
    
    self.historyVC.view.hidden = YES;
    self.historyVC.view.alphaValue = 0;
    
}

- (void)viewWillLayout
{
    [super viewWillLayout];
    
//    if (self.historyVC.view.hidden) {
//        self.historyBtn.frame = NSMakeRect(self.view.bounds.size.width - 10 - self.formatBtn.bounds.size.width, self.formatBtn.frame.origin.y, self.formatBtn.bounds.size.width, self.formatBtn.bounds.size.height);
//    }else{
//        self.historyBtn.frame = self.formatBtn.frame;
//    }
    
    self.historyVC.view.frame = CGRectMake(CGRectGetMaxX(self.formatBtn.frame), 0, self.view.bounds.size.width - CGRectGetMaxX(self.formatBtn.frame), self.view.bounds.size.height);
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    __weak typeof(self) weakSelf = self;
    self.localEvent = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent * _Nonnull evt) {
        
        if ([[[NSApplication sharedApplication] keyWindow] firstResponder] == weakSelf.outlineView) {
            
            if ((([evt modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask) == NSEventModifierFlagCommand) && [evt.characters isEqualToString:@"c"]) {
                
                if (weakSelf.outlineView.selectedRow >= 0) {
                    
                    id obj = [weakSelf.outlineView itemAtRow:[weakSelf.outlineView selectedRow]];
                    
                    if (obj && ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]])) {
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
                        if (jsonData) {
                            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            
                            [[NSPasteboard generalPasteboard] clearContents];
                            [[NSPasteboard generalPasteboard] writeObjects:@[jsonStr]];
                            
                            [weakSelf.outlineView deselectRow:[weakSelf.outlineView selectedRow]];
                            return nil;
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

- (void)textDidChange:(NSNotification *)notification
{
    if (notification.object == self.txtView) {
        self.originStr = self.txtView.string;
    }
}


- (void)outlineViewClicked:(NSOutlineView *)sender
{
    id clickItem = [sender itemAtRow:[self.outlineView clickedRow]];
    if (clickItem)
    {
        BOOL optionPressed = (([[NSApp currentEvent] modifierFlags] & NSEventModifierFlagOption) == NSEventModifierFlagOption);
        
        [sender isItemExpanded:clickItem] ?
        [sender.animator collapseItem:clickItem collapseChildren:optionPressed] :
        [sender.animator expandItem:clickItem expandChildren:optionPressed];
    }
}


- (IBAction)formatBtnAction:(id)sender
{
    if (self.originStr && self.originStr.length > 0) {
        
        self.jsonModel = [NSJSONSerialization JSONObjectWithData:[self.originStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:nil];
        
//        [self changeTextString];
        
        [self.historyVC addHistory:[self.originStr copy]];
        
        [self.keysFromDic removeAllObjects];
        [self.outlineView reloadData];
    }
}

- (void)changeTextString
{
    self.txtView.string = [self.originStr stringByReplacingOccurrencesOfString:@"{" withString:@"{\n"];
}

- (void)expandOutlineViewWithLevel:(NSInteger)level
{
    [self.outlineView expandItem:nil expandChildren:YES];
    
}

- (IBAction)historyBtnAction:(id)sender
{
    if (self.historyVC.view.hidden) {
        [self.historyVC reloadData];
        self.historyVC.view.hidden = NO;
        __weak typeof(self) weakSelf = self;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            [[weakSelf.historyBtn animator] setFrame:weakSelf.formatBtn.frame];
            [[weakSelf.formatBtn animator] setAlphaValue:0];
            [[weakSelf.historyBtn animator] setTitle:@"Cancel"];
            [[weakSelf.historyVC.view animator] setAlphaValue:1];
        } completionHandler:^{
            
        }];
    }else{
        
        __weak typeof(self) weakSelf = self;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            [[weakSelf.historyBtn animator] setFrame:NSMakeRect(weakSelf.view.bounds.size.width - 10 - weakSelf.formatBtn.bounds.size.width, weakSelf.formatBtn.frame.origin.y, weakSelf.formatBtn.bounds.size.width, weakSelf.formatBtn.bounds.size.height)];
            [[weakSelf.formatBtn animator] setAlphaValue:1];
            [[weakSelf.historyBtn animator] setTitle:@"History"];
            [[weakSelf.historyVC.view animator] setAlphaValue:0];
        } completionHandler:^{
            weakSelf.historyVC.view.hidden = YES;
        }];
        
    }
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
        if (self.jsonModel) {
            
            NSString *key = [NSString stringWithFormat:@"%p",self.jsonModel];
            id obj = [self.keysFromDic objectForKey:key];
            
            if (obj) {
                if ([obj isKindOfClass:[NSArray class]]) {
                    return [(NSArray *)obj count];
                }else{
                    return [[(NSDictionary *)obj allKeys] count];
                }
            }else{
                if ([self.jsonModel isKindOfClass:[NSArray class]]) {
                    [self.keysFromDic setObject:self.jsonModel forKey:key];
                    return [(NSArray *)self.jsonModel count];
                }else{
                    NSArray *arr = [(NSDictionary *)self.jsonModel allKeys];
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
        item = self.jsonModel;
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
    JKJSONFormatCell *reuseView = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if ([tableColumn.identifier isEqualToString:@"Key"]) {
        reuseView.textField.stringValue = [[item allKeys] firstObject]?:@"No Key";
    }else{
        id value = [[item allValues] firstObject];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            reuseView.textField.stringValue = @"Dictionary";
        }else if([value isKindOfClass:[NSArray class]]){
            reuseView.textField.stringValue = [NSString stringWithFormat:@"Array[%ld]",[(NSArray *)value count]];
        }else{
            reuseView.textField.stringValue = value?[NSString stringWithFormat:@"%@",value]:@"Null";
        }
    }
    
    [reuseView.textField sizeToFit];
    
    return reuseView;
}

@end
