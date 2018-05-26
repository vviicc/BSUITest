//
//  MFUITestMgr.h
//  pkgame iOS
//
//  Created by Vic on 2018/5/12.
//

#import <Foundation/Foundation.h>

@interface MFUITestMgr : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy) dispatch_block_t goHomeUIBlock;

@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, assign) BOOL screenRecEnable;

@property (nonatomic, strong, readonly) NSMutableArray *logTouchs;

- (void)startRecord;

- (void)stopRecord;

- (void)saveRecord:(NSString *)recordName;

- (void)replayLastRecord:(uint32_t)count complete:(dispatch_block_t)complete;

- (void)record:(CGPoint)point isKeyboard:(BOOL)isKeyboard endTouch:(BOOL)endTouch;

- (void)replayHistoryRecord:(NSString *)recordPath repeatCount:(int32_t)repeatCount complete:(dispatch_block_t)complete;

- (NSString *)logTouchDir;

- (NSArray<NSString *> *)historyLogTouchPath;

- (void)historyRecVideo:(NSString *)recTimestamp videosCallback:(void(^)(NSString *recVideoName, NSArray<NSString *> *replayVideos))videosCallback;

- (void)removeRecord:(NSString *)recName;

- (void)removeReplayVideo:(NSString *)videoFile;

- (void)parseFileName:(NSString *)fileName recordInfoBlock:(void (^)(NSString *name, NSString *date, NSString *duration))recordInfoBlock;

@end
