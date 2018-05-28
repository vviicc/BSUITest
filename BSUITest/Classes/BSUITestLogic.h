//
//  BSUITestLogic.h
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import <Foundation/Foundation.h>

@import UIKit;
@import CoreGraphics;

@interface BSUITestLogic : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, weak) UIWindow *recWindow;

@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, assign) BOOL screenRecEnable;

@property (nonatomic, strong, readonly) NSMutableArray *logTouchs;

- (void)hookSendEvent;

- (void)startRecord;

- (void)stopRecord;

- (void)saveRecord:(NSString *)recordName;

- (void)replayLastRecord:(uint32_t)count complete:(dispatch_block_t)complete;

- (void)record:(CGPoint)point isKeyboard:(BOOL)isKeyboard endTouch:(BOOL)endTouch;

- (void)replayHistoryRecord:(NSString *)recordPath repeatCount:(int32_t)repeatCount complete:(dispatch_block_t)complete;

@end
