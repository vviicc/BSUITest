//
//  MFUITestMgr.m
//  pkgame iOS
//
//  Created by Vic on 2018/5/12.
//

#import "MFUITestMgr.h"
#import "MFRecWindow.h"
#import "MFRecReplay.h"
#import "KTouchPointerWindow.h"
#import "TPPreciseTimer.h"
#import <objc/runtime.h>
#import <PTFakeTouch/PTFakeMetaTouch.h>

#define MFPerformOnMain(__func__)   \
if ([NSThread isMainThread]) {      \
    __func__                         \
} else {                             \
    dispatch_async(dispatch_get_main_queue(), ^{    \
        __func__    \
    }); \
}


@interface MFLogTouch : NSObject<NSCoding>
@property (nonatomic, assign) double secs;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) BOOL isKeyboard;
@property (nonatomic, assign) BOOL endTouch;   // 点击结束录制按钮
@end

@implementation MFLogTouch

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

@interface MFUITestMgr()
@property (nonatomic, assign) NSTimeInterval startRecMediaTime;
@property (nonatomic, assign) NSTimeInterval endRecMediaTime;
@property (nonatomic, assign) NSTimeInterval startRecTimestamp;
@property (nonatomic, strong) NSMutableArray<MFLogTouch *> *logTouchs;
@property (nonatomic, strong) MFRecWindow *recWindow;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@end

@implementation MFUITestMgr

+ (instancetype)sharedInstance
{
    static MFUITestMgr *sharedMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMgr = [[MFUITestMgr alloc] init];
    });
        
    return sharedMgr;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.recWindow.hidden = NO;
        self.serialQueue = dispatch_queue_create("com.mf.uitest.mgr", DISPATCH_QUEUE_SERIAL);
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
    
    MFLogTouch *logTouch = [MFLogTouch new];
    logTouch.point = point;
    logTouch.secs = CACurrentMediaTime() - self.startRecMediaTime;
    logTouch.isKeyboard = isKeyboard;
    logTouch.endTouch = endTouch;
    
    [self.logTouchs addObject:logTouch];
}

- (void)startRecord
{
    [self createTouchDir];

    self.isRecording = YES;
    self.startRecMediaTime = CACurrentMediaTime();
    self.startRecTimestamp = [[NSDate date] timeIntervalSince1970];
    [self clearLogTouchs];
    
    NSString *fileName = [NSString stringWithFormat:@"record_%@.mp4",@(self.startRecTimestamp)];
    NSString *filePath = [[self logTouchDir] stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
    
    if (self.screenRecEnable) {
        [[MFRecReplay sharedInstance] startReplay:fileURL];
    }
    
    KTouchPointerWindowInstall();

    [self jumpHome];
}

- (void)stopRecord
{
    self.isRecording = NO;
    self.endRecMediaTime = CACurrentMediaTime();
    
    if (self.screenRecEnable) {
        [[MFRecReplay sharedInstance] stopReplay:^{
            NSLog(@"99999 stopreplayed");
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
    NSString *filePath = [[self logTouchDir] stringByAppendingPathComponent:fileName];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSKeyedArchiver archiveRootObject:self.logTouchs toFile:filePath];
    });
}

- (void)parseFileName:(NSString *)fileName recordInfoBlock:(void (^)(NSString *name, NSString *date, NSString *duration))recordInfoBlock
{
    NSArray<NSString *> *array = [fileName componentsSeparatedByString:@"_"];
    
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    
    if (recordInfoBlock && array.count == 3) {
        NSTimeInterval stamp = [array[1] doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:stamp];
        NSString *dateString = [formatter stringFromDate:date];
        recordInfoBlock(array[0], dateString, array[2]);
    }
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
    recordFileName = [[self logTouchDir] stringByAppendingPathComponent:recordFileName];
    NSArray<MFLogTouch *> *logTouchs = [NSKeyedUnarchiver unarchiveObjectWithFile:recordFileName];
    
    [self replayRecord:logTouchs repeatCount:repeatCount recTimestamp:[recTimestamp doubleValue] complete:complete];
}

- (void)replayRecord:(NSArray<MFLogTouch *> *)logTouch
         repeatCount:(int32_t)repeatCount
        recTimestamp:(NSTimeInterval)recTimestamp
            complete:(dispatch_block_t)complete
{
    dispatch_async(self.serialQueue, ^{
        MFPerformOnMain(self.recWindow.hidden = YES;)
        
        __block int32_t blockCount = repeatCount;
        
        while (blockCount > 0) {
            
            dispatch_semaphore_t semphore = dispatch_semaphore_create(0);
            
            NSString *replayFilePath = [[self logTouchDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"replay_%@_%@.mp4",@(recTimestamp), @([[NSDate date] timeIntervalSince1970])]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.screenRecEnable) {
                    [[MFRecReplay sharedInstance] startReplay:[NSURL fileURLWithPath:replayFilePath isDirectory:NO]];
                }
                KTouchPointerWindowInstall();
            });
            
            [logTouch enumerateObjectsUsingBlock:^(MFLogTouch * _Nonnull touch, NSUInteger idx, BOOL * _Nonnull stop) {
                
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
                            [self jumpHome];
                            if (complete) {
                                self.recWindow.hidden = NO;
                                complete();
                            }
                        });
                    }
                    
                    if (idx == logTouch.count - 1) {
                        if (self.screenRecEnable) {
                            [[MFRecReplay sharedInstance] stopReplay:^{
                                dispatch_semaphore_signal(semphore);
                            }];
                        } else {
                            dispatch_semaphore_signal(semphore);
                        }
                        
                        NSLog(@"99999,stopreplayed");
                        KTouchPointerWindowUninstall();
                    }
                } inTimeInterval:secs];
                
            }];
            
            dispatch_semaphore_wait(semphore, DISPATCH_TIME_FOREVER);
            blockCount--;
        }
    });
}

- (NSArray<NSString *> *)historyLogTouchPath
{
    NSString *touchDir = [self logTouchDir];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:touchDir];

    NSMutableArray<NSString *> *tempPaths = [NSMutableArray array];
    NSString *path = nil;
    while ((path = [enumerator nextObject]) != nil) {
        if (![path.pathExtension isEqualToString:@"mp4"]) {
            [tempPaths addObject:path];
        }
    }
    
    [tempPaths sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        NSNumber *timestamp1 = @([[[obj1 componentsSeparatedByString:@"_"] objectAtIndex:1] doubleValue]);
        NSNumber *timestamp2 = @([[[obj2 componentsSeparatedByString:@"_"] objectAtIndex:1] doubleValue]);
        return [timestamp2 compare:timestamp1];
    }];
    
    return [NSArray arrayWithArray:tempPaths];
}

- (void)historyRecVideo:(NSString *)recTimestamp videosCallback:(void(^)(NSString *recVideoName, NSArray<NSString *> *replayVideos))videosCallback
{
    NSString *touchDir = [self logTouchDir];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:touchDir];
    
    NSString *path = nil;
    NSString *recVideo = nil;
    NSMutableArray<NSString *> *replayVideeos = [NSMutableArray array];
    while ((path = [enumerator nextObject]) != nil) {
        if ([path.pathExtension isEqualToString:@"mp4"]) {
            if ([path hasPrefix:[NSString stringWithFormat:@"record_%@", recTimestamp]]) {
                recVideo = path;
            } else if ([path hasPrefix:[NSString stringWithFormat:@"replay_%@", recTimestamp]]) {
                [replayVideeos addObject:path];
            }
        }
    }
    
    if (videosCallback) {
        videosCallback(recVideo, replayVideeos.copy);
    }
}

- (void)removeRecord:(NSString *)recName
{
    NSString *touchDir = [self logTouchDir];
    NSString *recPath = [touchDir stringByAppendingPathComponent:recName];
    [[NSFileManager defaultManager] removeItemAtPath:recPath error:nil];
    
    NSString *recTimestamp = [[recName componentsSeparatedByString:@"_"] objectAtIndex:1];
    [self historyRecVideo:recTimestamp videosCallback:^(NSString *recVideoName, NSArray<NSString *> *replayVideos) {
        [self removeReplayVideo:recVideoName];
        
        [replayVideos enumerateObjectsUsingBlock:^(NSString * _Nonnull replayVideo, NSUInteger idx, BOOL * _Nonnull stop) {
            [self removeReplayVideo:replayVideo];
        }];
    }];
}

- (void)removeReplayVideo:(NSString *)videoFile
{
    NSString *touchDir = [self logTouchDir];
    NSString *videoPath = [touchDir stringByAppendingPathComponent:videoFile];
    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
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
        isEnable = [[NSUserDefaults standardUserDefaults] boolForKey:@"MFScreenRecEnable"];
        objc_setAssociatedObject(self, @selector(screenRecEnable), @(isEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    
    return isEnable;
}

- (void)setScreenRecEnable:(BOOL)screenRecEnable
{
    objc_setAssociatedObject(self, @selector(screenRecEnable), @(screenRecEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[NSUserDefaults standardUserDefaults] setBool:screenRecEnable forKey:@"MFScreenRecEnable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - private

- (void)jumpHome
{
    if (self.goHomeUIBlock) {
        self.goHomeUIBlock();
    }
}

- (void)clearLogTouchs
{
    [self.logTouchs removeAllObjects];
}

- (void)createTouchDir
{
    NSString *touchDir = [self logTouchDir];
    
    BOOL isDirectory;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:touchDir isDirectory:&isDirectory] && isDirectory;
    
    if (!isExists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:touchDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSString *)logTouchDir
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *touchDir = [cachePath stringByAppendingPathComponent:@"TouchDir"];
    return touchDir;
}

#pragma mark - getter

- (NSMutableArray<MFLogTouch *> *)logTouchs
{
    if (!_logTouchs) {
        _logTouchs = [NSMutableArray array];
    }
    
    return _logTouchs;
}

- (MFRecWindow *)recWindow
{
    if (!_recWindow) {
        _recWindow = [[MFRecWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    return _recWindow;
}

@end
