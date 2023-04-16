//
//  JKGTranslateViewController.m
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/4/14.
//  Copyright © 2023 JK. All rights reserved.
//

#import "JKGTranslateViewController.h"
#import "JKGTranslateProxyEditViewController.h"
#import "JKGTranslateStorage.h"
#import "libgtranslate.h"
#import "JKProxyModel.h"

@interface JKGTranslateViewController ()<NSComboBoxDelegate, NSComboBoxDataSource>

@property (unsafe_unretained) IBOutlet NSTextView *inputTxtView;
@property (unsafe_unretained) IBOutlet NSTextView *outputTxtView;

@property (weak) IBOutlet NSButton *proxyStatusBtn;
@property (nonatomic, strong) JKGTranslateProxyEditViewController *proxyEditViewController;
@property (nonatomic, strong) JKProxyModel *proxyModel;
@property (nonatomic, assign) NSInteger reqIdentify;

@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSButton *translateBtn;
@property (weak) IBOutlet NSComboBox *targetLanguageComboBox;

@property (nonatomic, strong) NSMutableArray *itemsArr;
@property (nonatomic, assign) NSInteger foundIdx;

@property (nonatomic, strong) NSArray *lanDatas;

@end

@implementation JKGTranslateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.foundIdx = NSNotFound;
    [self serializeDatas];
    self.targetLanguageComboBox.usesDataSource = true;
    self.targetLanguageComboBox.delegate = self;
    self.targetLanguageComboBox.completes = true;
    self.targetLanguageComboBox.dataSource = self;
    self.indicator.usesThreadedAnimation = true;
    self.indicator.displayedWhenStopped = false;
    
    self.proxyModel = [[JKProxyModel alloc] initWithFileString:[JKGTranslateStorage readProxyFromDisk]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.targetLanguageComboBox selectItemAtIndex:18];
    });
}

- (IBAction)translateAction:(id)sender {
    if (self.foundIdx == NSNotFound) {
        NSLog(@"Did not selected a target language. ");
        return;
    }
    
    NSString *str = self.inputTxtView.string;
    if (str == nil || str.length <= 0) {
        NSLog(@"Input String is empty.");
        return;
    }
    
    NSDictionary *lan = [self.lanDatas objectAtIndex:self.foundIdx];
    NSString *targetLan = lan[@"abbr"];
    
    NSLog(@"Current selected : %ld ",self.targetLanguageComboBox.indexOfSelectedItem);
    NSLog(@"Translate To -- %@",targetLan);
    
    NSString *proxyHost = nil;
    NSString *proxyUsername = nil;
    NSString *proxyPassword = nil;
    if (self.proxyStatusBtn.state == NSControlStateValueOn) {
        proxyHost = [self.proxyModel.host copy];
        proxyUsername = [self.proxyModel.username copy];
        proxyPassword = [self.proxyModel.password copy];
    }
    
    [self.indicator startAnimation:nil];
    
    __weak typeof(self) weakSelf = self;
    NSInteger cur_id = arc4random();
    self.reqIdentify = cur_id;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        const char *proxyChar = nil;
        if (proxyHost && proxyHost.length > 0) {
            proxyChar = [proxyHost cStringUsingEncoding:NSUTF8StringEncoding];
        }
        const char *proxyUsernameChar = nil;
        if (proxyUsername && proxyUsername.length > 0) {
            proxyUsernameChar = [proxyUsername cStringUsingEncoding:NSUTF8StringEncoding];
        }
        const char *proxyPasswordChar = nil;
        if (proxyPassword && proxyPassword.length > 0) {
            proxyPasswordChar = [proxyPassword cStringUsingEncoding:NSUTF8StringEncoding];
        }
        char *res = translation((char *)[targetLan cStringUsingEncoding:NSUTF8StringEncoding],
                                (char *)proxyChar,
                                (char *)proxyUsernameChar,
                                (char *)proxyPasswordChar,
                                (char *)[str cStringUsingEncoding:NSUTF8StringEncoding]);
        if (res == nil) {
            NSLog(@"Failed For Translate.");
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.indicator stopAnimation:nil];
            });
            return;
        }
        NSLog(@"Get Result : %s",res);
        NSString *resStr = [[NSString alloc] initWithCString:res encoding:NSUTF8StringEncoding];
        destoryCString(res);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cur_id != self.reqIdentify) {
                return;
            }
            weakSelf.outputTxtView.string = resStr;
            [weakSelf.indicator stopAnimation:nil];
        });
    });
    
}


- (IBAction)proxyBtnAction:(id)sender {
    [self showProxyEditViewController];
}
- (IBAction)proxyStatusBtnAction:(id)sender {
    if (self.proxyStatusBtn.state == NSControlStateValueOn) {
        self.proxyStatusBtn.title = @"On";
    }else{
        self.proxyStatusBtn.title = @"Off";
    }
}
- (IBAction)switchBtnAction:(id)sender {
    NSString *input = [self.inputTxtView.string copy];
    self.inputTxtView.string = self.outputTxtView.string;
    self.outputTxtView.string = input;
}

- (void)serializeDatas
{
    self.itemsArr = [NSMutableArray array];
    for (NSDictionary *lan in self.lanDatas) {
        NSString *item = [NSString stringWithFormat:@"%@_%@",lan[@"abbr"],lan[@"lan_zh"]];
        [self.itemsArr addObject:item];
    }
}

- (void)showProxyEditViewController
{
    self.proxyEditViewController.currentProxy = self.proxyModel;
    [self presentViewControllerAsSheet:self.proxyEditViewController];
}

#pragma mark - Combo Box Delegate
- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    if (notification && notification.object && notification.object == self.targetLanguageComboBox) {
        self.foundIdx = self.targetLanguageComboBox.indexOfSelectedItem;
    }
}
#pragma mark - Combo Box Data Source

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox
{
    return self.itemsArr.count;
}

- (nullable id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index
{
    return self.itemsArr[index];
}

- (NSUInteger)comboBox:(NSComboBox *)comboBox indexOfItemWithStringValue:(NSString *)string
{
    return self.foundIdx;
}

- (nullable NSString *)comboBox:(NSComboBox *)comboBox completedString:(NSString *)string
{
    NSString *found = nil;
    NSInteger idx = 0;
    for (NSString *str in self.itemsArr) {
        if ([str containsString:string]) {
            found = str;
            break;
        }
        idx ++;
    }
    
    if (found != nil) {
        [comboBox scrollItemAtIndexToTop:idx];
        self.foundIdx = idx;
//        [comboBox selectItemWithObjectValue:found];
    }else{
        self.foundIdx = NSNotFound;
    }
    
    return found;
}


- (JKGTranslateProxyEditViewController *)proxyEditViewController
{
    if (!_proxyEditViewController) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"GTranslate" bundle:nil];
        _proxyEditViewController = [sb instantiateControllerWithIdentifier:@"JKGTranslateProxyEditViewController"];
        __weak typeof(self) weakSelf = self;
        _proxyEditViewController.FinishEditActionBlock = ^(BOOL ok, JKProxyModel * _Nullable nPorxy) {
            if (ok) {
                weakSelf.proxyModel = nPorxy;
                [JKGTranslateStorage saveProxyToDisk:[nPorxy fileString]];
            }
        };
    }
    return _proxyEditViewController;
}

- (NSArray *)lanDatas
{
    if (!_lanDatas) {
       _lanDatas = @[
            @{@"lan_en":@"Afrikaans",@"lan_zh":@"南非公用荷兰语",@"abbr":@"af"},
            @{@"lan_en":@"Irish",@"lan_zh":@"爱尔兰语",@"abbr":@"ga"},
            @{@"lan_en":@"Albanian",@"lan_zh":@"阿尔巴尼亚语",@"abbr":@"sq"},
            @{@"lan_en":@"Italian",@"lan_zh":@"意大利语",@"abbr":@"it"},
            @{@"lan_en":@"Arabic",@"lan_zh":@"阿拉伯语",@"abbr":@"ar"},
            @{@"lan_en":@"Japanese",@"lan_zh":@"日语",@"abbr":@"ja"},
            @{@"lan_en":@"Azerbaijani",@"lan_zh":@"阿塞拜疆语",@"abbr":@"az"},
            @{@"lan_en":@"Kannada",@"lan_zh":@"卡纳达语",@"abbr":@"kn"},
            @{@"lan_en":@"Basque",@"lan_zh":@"巴斯克语",@"abbr":@"eu"},
            @{@"lan_en":@"Korean",@"lan_zh":@"韩语",@"abbr":@"ko"},
            @{@"lan_en":@"Bengali",@"lan_zh":@"孟加拉语",@"abbr":@"bn"},
            @{@"lan_en":@"Latin",@"lan_zh":@"拉丁文",@"abbr":@"la"},
            @{@"lan_en":@"Belarusian",@"lan_zh":@"白俄罗斯语",@"abbr":@"be"},
            @{@"lan_en":@"Latvian",@"lan_zh":@"拉脱维亚语",@"abbr":@"lv"},
            @{@"lan_en":@"Bulgarian",@"lan_zh":@"保加利亚语",@"abbr":@"bg"},
            @{@"lan_en":@"Lithuanian",@"lan_zh":@"立陶宛语",@"abbr":@"lt"},
            @{@"lan_en":@"Catalan",@"lan_zh":@"加泰罗尼亚语",@"abbr":@"ca"},
            @{@"lan_en":@"Macedonian",@"lan_zh":@"马其顿语",@"abbr":@"mk"},
            @{@"lan_en":@"Chinese Simplified",@"lan_zh":@"简体中文",@"abbr":@"zhHans"},
            @{@"lan_en":@"Malay",@"lan_zh":@"马来西亚语",@"abbr":@"ms"},
            @{@"lan_en":@"Chinese Traditional",@"lan_zh":@"繁体中文",@"abbr":@"zhHant"},
            @{@"lan_en":@"Maltese",@"lan_zh":@"马耳他语",@"abbr":@"mt"},
            @{@"lan_en":@"Croatian",@"lan_zh":@"克罗地亚语",@"abbr":@"hr"},
            @{@"lan_en":@"Norwegian",@"lan_zh":@"挪威文",@"abbr":@"no"},
            @{@"lan_en":@"Czech",@"lan_zh":@"捷克语",@"abbr":@"cs"},
            @{@"lan_en":@"Persian",@"lan_zh":@"波斯语",@"abbr":@"fa"},
            @{@"lan_en":@"Danish",@"lan_zh":@"丹麦语",@"abbr":@"da"},
            @{@"lan_en":@"Polish",@"lan_zh":@"波兰语",@"abbr":@"pl"},
            @{@"lan_en":@"Dutch",@"lan_zh":@"荷兰语",@"abbr":@"nl"},
            @{@"lan_en":@"Portuguese",@"lan_zh":@"葡萄牙语",@"abbr":@"pt"},
            @{@"lan_en":@"English",@"lan_zh":@"英文",@"abbr":@"en"},
            @{@"lan_en":@"Romanian",@"lan_zh":@"罗马尼亚语",@"abbr":@"ro"},
            @{@"lan_en":@"Esperanto",@"lan_zh":@"世界语",@"abbr":@"eo"},
            @{@"lan_en":@"Russian",@"lan_zh":@"俄语",@"abbr":@"ru"},
            @{@"lan_en":@"Estonian",@"lan_zh":@"爱沙尼亚语",@"abbr":@"et"},
            @{@"lan_en":@"Serbian",@"lan_zh":@"塞尔维亚语",@"abbr":@"sr"},
            @{@"lan_en":@"Filipino",@"lan_zh":@"菲律宾语",@"abbr":@"tl"},
            @{@"lan_en":@"Slovak",@"lan_zh":@"斯洛伐克语",@"abbr":@"sk"},
            @{@"lan_en":@"Finnish",@"lan_zh":@"芬兰语",@"abbr":@"fi"},
            @{@"lan_en":@"Slovenian",@"lan_zh":@"斯洛文尼亚语",@"abbr":@"sl"},
            @{@"lan_en":@"French",@"lan_zh":@"法语",@"abbr":@"fr"},
            @{@"lan_en":@"Spanish",@"lan_zh":@"西班牙语",@"abbr":@"es"},
            @{@"lan_en":@"Galician",@"lan_zh":@"加利西亚语",@"abbr":@"gl"},
            @{@"lan_en":@"Swahili",@"lan_zh":@"斯瓦希里语",@"abbr":@"sw"},
            @{@"lan_en":@"Georgian",@"lan_zh":@"格鲁吉亚语",@"abbr":@"ka"},
            @{@"lan_en":@"Swedish",@"lan_zh":@"瑞典语",@"abbr":@"sv"},
            @{@"lan_en":@"German",@"lan_zh":@"德语",@"abbr":@"de"},
            @{@"lan_en":@"Tamil",@"lan_zh":@"泰米尔语",@"abbr":@"ta"},
            @{@"lan_en":@"Greek",@"lan_zh":@"希腊语",@"abbr":@"el"},
            @{@"lan_en":@"Telugu",@"lan_zh":@"泰卢固语",@"abbr":@"te"},
            @{@"lan_en":@"Gujarati",@"lan_zh":@"古吉拉特语",@"abbr":@"gu"},
            @{@"lan_en":@"Thai",@"lan_zh":@"泰语",@"abbr":@"th"},
            @{@"lan_en":@"Haitian Creole",@"lan_zh":@"海地克里奥尔语",@"abbr":@"ht"},
            @{@"lan_en":@"Turkish",@"lan_zh":@"土耳其语",@"abbr":@"tr"},
            @{@"lan_en":@"Hebrew",@"lan_zh":@"希伯来语",@"abbr":@"iw"},
            @{@"lan_en":@"Ukrainian",@"lan_zh":@"乌克兰语",@"abbr":@"uk"},
            @{@"lan_en":@"Hindi",@"lan_zh":@"印地文",@"abbr":@"hi"},
            @{@"lan_en":@"Urdu",@"lan_zh":@"乌尔都语",@"abbr":@"ur"},
            @{@"lan_en":@"Hungarian",@"lan_zh":@"匈牙利语",@"abbr":@"hu"},
            @{@"lan_en":@"Vietnamese",@"lan_zh":@"越南语",@"abbr":@"vi"},
            @{@"lan_en":@"Icelandic",@"lan_zh":@"冰岛语",@"abbr":@"is"},
            @{@"lan_en":@"Welsh",@"lan_zh":@"威尔士语",@"abbr":@"cy"},
            @{@"lan_en":@"Indonesian",@"lan_zh":@"印度尼西亚语",@"abbr":@"id"},
            @{@"lan_en":@"Yiddish",@"lan_zh":@"意第绪语",@"abbr":@"yi"}
        ];
    }
    return _lanDatas;
}

@end
