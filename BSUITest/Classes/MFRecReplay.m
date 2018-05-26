//
//  MFRecReplay.m
//  pkgame iOS
//
//  Created by Vic on 2018/5/18.
//

#import "MFRecReplay.h"
#import "SRScreenRecorder.h"

@import AssetsLibrary;
@import Photos;

@interface MFRecReplay()


@property (nonatomic, strong) SRScreenRecorder *screenRecorder;

@end

@implementation MFRecReplay

+ (instancetype)sharedInstance
{
    static MFRecReplay *sharedReplay = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedReplay = [[MFRecReplay alloc] init];
    });
    
    return sharedReplay;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        self.screenRecorder = [[SRScreenRecorder alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
        

    }
    
    return self;
}

- (void)startReplay:(NSURL *)fileURL
{
    [self.screenRecorder startRecording:fileURL];
}

- (void)stopReplay:(dispatch_block_t)complete
{
    [self.screenRecorder stopRecording:complete];
}

@end
