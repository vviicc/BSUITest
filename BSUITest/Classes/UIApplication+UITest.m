//
//  UIApplication+UITest.m
//  pkgame iOS
//
//  Created by Vic on 2018/5/12.
//

#import "UIApplication+UITest.h"
#import <objc/runtime.h>
#import "MFUITestMgr.h"

@implementation UIApplication (UITest)

+ (void)load
{
    [self swizzleSEL:@selector(sendEvent:) withSEL:@selector(mfSendEvent:)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MFUITestMgr sharedInstance];
    });
}

- (void)mfSendEvent:(UIEvent *)event
{    
    [self mfSendEvent:event];
    
    if (![MFUITestMgr sharedInstance].goHomeUIBlock) {
        [MFUITestMgr sharedInstance].goHomeUIBlock = ^{

        };
    }
    
    if ([MFUITestMgr sharedInstance].isRecording) {
        [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
            UITouchPhase phase = touch.phase;
            CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
            UIView *view = touch.view;
            UIWindow *window = touch.window;
            BOOL isKeyboardWindow = [window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")];
            
            if (view && phase == UITouchPhaseBegan  && !CGPointEqualToPoint(point, CGPointMake(0, [UIScreen mainScreen].bounds.size.height))) {
                [[MFUITestMgr sharedInstance] record:point isKeyboard:isKeyboardWindow endTouch:[window isKindOfClass:NSClassFromString(@"MFRecWindow")]];
            }
        }];
    }
    
}

+ (void)swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL {
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSEL);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSEL);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSEL,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSEL,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
