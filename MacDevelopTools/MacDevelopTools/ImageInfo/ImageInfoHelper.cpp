//
//  ImageInfoHelper.cpp
//  MacDevelopTools
//
//  Created by jk on 2019/1/2.
//  Copyright © 2019年 JK. All rights reserved.
//

#include "ImageInfoHelper.hpp"
#include "Magick++.h"


const char * JKClassType[] = {"UndefinedClass","DirectClass","PseudoClass"};
const char * JKColorspaceType[] = {
    "UndefinedColorspace",
    "CMYColorspace",/* negated linear RGB colorspace */
    "CMYKColorspace",/* CMY with Black separation */
    "GRAYColorspace",          /* Single Channel greyscale (non-linear) image */
    "HCLColorspace",
    "HCLpColorspace",
    "HSBColorspace",
    "HSIColorspace",
    "HSLColorspace",
    "HSVColorspace",           /* alias for HSB */
    "HWBColorspace",
    "LabColorspace",
    "LCHColorspace",           /* alias for LCHuv */
    "LCHabColorspace",         /* Cylindrical (Polar) Lab */
    "LCHuvColorspace",         /* Cylindrical (Polar) Luv */
    "LogColorspace",
    "LMSColorspace",
    "LuvColorspace",
    "OHTAColorspace",
    "Rec601YCbCrColorspace",
    "Rec709YCbCrColorspace",
    "RGBColorspace",           /* Linear RGB colorspace */
    "scRGBColorspace",         /* ??? */
    "sRGBColorspace",          /* Default: non-linear sRGB colorspace */
    "TransparentColorspace",
    "xyYColorspace",
    "XYZColorspace",           /* IEEE Color Reference colorspace */
    "YCbCrColorspace",
    "YCCColorspace",
    "YDbDrColorspace",
    "YIQColorspace",
    "YPbPrColorspace",
    "YUVColorspace",
    "LinearGRAYColorspace"     /* Single Channel greyscale (linear) image */
};


const char * JKCompressionType[] =
{
    "UndefinedCompression",
    "B44ACompression",
    "B44Compression",
    "BZipCompression",
    "DXT1Compression",
    "DXT3Compression",
    "DXT5Compression",
    "FaxCompression",
    "Group4Compression",
    "JBIG1Compression",        /* ISO/IEC std 11544 / ITU-T rec T.82 */
    "JBIG2Compression",        /* ISO/IEC std 14492 / ITU-T rec T.88 */
    "JPEG2000Compression",     /* ISO/IEC std 15444-1 */
    "JPEGCompression",
    "LosslessJPEGCompression",
    "LZMACompression",         /* Lempel-Ziv-Markov chain algorithm */
    "LZWCompression",
    "NoCompression",
    "PizCompression",
    "Pxr24Compression",
    "RLECompression",
    "ZipCompression",
    "ZipSCompression"
};

const char * JKOrientationType[] =
{
    "UndefinedOrientation",
    "TopLeftOrientation",
    "TopRightOrientation",
    "BottomRightOrientation",
    "BottomLeftOrientation",
    "LeftTopOrientation",
    "RightTopOrientation",
    "RightBottomOrientation",
    "LeftBottomOrientation"
};

const char * JKBooleanType[] =
{
    "False",
    "True"
};

const char * JKRenderingIntent[] =
{
    "UndefinedIntent",
    "SaturationIntent",
    "PerceptualIntent",
    "AbsoluteIntent",
    "RelativeIntent"
};

const char * JKResolutionType[] =
{
    "UndefinedResolution",
    "PixelsPerInchResolution",
    "PixelsPerCentimeterResolution"
};

const char * JKFilterType[] =
{
    "UndefinedFilter",
    "PointFilter",
    "BoxFilter",
    "TriangleFilter",
    "HermiteFilter",
    "HannFilter",
    "HammingFilter",
    "BlackmanFilter",
    "GaussianFilter",
    "QuadraticFilter",
    "CubicFilter",
    "CatromFilter",
    "MitchellFilter",
    "JincFilter",
    "SincFilter",
    "SincFastFilter",
    "KaiserFilter",
    "WelchFilter",
    "ParzenFilter",
    "BohmanFilter",
    "BartlettFilter",
    "LagrangeFilter",
    "LanczosFilter",
    "LanczosSharpFilter",
    "Lanczos2Filter",
    "Lanczos2SharpFilter",
    "RobidouxFilter",
    "RobidouxSharpFilter",
    "CosineFilter",
    "SplineFilter",
    "LanczosRadiusFilter",
    "CubicSplineFilter",
    "SentinelFilter"  /* a count of all the filters, not a real filter */
};

const char * JKPixelIntensityMethod[] =
{
    "UndefinedPixelIntensityMethod",
    "AveragePixelIntensityMethod",
    "BrightnessPixelIntensityMethod",
    "LightnessPixelIntensityMethod",
    "MSPixelIntensityMethod",
    "Rec601LumaPixelIntensityMethod",
    "Rec601LuminancePixelIntensityMethod",
    "Rec709LumaPixelIntensityMethod",
    "Rec709LuminancePixelIntensityMethod",
    "RMSPixelIntensityMethod"
};

const char * JKInterlaceType[] =
{
    "UndefinedInterlace",
    "NoInterlace",
    "LineInterlace",
    "PlaneInterlace",
    "PartitionInterlace",
    "GIFInterlace",
    "JPEGInterlace",
    "PNGInterlace"
};

const char * JKEndianType[] =
{
    "UndefinedEndian",
    "LSBEndian",
    "MSBEndian"
};

const char * JKGravityType[] =
{
    "UndefinedGravity", // -1
    "ForgetGravity",  // 0
    "NorthWestGravity",
    "NorthGravity",
    "NorthEastGravity",
    "WestGravity",
    "CenterGravity",
    "EastGravity",
    "SouthWestGravity",
    "SouthGravity",
    "SouthEastGravity"
};

const char * JKCompositeOperator[] =
{
    "UndefinedCompositeOp",
    "AlphaCompositeOp",
    "AtopCompositeOp",
    "BlendCompositeOp",
    "BlurCompositeOp",
    "BumpmapCompositeOp",
    "ChangeMaskCompositeOp",
    "ClearCompositeOp",
    "ColorBurnCompositeOp",
    "ColorDodgeCompositeOp",
    "ColorizeCompositeOp",
    "CopyBlackCompositeOp",
    "CopyBlueCompositeOp",
    "CopyCompositeOp",
    "CopyCyanCompositeOp",
    "CopyGreenCompositeOp",
    "CopyMagentaCompositeOp",
    "CopyAlphaCompositeOp",
    "CopyRedCompositeOp",
    "CopyYellowCompositeOp",
    "DarkenCompositeOp",
    "DarkenIntensityCompositeOp",
    "DifferenceCompositeOp",
    "DisplaceCompositeOp",
    "DissolveCompositeOp",
    "DistortCompositeOp",
    "DivideDstCompositeOp",
    "DivideSrcCompositeOp",
    "DstAtopCompositeOp",
    "DstCompositeOp",
    "DstInCompositeOp",
    "DstOutCompositeOp",
    "DstOverCompositeOp",
    "ExclusionCompositeOp",
    "HardLightCompositeOp",
    "HardMixCompositeOp",
    "HueCompositeOp",
    "InCompositeOp",
    "IntensityCompositeOp",
    "LightenCompositeOp",
    "LightenIntensityCompositeOp",
    "LinearBurnCompositeOp",
    "LinearDodgeCompositeOp",
    "LinearLightCompositeOp",
    "LuminizeCompositeOp",
    "MathematicsCompositeOp",
    "MinusDstCompositeOp",
    "MinusSrcCompositeOp",
    "ModulateCompositeOp",
    "ModulusAddCompositeOp",
    "ModulusSubtractCompositeOp",
    "MultiplyCompositeOp",
    "NoCompositeOp",
    "OutCompositeOp",
    "OverCompositeOp",
    "OverlayCompositeOp",
    "PegtopLightCompositeOp",
    "PinLightCompositeOp",
    "PlusCompositeOp",
    "ReplaceCompositeOp",
    "SaturateCompositeOp",
    "ScreenCompositeOp",
    "SoftLightCompositeOp",
    "SrcAtopCompositeOp",
    "SrcCompositeOp",
    "SrcInCompositeOp",
    "SrcOutCompositeOp",
    "SrcOverCompositeOp",
    "ThresholdCompositeOp",
    "VividLightCompositeOp",
    "XorCompositeOp",
    "StereoCompositeOp"
};


const char * JKDisposeType[] =
{
    "UnrecognizedDispose",//-1
    "UndefinedDispose",// 0
    "NoneDispose",
    "BackgroundDispose",
    "PreviousDispose"
};

const char * JKPixelInterpolateMethod[] =
{
    "UndefinedInterpolatePixel",
    "AverageInterpolatePixel",    /* Average 4 nearest neighbours */
    "Average9InterpolatePixel",   /* Average 9 nearest neighbours */
    "Average16InterpolatePixel",  /* Average 16 nearest neighbours */
    "BackgroundInterpolatePixel", /* Just return background color */
    "BilinearInterpolatePixel",   /* Triangular filter interpolation */
    "BlendInterpolatePixel",      /* blend of nearest 1, 2 or 4 pixels */
    "CatromInterpolatePixel",     /* Catmull-Rom interpolation */
    "IntegerInterpolatePixel",    /* Integer (floor) interpolation */
    "MeshInterpolatePixel",       /* Triangular Mesh interpolation */
    "NearestInterpolatePixel",    /* Nearest Neighbour Only */
    "SplineInterpolatePixel"    /* Cubic Spline (blurred) interpolation */
    /* FilterInterpolatePixel,  ** Use resize filter - (very slow) */
};

const char * JKImageType[] =
{
    "UndefinedType",
    "BilevelType",
    "GrayscaleType",
    "GrayscaleAlphaType",
    "PaletteType",
    "PaletteAlphaType",
    "TrueColorType",
    "TrueColorAlphaType",
    "ColorSeparationType",
    "ColorSeparationAlphaType",
    "OptimizeType",
    "PaletteBilevelAlphaType"
};
