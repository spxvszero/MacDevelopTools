//
//  JKImageInfoViewController.m
//  MacDevelopTools
//
//  Created by jk on 2018/12/29.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKImageInfoViewController.h"
#import "JKImageInfoInspectorViewController.h"
#import "JKInfoImageView.h"
#import "Magick++.h"
#import "ImageInfoHelper.hpp"

@interface JKImageInfoViewController ()

@property (weak) IBOutlet JKInfoImageView *imageView;

@property (weak) IBOutlet NSButton *expandButton;

@property (weak) IBOutlet NSView *containView;

@property (nonatomic, strong) JKImageInfoInspectorViewController *inspectorViewController;

@end

@implementation JKImageInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.containView addSubview:self.inspectorViewController.view];
    self.imageView.editable = YES;
    __weak typeof(self) weakSelf = self;
    self.imageView.ImageDidChangeBlock = ^(JKInfoImageView *imageView, NSURL *fileUrl, NSImage *image) {
        [weakSelf lookImageInfoWithUrl:fileUrl];
    };
}


- (void)lookImageInfoWithUrl:(NSURL *)imageFileUrl
{
    NSData *data = [NSData dataWithContentsOfURL:imageFileUrl];
    const void *imageData = [data bytes];
    
    MagickCore::Image *imageInfo = MagickCore::BlobToImage(MagickCore::AcquireImageInfo(), imageData, data.length, MagickCore::AcquireExceptionInfo());
    
    NSDictionary *imageDic = [self dictionaryFromImage:imageInfo];
    
    MagickCore::DestroyImage(imageInfo);
    
    self.inspectorViewController.dic = imageDic;
    [self.inspectorViewController reloadData];
}

- (NSDictionary *)dictionaryFromImage:(MagickCore::Image *)imageInfo
{
    NSMutableDictionary *resDic = [NSMutableDictionary dictionary];
    
//    ClassType storage_class;
    
    [resDic setObject:[NSString stringWithFormat:@"%s",JKClassType[imageInfo->storage_class]] forKey:@"ClassType"];
//    ColorspaceType colorspace;         /* colorspace of image data */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKColorspaceType[imageInfo->colorspace]] forKey:@"ColorspaceType"];
//    CompressionType compression;        /* compression of image when read/write */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKCompressionType[imageInfo->compression]] forKey:@"CompressionType"];
//    size_t quality;            /* compression quality setting, meaning varies */
    [resDic setObject:@(imageInfo->quality) forKey:@"Quality"];
//    OrientationType orientation;        /* photo orientation of image */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKCompressionType[imageInfo->orientation]] forKey:@"OrientationType"];
//    MagickBooleanType taint;              /* has image been modified since reading */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKBooleanType[imageInfo->taint]] forKey:@"Taint"];
    
    //    size_t
    //    columns,            /* physical size of image */
    //    rows,
    //    depth,              /* depth of image on read/write */
    //    colors;             /* Size of color table, or actual color count */
    //    /* Only valid if image is not DirectClass */
    NSDictionary *sizeDic = [NSDictionary dictionaryWithObjectsAndKeys:@(imageInfo->columns),@"columns",
                         @(imageInfo->rows),@"rows",
                         @(imageInfo->depth),@"depth",
                         @(imageInfo->colors),@"colors",nil];
    [resDic setObject:sizeDic forKey:@"size"];
    
    //    PixelInfo
    //    *colormap,
    //    alpha_color,        /* deprecated */
    //    background_color,   /* current background color attribute */
    //    border_color,       /* current bordercolor attribute */
    //    transparent_color;  /* color for 'transparent' color index in GIF */
#warning not finish
    [resDic setObject:@"" forKey:@"PixelInfo"];
    
//    double gamma;
    [resDic setObject:@(imageInfo->gamma) forKey:@"gamma"];
    
//    ChromaticityInfo chromaticity;
#warning not finish
    [resDic setObject:@"" forKey:@"ChromaticityInfo"];
//    imageInfo->chromaticity;
    
//    RenderingIntent rendering_intent;
    [resDic setObject:[NSString stringWithFormat:@"%s",JKRenderingIntent[imageInfo->rendering_intent]] forKey:@"RenderingIntent"];
    
//    void *profiles;
#warning not finish
//    imageInfo->profiles;
    
//    ResolutionType units;          /* resolution/density  ppi or ppc */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKRenderingIntent[imageInfo->units]] forKey:@"ResolutionType"];
    
//    char *montage,
    //    *directory,
    //    *geometry;
    [resDic setObject:imageInfo->montage?[[NSString alloc] initWithCString:imageInfo->montage encoding:NSASCIIStringEncoding]:@"" forKey:@"montage"];
    [resDic setObject:imageInfo->directory?[[NSString alloc] initWithCString:imageInfo->directory encoding:NSASCIIStringEncoding]:@"" forKey:@"directory"];
    [resDic setObject:imageInfo->geometry?[[NSString alloc] initWithCString:imageInfo->geometry encoding:NSASCIIStringEncoding]:@"" forKey:@"geometry"];
    
    //    ssize_t offset;         /* ??? */
    [resDic setObject:@(imageInfo->offset) forKey:@"offset??"];
    
    //    PointInfo
    //    resolution;     /* image resolution/density */
#warning not finish
//    imageInfo->resolution
    
    //    RectangleInfo
    //    page,           /* virtual canvas size and offset of image */
    //    extract_info;
#warning not finish
//    imageInfo->page;
    
    //    double
    //    fuzz;           /* current color fuzz attribute - move to image_info */
    [resDic setObject:@(imageInfo->fuzz) forKey:@"fuzz"];
    
    //    FilterType
    //    filter;         /* resize/distort filter to apply */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKFilterType[imageInfo->filter]] forKey:@"filter"];
    
    
    //    PixelIntensityMethod intensity;      /* method to generate an intensity value from a pixel */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKPixelIntensityMethod[imageInfo->intensity]] forKey:@"PixelIntensity"];
    
//    InterlaceType    interlace;
    [resDic setObject:[NSString stringWithFormat:@"%s",JKInterlaceType[imageInfo->interlace]] forKey:@"InterlaceType"];
    
    //    EndianType
    //    endian;         /* raw data integer ordering on read/write */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKEndianType[imageInfo->endian]] forKey:@"EndianType"];
    
    //    GravityType   gravity;        /* Gravity attribute for positioning in image */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKGravityType[imageInfo->gravity + 1]] forKey:@"GravityType"];
    
    //    CompositeOperator
    //    compose;        /* alpha composition method for layered images */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKCompositeOperator[imageInfo->compose]] forKey:@"CompositeOperator"];
    
    //    DisposeType
    //    dispose;        /* GIF animation disposal method */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKDisposeType[imageInfo->dispose + 1]] forKey:@"DisposeType"];
    
    //    size_t
    //    scene,          /* index of image in multi-image file */
    //    delay,          /* Animation delay time */
    //    duration;       /* Total animation duration sum(delay*iterations) */
    [resDic setObject:@(imageInfo->scene) forKey:@"scene"];
    [resDic setObject:@(imageInfo->delay) forKey:@"delay"];
    [resDic setObject:@(imageInfo->duration) forKey:@"duration"];

    //    ssize_t
    //    ticks_per_second;  /* units for delay time, default 100 for GIF */
    [resDic setObject:@(imageInfo->ticks_per_second) forKey:@"ticks_per_second"];
    
    //    size_t
    //    iterations,        /* number of interations for GIF animations */
    //    total_colors;
    [resDic setObject:@(imageInfo->iterations) forKey:@"iterations"];
    [resDic setObject:@(imageInfo->total_colors) forKey:@"total_colors"];
    
    //    ssize_t
    //    start_loop;        /* ??? */
    [resDic setObject:@(imageInfo->start_loop) forKey:@"start_loop???"];
    
    //    PixelInterpolateMethod
    //    interpolate;       /* Interpolation of color for between pixel lookups */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKPixelInterpolateMethod[imageInfo->interpolate]] forKey:@"PixelInterpolate"];
    
    //    MagickBooleanType
    //    black_point_compensation;
    [resDic setObject:[NSString stringWithFormat:@"%s",JKBooleanType[imageInfo->black_point_compensation]] forKey:@"PixelInterpolate"];
    
    //    RectangleInfo
    //    tile_offset;
#warning not finish
//    [resDic setObject:@(imageInfo->tile_offset) forKey:@"RectangleInfo"];
    
    //    ImageType
    //    type;
    [resDic setObject:[NSString stringWithFormat:@"%s",JKImageType[imageInfo->type]]  forKey:@"ImageType"];
    
    //    MagickBooleanType
    //    dither;            /* dithering on/off */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKBooleanType[imageInfo->dither]] forKey:@"dither"];
    
    //    MagickSizeType
    //    extent;            /* Size of image read from disk */
    [resDic setObject:@(imageInfo->extent) forKey:@"extent"];
    
    //    MagickBooleanType
    //    ping;              /* no image data read, just attributes */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKBooleanType[imageInfo->ping]] forKey:@"ping"];
    
    //    MagickBooleanType
    //    read_mask,
    //    write_mask;
    [resDic setObject:[NSString stringWithFormat:@"%s",JKBooleanType[imageInfo->read_mask]] forKey:@"read_mask"];
    [resDic setObject:[NSString stringWithFormat:@"%s",JKBooleanType[imageInfo->write_mask]] forKey:@"write_mask"];
    
    //    PixelTrait
    //    alpha_trait;       /* is transparency channel defined and active */
    [resDic setObject:@(imageInfo->alpha_trait) forKey:@"alpha_trait"];
    
    //    size_t
    //    number_channels,
    //    number_meta_channels,
    //    metacontent_extent;
    [resDic setObject:@(imageInfo->number_channels) forKey:@"number_channels"];
    [resDic setObject:@(imageInfo->number_meta_channels) forKey:@"number_meta_channels"];
    [resDic setObject:@(imageInfo->metacontent_extent) forKey:@"metacontent_extent"];
    
    //    ChannelType
    //    channel_mask;
    [resDic setObject:@(imageInfo->channel_mask) forKey:@"channel_mask"];
    
    //    PixelChannelMap
    //    *channel_map;
#warning not finish
//    [resDic setObject:@(imageInfo->channel_map) forKey:@"channel_map"];
    
    //    void
    //    *cache;
    
    //    ErrorInfo
    //    error;
#warning not finish
//    [resDic setObject:@(imageInfo->error) forKey:@"ErrorInfo"];
    
    //    TimerInfo
    //    timer;
    #warning not finish
//    [resDic setObject:@(imageInfo->timer) forKey:@"timer"];
    
    //    MagickProgressMonitor
    //    progress_monitor;
//    [resDic setObject:@(imageInfo->progress_monitor) forKey:@"progress_monitor"];
    
    //    void
    //    *client_data;
    
    
    //    Ascii85Info
    //    *ascii85;
//    [resDic setObject:@(imageInfo->ascii85) forKey:@"ascii85"];
    
    //    ProfileInfo
    //    *generic_profile;
    
    
    //    void
    //    *properties,       /* general settings, to save with image */
    //    *artifacts;        /* general operational/coder settings, not saved */
//    [resDic setObject:@(imageInfo->ascii85) forKey:@"ascii85"];
    
    //    char
    //    filename[MagickPathExtent],        /* images input filename */
    //    magick_filename[MagickPathExtent], /* given image filename (with read mods) */
    //    magick[MagickPathExtent];          /* images file format (file magic) */
    [resDic setObject:[[NSString alloc] initWithCString:imageInfo->filename encoding:NSUTF8StringEncoding] forKey:@"filename"];
    [resDic setObject:[[NSString alloc] initWithCString:imageInfo->magick_filename encoding:NSUTF8StringEncoding] forKey:@"magick_filename"];
    [resDic setObject:[[NSString alloc] initWithCString:imageInfo->magick encoding:NSUTF8StringEncoding] forKey:@"magick"];
    
    //    size_t
    //    magick_columns,     /* size of image when read/created */
    //    magick_rows;
    [resDic setObject:@(imageInfo->magick_columns) forKey:@"magick_columns"];
    [resDic setObject:@(imageInfo->magick_rows) forKey:@"magick_rows"];
    
    //    BlobInfo
    //    *blob;             /* image file as in-memory string of 'extent' */
    
    
    //    time_t
    //    timestamp;
    [resDic setObject:@(imageInfo->timestamp) forKey:@"timestamp"];
    
    //    MagickBooleanType
    //    debug;             /* debug output attribute */
    [resDic setObject:[NSString stringWithFormat:@"%s",JKBooleanType[imageInfo->debug]] forKey:@"debug"];
    
    //    volatile ssize_t
    //    reference_count;   /* image data sharing memory management */
    [resDic setObject:@(imageInfo->reference_count) forKey:@"reference_count"];
    
    //    SemaphoreInfo
    //    *semaphore;
    
    //    struct _ImageInfo
    //    *image_info;       /* (Optional) Image belongs to this ImageInfo 'list'
    //                        * For access to 'global options' when no per-image
    //                        * attribute, properity, or artifact has been set.
    //                        */
    
    
    //    struct _Image
    //    *list,             /* Undo/Redo image processing list (for display) */
    //    *previous,         /* Image list links */
    //    *next;
    
    
    //    size_t
    //    signature;
    [resDic setObject:@(imageInfo->signature) forKey:@"signature"];
    
    //    PixelInfo
    //    matte_color;        /* current mattecolor attribute */
    
    
    //    MagickBooleanType
    //    composite_mask;
    [resDic setObject:[NSString stringWithFormat:@"%s",JKBooleanType[imageInfo->composite_mask]] forKey:@"composite_mask"];
    
    
    //    PixelTrait
    //    mask_trait;       /* apply the clip or composite mask */
    [resDic setObject:@(imageInfo->mask_trait) forKey:@"mask_trait"];
    
    //    ChannelType
    //    channels;
    [resDic setObject:@(imageInfo->channels) forKey:@"channels"];
    
    return resDic;
}

- (IBAction)expandButtonAction:(NSButton *)sender
{
    [self.inspectorViewController reloadData];
}


- (JKImageInfoInspectorViewController *)inspectorViewController
{
    if (!_inspectorViewController) {
        NSStoryboard *sb = [NSStoryboard storyboardWithName:@"ImageInfo" bundle:nil];
        _inspectorViewController = [sb instantiateControllerWithIdentifier:@"JKImageInfoInspectorViewController"];
    }
    return _inspectorViewController;
}

@end
