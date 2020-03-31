//
//  JKLottieDragBoxView.m
//  MacDevelopTools
//
//  Created by jk on 2020/3/31.
//  Copyright © 2020 JK. All rights reserved.
//

#import "JKLottieDragBoxView.h"

@interface JKLottieDragBoxView ()

@property (nonatomic, assign) NSTrackingRectTag trackingRect;

@end
@implementation JKLottieDragBoxView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        [self buildAttributes];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self buildAttributes];
    }
    return self;
}

- (void)buildAttributes
{
    NSArray *dragTypes = [NSArray arrayWithObjects:NSFilenamesPboardType, nil];
    [self registerForDraggedTypes:dragTypes];
    
    [self addTrackingRect:self.frame owner:self userData:nil assumeInside:false];
}


- (void)mouseEntered:(NSEvent *)event
{
    [[self window] setAcceptsMouseMovedEvents:YES];
    [[self window] makeFirstResponder:self];
    NSLog(@"enter");
    if (self.MouseActionBlock) {
        self.MouseActionBlock(true);
    }
}

- (void)mouseExited:(NSEvent *)event
{
    NSLog(@"exit");
    if (self.MouseActionBlock) {
        self.MouseActionBlock(false);
    }
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSColorPboardType] ) {
        if (sourceDragMask & NSDragOperationGeneric) {
            return NSDragOperationGeneric;
        }
    }
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        } else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSColorPboardType] ) {
        // Only a copy operation allowed so just copy the data
        
    } else if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        
        NSArray *jsonFiles = [files pathsMatchingExtensions:@[@"json"]];
        if (jsonFiles.count) {
            [self _openAnimationFile:jsonFiles.firstObject];
        }
        // Depending on the dragging source and modifier keys,
        // the file data may be copied or linked
        NSLog(@"FILES");
    }
    return YES;
}

- (void)_openAnimationFile:(NSString *)file {
    
    NSError *error;
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:file];
    NSDictionary  *JSONObject = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
                                                                           options:0 error:&error] : nil;
    if (JSONObject && !error) {
        if (self.OpenJsonLottieObjectBlock) {
            self.OpenJsonLottieObjectBlock(JSONObject);
        }
    }
}

-(void)openAnimationURL:(NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSError *error;
        NSData *jsonData = [[NSData alloc] initWithContentsOfURL:url];
        NSDictionary  *JSONObject = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
                                                                               options:0 error:&error] : nil;
        if (JSONObject && !error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.OpenJsonLottieObjectBlock) {
                    self.OpenJsonLottieObjectBlock(JSONObject);
                }
            });
        }
        
    });
}

@end
