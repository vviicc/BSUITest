//
//  BSUITestFileHelper.h
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import <Foundation/Foundation.h>

@interface BSUITestFileHelper : NSObject

+ (NSString *)logTouchDir;

+ (void)createTouchDirIfNeeded;

+ (NSArray<NSString *> *)historyLogTouchPath;

+ (void)historyRecVideo:(NSString *)recTimestamp videosCallback:(void(^)(NSString *recVideoName, NSArray<NSString *> *replayVideos))videosCallback;

+ (void)removeRecord:(NSString *)recName;

+ (void)removeReplayVideo:(NSString *)videoFile;

+ (void)parseFileName:(NSString *)fileName recordInfoBlock:(void (^)(NSString *name, NSString *date, NSString *duration))recordInfoBlock;

@end
