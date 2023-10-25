//
//  OpenCVWrapper.m
//  SceneKitTest
//
//  Created by M M on 25.10.2023.
//  Copyright © 2023 liu_temp. All rights reserved.
//



#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import "sam.hpp"

using namespace std;
using namespace cv;

#pragma mark - Private Declarations

@interface OpenCVWrapper ()


@end

#pragma mark - OpenCVWrapper

@implementation OpenCVWrapper

#pragma mark Public

+ (UIImage *)edgeDetection:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _edgeFrom:[OpenCVWrapper _matFrom:source]]];
}


+ (UIImage *)runSAM:(UIImage *)source {
    cout << "SAM: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _SamFrom:[OpenCVWrapper _matFrom:source]]];
}

#pragma mark Private

+(Mat)_SamFrom:(Mat)image {
    // model loading
    Sam sam;
    NSString *enc_nstring_path = [[NSBundle mainBundle] pathForResource:@"mobile_sam_preprocess" ofType:@"onnx"];
    
    NSString *dec_nstring_path = [[NSBundle mainBundle] pathForResource:@"mobile_sam" ofType:@"onnx"];
    

    std::string pathEncoder = std::string([enc_nstring_path UTF8String]);
    std::string pathDecoder = std::string([dec_nstring_path UTF8String]);
    
    std::cout<<"loadModel started"<<std::endl;
    
    bool terminated = false; 
    bool successLoadModel = sam.loadModel(pathEncoder, pathDecoder,1, &terminated);
    if(!successLoadModel){
      std::cout<<"loadModel error"<<std::endl;
    }
    
    auto inputSize = sam.getInputSize();
    cvtColor(image, image, COLOR_BGRA2RGB);

    cv::resize(image, image, inputSize);
    std::cout<<"preprocessImage started"<<std::endl;
    
    
    bool successPreprocessImage = sam.preprocessImage(image, &terminated);
    if(!successPreprocessImage){
      std::cout<<"preprocessImage error"<<std::endl;
    } else {
        std::cout<<"preprocessImage success"<<std::endl;

    }
    std::list<cv::Point> points, nagativePoints;
    cv::Rect roi;
    // 1st object and 1st click
    int previousMaskIdx = -1; // An index to use the previous mask result
    bool isNextGetMask = true; // Set true when start labeling a new object
    points.push_back({400, 400});
    cv::Mat mask = sam.getMask(points, nagativePoints, roi, previousMaskIdx, isNextGetMask);
    std::cout<<"get mask is success"<<std::endl;

    return mask;
}

+ (Mat)_edgeFrom:(Mat)source {
    cout << "-> grayFrom ->";
    
    Mat result;
    cvtColor(source, result, COLOR_BGR2GRAY);
    Canny(result, result, 100, 200);
    return result;
}

+ (Mat)_matFrom:(UIImage *)source {
    cout << "matFrom ->";
    
    CGImageRef image = CGImageCreateCopy(source.CGImage);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    Mat result(rows, cols, CV_8UC4);
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = result.step[0];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    
    CGContextRef context = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
    CGContextRelease(context);
    
    return result;
}

+ (UIImage *)_imageFrom:(Mat)source {
    cout << "-> imageFrom\n";
    
    NSData *data = [NSData dataWithBytes:source.data length:source.elemSize() * source.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = source.step[0];
    CGColorSpaceRef colorSpace = (source.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());
    
    CGImageRef image = CGImageCreate(source.cols, source.rows, bitsPerComponent, bitsPerComponent * source.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *result = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return result;
}

@end
