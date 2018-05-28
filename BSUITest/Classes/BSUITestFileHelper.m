//
//  BSUITestFileHelper.m
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import "BSUITestFileHelper.h"

@implementation BSUITestFileHelper

+ (void)createUITestDirIfNeeded
{
    NSString *touchDir = [self uiTestDir];
    
    BOOL isDirectory;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:touchDir isDirectory:&isDirectory] && isDirectory;
    
    if (!isExists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:touchDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (NSString *)uiTestDir
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dir = [cachePath stringByAppendingPathComponent:@"BSUITest"];
    return dir;
}

+ (NSArray<NSString *> *)historyRecordPath
{
    NSString *touchDir = [self uiTestDir];
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

+ (void)parseFileName:(NSString *)fileName recordInfoBlock:(void (^)(NSString *name, NSString *date, NSString *duration))recordInfoBlock
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

+ (void)historyRecVideo:(NSString *)recTimestamp videosCallback:(void(^)(NSString *recVideoName, NSArray<NSString *> *replayVideos))videosCallback
{
    NSString *touchDir = [self uiTestDir];
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

+ (void)removeRecord:(NSString *)recName
{
    NSString *touchDir = [self uiTestDir];
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

+ (void)removeReplayVideo:(NSString *)videoFile
{
    NSString *touchDir = [self uiTestDir];
    NSString *videoPath = [touchDir stringByAppendingPathComponent:videoFile];
    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
}

@end
