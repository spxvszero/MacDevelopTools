//
//  JKEncodingViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/14.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKEncodingViewController.h"
#import "NSString+URLEncode.h"

#define kErrorConvert @"error: convert failed!"

typedef enum : NSUInteger {
    EncodingOperationTypeUniToChin,
    EncodingOperationTypeChinToUni,
    EncodingOperationTypeURLEncode,
    EncodingOperationTypeURLDecode,
} JKEncodingOperationType;

#define kOperationItemTag 132

@interface JKEncodingViewController ()
@property (unsafe_unretained) IBOutlet NSTextView *originTextView;
@property (unsafe_unretained) IBOutlet NSTextView *outPutTextView;
@property (weak) IBOutlet NSPopUpButton *popUpButton;
@property (weak) IBOutlet NSButton *startButton;


@property (nonatomic, assign) JKEncodingOperationType currentSelectedType;

@end

@implementation JKEncodingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    NSInteger i = 0;
    for (NSMenuItem *item in self.popUpButton.menu.itemArray) {
        item.tag = kOperationItemTag + i++;
    }
    
    self.currentSelectedType = self.popUpButton.selectedItem.tag - kOperationItemTag;
}

- (IBAction)popUpSelectAction:(NSPopUpButton *)sender
{
    NSLog(@"select %@",sender.selectedItem.title);
    
    self.currentSelectedType = sender.selectedItem.tag - kOperationItemTag;
}


- (IBAction)startButtonAction:(id)sender
{
    switch (self.currentSelectedType) {
        case EncodingOperationTypeChinToUni:
        {
            [self chinToUnicode];
        }
            break;
        case EncodingOperationTypeUniToChin:
        {
            [self unicodeToChinese];
        }
            break;
        case EncodingOperationTypeURLEncode:
        {
            [self urlEncode];
        }
            break;
        case EncodingOperationTypeURLDecode:
        {
            [self urlDecode];
        }
            break;
            
        default:
            break;
    }
}

- (void)unicodeToChinese
{
    NSString *originStr = self.originTextView.string;
    
    NSData *strData = [originStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *resStr = [[NSString alloc] initWithData:strData encoding:NSNonLossyASCIIStringEncoding];

    if (resStr) {
        self.outPutTextView.string = resStr;
    }else{
        self.outPutTextView.string = kErrorConvert;
    }
    
}

- (void)chinToUnicode
{
    NSString *originStr = self.originTextView.string;
    
    NSData *strData = [originStr dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    
    NSString *resStr = [[NSString alloc] initWithData:strData encoding:NSASCIIStringEncoding];
    
    if (resStr) {
        self.outPutTextView.string = resStr;
    }else{
        self.outPutTextView.string = kErrorConvert;
    }
}

- (void)urlEncode
{
    NSString *originStr = self.originTextView.string;
    
    NSString *encodedString = [originStr URLEncode];
    if (encodedString) {
        self.outPutTextView.string = encodedString;
    }else{
        self.outPutTextView.string = kErrorConvert;
    }
}

- (void)urlDecode
{
    NSString *originStr = self.originTextView.string;
    
    NSString *decodeString = [originStr URLDecode];
    
    if (decodeString) {
        self.outPutTextView.string = decodeString;
    }else{
        self.outPutTextView.string = kErrorConvert;
    }
}

@end
