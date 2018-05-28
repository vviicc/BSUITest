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


@interface BSLogTouch : NSObject<NSCoding>
@property (nonatomic, assign) double secs;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) BOOL isKeyboard;
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

@interface BSUITestLogic()

@property (nonatomic, assign) NSTimeInterval startRecMediaTime;
@property (nonatomic, assign) NSTimeInterval endRecMediaTime;
@property (nonatomic, assign) NSTimeInterval startRecTimestamp;

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

- (void)hookSendEvent
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [UIApplication class];
        
        SEL originalSEL = @selector(sendEvent:);
        SEL swizzledSEL = @selector(bsSendEvent:);
        Method originalMethod = class_getInstanceMethod(class, originalSEL);
        Method swizzledMethod = class_getInstanceMethod(self.class, swizzledSEL);
        
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
    });
}

- (void)bsSendEvent:(UIEvent *)event
{
    [self bsSendEvent:event];
    
    if (self.isRecording) {
        [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
            UITouchPhase phase = touch.phase;
            CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
            UIView *view = touch.view;
            UIWindow *window = touch.window;
            BOOL isKeyboardWindow = [window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")];
            
            if (view && phase == UITouchPhaseBegan  && !CGPointEqualToPoint(point, CGPointMake(0, [UIScreen mainScreen].bounds.size.height))) {
                [self record:point isKeyboard:isKeyboardWindow endTouch:[window isKindOfClass:NSClassFromString(@"MFRecWindow")]];
            }
        }];
    }
}

- (void)startRecord
{
    [BSUITestFileHelper createTouchDirIfNeeded];
    
    self.isRecording = YES;
    self.startRecMediaTime = CACurrentMediaTime();
    self.startRecTimestamp = [[NSDate date] timeIntervalSince1970];
    [self clearLogTouchs];
    
    NSString *fileName = [NSString stringWithFormat:@"record_%@.mp4",@(self.startRecTimestamp)];
    NSString *filePath = [[BSUITestFileHelper logTouchDir] stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
    
    if (self.screenRecEnable) {
        [self startReplay:fileURL];
    }
    
    KTouchPointerWindowInstall();
    
}

- (void)stopRecord
{
    self.isRecording = NO;
    self.endRecMediaTime = CACurrentMediaTime();
    
    if (self.screenRecEnable) {
        [self stopReplay:^{
        }];
    }
    
    KTouchPointerWindowUninstall();
}

// name_time_duration
- (void)saveRecord:(NSString *)recordName
{
    if (self.logTouchs.count == 0) {
        return;
    }
    
    NSTimeInterval duration = self.endRecMediaTime - self.startRecMediaTime;
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@", recordName, @(self.startRecTimestamp), @(duration)];
    NSString *filePath = [[BSUITestFileHelper logTouchDir] stringByAppendingPathComponent:fileName];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSKeyedArchiver archiveRootObject:self.logTouchs toFile:filePath];
    });
}

- (void)clearLogTouchs
{
    [self.logTouchs removeAllObjects];
}

- (void)startReplay:(NSURL *)fileURL
{
    [self.screenRecorder startRecording:fileURL];
}

- (void)stopReplay:(dispatch_block_t)complete
{
    [self.screenRecorder stopRecording:complete];
}

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
    recordFileName = [[BSUITestFileHelper logTouchDir] stringByAppendingPathComponent:recordFileName];
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
        
        __block int32_t blockCount = repeatCount;
        
        while (blockCount > 0) {
            
            dispatch_semaphore_t semphore = dispatch_semaphore_create(0);
            
            NSString *replayFilePath = [[BSUITestFileHelper logTouchDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"replay_%@_%@.mp4",@(recTimestamp), @([[NSDate date] timeIntervalSince1970])]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.screenRecEnable) {
                    [self startReplay:[NSURL fileURLWithPath:replayFilePath isDirectory:NO]];
                }
                KTouchPointerWindowInstall();
            });
            
            [logTouch enumerateObjectsUsingBlock:^(BSLogTouch * _Nonnull touch, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CGPoint point = touch.point;
                double secs = touch.secs;
                BOOL isKeyboard = touch.isKeyboard;
                BOOL endTouch = touch.endTouch;
                
                [TPPreciseTimer scheduleBlock:^{
                    if (!endTouch) {
                        NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:point withTouchPhase:UITouchPhaseBegan isKeyboard:isKeyboard];
                        [PTFakeMetaTouch fakeTouchId:pointId AtPoint:point withTouchPhase:UITouchPhaseEnded isKeyboard:isKeyboard];
                    }
                    
                    if (blockCount == 1 && idx == logTouch.count - 1) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            if (complete) {
                                self.recWindow.hidden = NO;
                                complete();
                            }
                        });
                    }
                    
                    if (idx == logTouch.count - 1) {
                        if (self.screenRecEnable) {
                            [self stopReplay:^{
                                dispatch_semaphore_signal(semphore);
                            }];
                        } else {
                            dispatch_semaphore_signal(semphore);
                        }
                        
                        KTouchPointerWindowUninstall();
                    }
                } inTimeInterval:secs];
                
            }];
            
            dispatch_semaphore_wait(semphore, DISPATCH_TIME_FOREVER);
            blockCount--;
        }
    });
}

@end
