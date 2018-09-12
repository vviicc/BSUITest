//
//  BSUITestLogic.m
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import "BSUITestLogic.h"
#import "BSUITestFileHelper.h"
#import "KTouchPointerWindow.h"
#import "SRScreenRecorder.h"
#import "TPPreciseTimer.h"
#import <objc/runtime.h>
#import <PTFakeTouch/PTFakeMetaTouch.h>

#pragma mark - BSLogTouch

@interface BSLogTouch : NSObject<NSCoding>
@property (nonatomic, assign) double secs;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) BOOL isKeyboard;  // 是不是键盘
@property (nonatomic, assign) BOOL endTouch;   // 点击结束录制按钮
@end

@implementation BSLogTouch

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:self.secs forKey:@"secs"];
    [aCoder encodeCGPoint:self.point forKey:@"point"];
    [aCoder encodeBool:self.isKeyboard forKey:@"isKeyboard"];
    [aCoder encodeBool:self.endTouch forKey:@"endTouch"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.secs = [aDecoder decodeDoubleForKey:@"secs"];
        self.point = [aDecoder decodeCGPointForKey:@"point"];
        self.isKeyboard = [aDecoder decodeBoolForKey:@"isKeyboard"];
        self.endTouch = [aDecoder decodeBoolForKey:@"endTouch"];
    }
    
    return self;
}

@end

#pragma mark - BSUITestLogic

@interface BSUITestLogic()

@property (nonatomic, assign) NSTimeInterval startRecMediaTime;     // 开始录制mediaTime
@property (nonatomic, assign) NSTimeInterval endRecMediaTime;       // 结束录制mediaTime
@property (nonatomic, assign) NSTimeInterval startRecTimestamp;     // 开始录制时间戳

@property (nonatomic, strong) NSMutableArray<BSLogTouch *> *logTouchs;
@property (nonatomic, strong) SRScreenRecorder *screenRecorder;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation BSUITestLogic

+ (instancetype)sharedInstance
{
    static BSUITestLogic *logic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logic = [[BSUITestLogic alloc] init];
    });
    
    return logic;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.screenRecorder = [[SRScreenRecorder alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
        self.serialQueue = dispatch_queue_create("com.bs.uitest.logic", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - record录制

- (void)record:(CGPoint)point isKeyboard:(BOOL)isKeyboard endTouch:(BOOL)endTouch
{
    if (!self.isRecording) {
        return;
    }
    
    if (endTouch && self.logTouchs.count == 0) {
        return;
    }
    
    BSLogTouch *logTouch = [BSLogTouch new];
    logTouch.point = point;
    logTouch.secs = CACurrentMediaTime() - self.startRecMediaTime;
    logTouch.isKeyboard = isKeyboard;
    logTouch.endTouch = endTouch;
    
    [self.logTouchs addObject:logTouch];
}

- (void)startRecord
{
    [BSUITestFileHelper createUITestDirIfNeeded];
    
    self.isRecording = YES;
    self.startRecMediaTime = CACurrentMediaTime();
    self.startRecTimestamp = [[NSDate date] timeIntervalSince1970];
    [self clearLogTouchs];
    
    if (self.screenRecEnable) {
        NSString *fileName = [NSString stringWithFormat:@"record_%@.mp4",@(self.startRecTimestamp)];
        NSString *filePath = [[BSUITestFileHelper uiTestDir] stringByAppendingPathComponent:fileName];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
        
        [self startScreenRecord:fileURL];
    }
    
    KTouchPointerWindowInstall();
}

- (void)stopRecord
{
    self.isRecording = NO;
    self.endRecMediaTime = CACurrentMediaTime();
    
    if (self.screenRecEnable) {
        [self stopScreenRecord:nil];
    }
    
    KTouchPointerWindowUninstall();
}

// recordName_startRecTimestamp_duration
- (void)saveRecord:(NSString *)recordName
{
    if (self.logTouchs.count == 0) {
        return;
    }
    
    NSTimeInterval duration = self.endRecMediaTime - self.startRecMediaTime;
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@", recordName, @(self.startRecTimestamp), @(duration)];
    NSString *filePath = [[BSUITestFileHelper uiTestDir] stringByAppendingPathComponent:fileName];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSKeyedArchiver archiveRootObject:self.logTouchs toFile:filePath];
    });
}

- (void)clearLogTouchs
{
    [self.logTouchs removeAllObjects];
}

#pragma mark - replay回放

- (void)replayLastRecord:(uint32_t)count complete:(dispatch_block_t)complete
{
    [self replayRecord:self.logTouchs repeatCount:count recTimestamp:self.startRecTimestamp complete:complete];
}

- (void)replayHistoryRecord:(NSString *)recordFileName repeatCount:(int32_t)repeatCount complete:(dispatch_block_t)complete
{
    if (recordFileName.length == 0) {
        if (complete) {
            complete();
        }
        return;
    }
    
    NSArray<NSString *> *recordFileArray = [recordFileName componentsSeparatedByString:@"_"];
    NSString *recTimestamp = recordFileArray[1];
    recordFileName = [[BSUITestFileHelper uiTestDir] stringByAppendingPathComponent:recordFileName];
    NSArray<BSLogTouch *> *logTouchs = [NSKeyedUnarchiver unarchiveObjectWithFile:recordFileName];
    
    [self replayRecord:logTouchs repeatCount:repeatCount recTimestamp:[recTimestamp doubleValue] complete:complete];
}

- (void)replayRecord:(NSArray<BSLogTouch *> *)logTouch
         repeatCount:(int32_t)repeatCount
        recTimestamp:(NSTimeInterval)recTimestamp
            complete:(dispatch_block_t)complete
{
    dispatch_async(self.serialQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.recWindow.hidden = YES;
        });
        
        __block int32_t bRepeatCount = repeatCount;
        
        while (bRepeatCount > 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.screenRecEnable) {
                    NSString *replayFilePath = [[BSUITestFileHelper uiTestDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"replay_%@_%@.mp4",@(recTimestamp), @([[NSDate date] timeIntervalSince1970])]];
                    [self startScreenRecord:[NSURL fileURLWithPath:replayFilePath isDirectory:NO]];
                }
                KTouchPointerWindowInstall();
            });
            
            dispatch_semaphore_t semphore = dispatch_semaphore_create(0);
            [logTouch enumerateObjectsUsingBlock:^(BSLogTouch * _Nonnull touch, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CGPoint point = touch.point;
                double secs = touch.secs;
                BOOL isKeyboard = touch.isKeyboard;
                BOOL endTouch = touch.endTouch;
                
                // 精准延迟调用
                [TPPreciseTimer scheduleBlock:^{
                    if (!endTouch) {
                        // 虚拟点击
                        NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:point withTouchPhase:UITouchPhaseBegan isKeyboard:isKeyboard];
                        [PTFakeMetaTouch fakeTouchId:pointId AtPoint:point withTouchPhase:UITouchPhaseEnded isKeyboard:isKeyboard];
                    }
                    
                    // 完成一次回放循环
                    if (idx == logTouch.count - 1) {
                        KTouchPointerWindowUninstall();

                        if (self.screenRecEnable) {
                            [self stopScreenRecord:^{
                                dispatch_semaphore_signal(semphore);
                            }];
                        } else {
                            dispatch_semaphore_signal(semphore);
                        }
                        
                        // 最后一次回放循环
                        if (bRepeatCount == 1) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                if (complete) {
                                    self.recWindow.hidden = NO;
                                    complete();
                                }
                            });
                        }
                    }
                } inTimeInterval:secs];
            }];
            
            // 保证上一次循环结束才开始下一次循环
            dispatch_semaphore_wait(semphore, DISPATCH_TIME_FOREVER);
            bRepeatCount--;
        }
    });
}

#pragma mark - screen record 录屏

- (void)startScreenRecord:(NSURL *)fileURL
{
    [self.screenRecorder startRecording:fileURL];
}

- (void)stopScreenRecord:(dispatch_block_t)complete
{
    [self.screenRecorder stopRecording:complete];
}

#pragma mark - hook sendEvent事件

- (void)hookSendEvent
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [UIApplication class];
        
        SEL hookSEL = @selector(sendEvent:);
        SEL originalSEL = @selector(oriSendEvent:);
        SEL mySelfSEL = @selector(bsSendEvent:);
        
        Method hookMethod = class_getInstanceMethod(class, hookSEL);
        Method mySelfMethod = class_getInstanceMethod(self.class, mySelfSEL);
        
        IMP hookMethodIMP = method_getImplementation(hookMethod);
        class_addMethod(class, originalSEL, hookMethodIMP, method_getTypeEncoding(hookMethod));
        
        IMP hookMethodMySelfIMP = method_getImplementation(mySelfMethod);
        class_replaceMethod(class, hookSEL, hookMethodMySelfIMP, method_getTypeEncoding(hookMethod));
    });
}

- (void)bsSendEvent:(UIEvent *)event
{
    [self oriSendEvent:event];
    
    if ([BSUITestLogic sharedInstance].isRecording) {
        [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
            UITouchPhase phase = touch.phase;
            CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
            UIView *view = touch.view;
            UIWindow *window = touch.window;
            BOOL isKeyboardWindow = [window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")];
            
            if (view && phase == UITouchPhaseBegan  && !CGPointEqualToPoint(point, CGPointMake(0, [UIScreen mainScreen].bounds.size.height))) {
                [[BSUITestLogic sharedInstance] record:point isKeyboard:isKeyboardWindow endTouch:[window isKindOfClass:NSClassFromString(@"BSUITestWindow")]];
            }
        }];
    }
}

- (void)oriSendEvent:(UIEvent *)event
{
}

#pragma mark - setter

- (void)setScreenRecEnable:(BOOL)screenRecEnable
{
    objc_setAssociatedObject(self, @selector(screenRecEnable), @(screenRecEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[NSUserDefaults standardUserDefaults] setBool:screenRecEnable forKey:@"BSScreenRecEnable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - getter

- (NSMutableArray *)logTouchs
{
    if (!_logTouchs) {
        _logTouchs = [NSMutableArray array];
    }
    
    return _logTouchs;
}

- (BOOL)screenRecEnable
{
    NSNumber *enableNum = objc_getAssociatedObject(self, _cmd);
    if (enableNum) {
        return enableNum.boolValue;
    }
    
    __block BOOL isEnable = NO;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"BSScreenRecEnable"]) {
            // 默认关闭
            isEnable = NO;
        } else {
            isEnable = [[NSUserDefaults standardUserDefaults] boolForKey:@"BSScreenRecEnable"];
        }
        objc_setAssociatedObject(self, @selector(screenRecEnable), @(isEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    
    return isEnable;
}

@end
