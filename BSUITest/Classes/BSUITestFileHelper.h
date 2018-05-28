//
//  BSUITestFileHelper.h
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import <Foundation/Foundation.h>


/**
 文件存储相关helper
 */
@interface BSUITestFileHelper : NSObject

/**
 创建UITest根目录
 */
+ (void)createUITestDirIfNeeded;

/**
 UITest根目录
 */
+ (NSString *)uiTestDir;

/**
 本地保存的录制用例路径
 */
+ (NSArray<NSString *> *)historyRecordPath;

/**
 通过录制文件名解析用例名称、时间、时长
 */
+ (void)parseFileName:(NSString *)fileName recordInfoBlock:(void (^)(NSString *name, NSString *date, NSString *duration))recordInfoBlock;

/**
 通过录制用例查找相关的录制、回放视频
 */
+ (void)historyRecVideo:(NSString *)recTimestamp videosCallback:(void(^)(NSString *recVideoName, NSArray<NSString *> *replayVideos))videosCallback;

/**
 删除录制用例，包括相关视频
 */
+ (void)removeRecord:(NSString *)recName;

/**
 删除回放视频
 */
+ (void)removeReplayVideo:(NSString *)videoFile;


@end
