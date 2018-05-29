//
//  UIImageDiff.h
//  Pods
//
//  Created by Vic on 2018/5/29.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface UIImageDiff : NSObject

+ (NSInteger)differentValueCountWithImage:(UIImage *)image1 andAnotherImage:(UIImage *)image2;

@end
