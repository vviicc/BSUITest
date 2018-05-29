//
//  UIImageDiff.m
//  Pods
//
//  Created by Vic on 2018/5/29.
//

#import "UIImageDiff.h"

@implementation UIImageDiff

+ (NSInteger)differentValueCountWithImage:(UIImage *)image1 andAnotherImage:(UIImage *)image2 {
    NSString *pHashString1 = [self pha_pHashStringValue:[self pha_grayImage:[self pha_scaleToSize:CGSizeMake(8.0, 8.0) image:image1]]];
    NSString *pHashString2 = [self pha_pHashStringValue:[self pha_grayImage:[self pha_scaleToSize:CGSizeMake(8.0, 8.0) image:image2]]];
    return [self differentValueCountWithString:pHashString1 andString:pHashString2];
}

+ (UIImage *)pha_scaleToSize:(CGSize)size image:(UIImage *)image
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)pha_grayImage:(UIImage *)image
{
    int width = image.size.width;
    int height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil, width, height, 8,0, colorSpace, kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    if (!context) {
        return nil;
    }
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), image.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}

+ (NSString *)pha_pHashStringValue:(UIImage *)image
{
    NSMutableString * pHashString = [NSMutableString string];
    CGImageRef imageRef = [image CGImage];
    unsigned long width = CGImageGetWidth(imageRef);
    unsigned long height = CGImageGetHeight(imageRef);
    CGDataProviderRef provider = CGImageGetDataProvider(imageRef);
    NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
    const char * heightData = (char*)data.bytes;
    int sum = 0;
    for (int i = 0; i < width * height; i++) {
        if (heightData[i] != 0) {
            sum += heightData[i];
        }
    }
    int avr = sum / (width * height);
    for (int i = 0; i < width * height; i++) {
        if (heightData[i] >= avr) {
            [pHashString appendString:@"1"];
        } else {
            [pHashString appendString:@"0"];
        }
    }
    return pHashString;
}

+ (NSInteger)differentValueCountWithString:(NSString *)str1 andString:(NSString *)str2
{
    NSInteger diff = 0;
    const char * s1 = [str1 UTF8String];
    const char * s2 = [str2 UTF8String];
    for (int i = 0 ; i < str1.length ;i++){
        if(s1[i] != s2[i]){
            diff++;
        }
    }
    return diff;
}

@end
