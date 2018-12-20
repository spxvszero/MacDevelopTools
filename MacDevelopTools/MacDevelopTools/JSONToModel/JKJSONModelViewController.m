//
//  JKJSONModelViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/19.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKJSONModelViewController.h"
#import "JKJSONModelObjectiveC.h"

typedef enum : NSUInteger {
    TransformTypeObjectiveC,
} JKJSONModelTransformType;

#define kOperationItemTag 233

@interface JKJSONModelViewController ()
@property (unsafe_unretained) IBOutlet NSTextView *jsonTxtView;
@property (unsafe_unretained) IBOutlet NSTextView *resultTxtView;

@property (weak) IBOutlet NSPopUpButton *popUpButton;



@property (nonatomic, assign) JKJSONModelTransformType currentSelectedType;

@end

@implementation JKJSONModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self disableAutoFormatWithTxtView:self.jsonTxtView];
    [self disableAutoFormatWithTxtView:self.resultTxtView];
    
    NSInteger i = 0;
    for (NSMenuItem *item in self.popUpButton.menu.itemArray) {
        item.tag = kOperationItemTag + i++;
    }
    
    self.currentSelectedType = self.popUpButton.selectedItem.tag - kOperationItemTag;
    
}

- (IBAction)popUpButtonAction:(NSPopUpButton *)sender
{
    NSLog(@"jsonmodel select %@",sender.selectedItem.title);
    
    self.currentSelectedType = sender.selectedItem.tag - kOperationItemTag;
}

- (IBAction)outputButton:(id)sender
{
    switch (self.currentSelectedType) {
        case TransformTypeObjectiveC:
        {
            self.resultTxtView.string = [JKJSONModelObjectiveC transformFromJSONString:self.jsonTxtView.string];
        }
            break;
            
        default:
        {
            self.resultTxtView.string = @"Unkown selection";
        }
            break;
    }
}

- (void)disableAutoFormatWithTxtView:(NSTextView *)textView
{
    textView.automaticLinkDetectionEnabled = false;
    textView.continuousSpellCheckingEnabled = false;
    textView.grammarCheckingEnabled = false;
    textView.automaticDashSubstitutionEnabled = false;
    textView.automaticDataDetectionEnabled = false;
    textView.automaticSpellingCorrectionEnabled = false;
    textView.automaticTextReplacementEnabled = false;
    textView.incrementalSearchingEnabled = false;
    textView.automaticTextCompletionEnabled = false;
    
    textView.automaticQuoteSubstitutionEnabled = false;
    
    textView.rulerVisible = false;
    textView.fieldEditor = false;
    textView.richText = false;
}

@end
