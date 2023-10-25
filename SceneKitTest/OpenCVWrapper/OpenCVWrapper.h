//
//  OpenCVWrapper.h
//  SceneKitTest
//
//  Created by M M on 25.10.2023.
//  Copyright © 2023 liu_temp. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

+ (UIImage *)edgeDetection:(UIImage *)source;
+ (UIImage *)runSAM:(UIImage *)source;

@end
