//
//  JKSVGADragBoxView.m
//  MacDevelopTools
//
//  Created by jk on 2022/2/22.
//  Copyright © 2022 JK. All rights reserved.
//

#import "JKSVGADragBoxView.h"

@interface JKSVGADragBoxView ()

@property (nonatomic, assign) NSTrackingRectTag trackingRect;

@end
@implementation JKSVGADragBoxView

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
    if (self.MouseActionBlock) {
        self.MouseActionBlock(true);
    }
}

- (void)mouseExited:(NSEvent *)event
{
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
        
        NSArray *svgaFiles = [files pathsMatchingExtensions:@[@"svga"]];
        if (svgaFiles.count) {
            [self _openAnimationFile:svgaFiles.firstObject];
        }
        // Depending on the dragging source and modifier keys,
        // the file data may be copied or linked
        NSLog(@"FILES");
    }
    return YES;
}

- (void)_openAnimationFile:(NSString *)file {
    
    if (file && [file isKindOfClass:[NSString class]] && file.length > 0) {
        if (self.OpenSVGAObjectBlock) {
            self.OpenSVGAObjectBlock(file);
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
                if (self.OpenSVGAObjectBlock) {
                    self.OpenSVGAObjectBlock(JSONObject);
                }
            });
        }
        
    });
}

@end
