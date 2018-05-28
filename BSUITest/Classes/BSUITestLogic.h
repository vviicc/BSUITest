//
//  BSUITestLogic.h
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import <Foundation/Foundation.h>


/**
 录制、回放、录屏相关的逻辑类
 */
@interface BSUITestLogic : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, weak) UIWindow *recWindow;


/**
 是否正在录制
 */
@property (nonatomic, assign) BOOL isRecording;

/**
 是否开启录屏功能
 */
@property (nonatomic, assign) BOOL screenRecEnable;

@property (nonatomic, strong, readonly) NSMutableArray *logTouchs;


/**
 hook点击事件
 */
- (void)hookSendEvent;

/**
 开始录制
 */
- (void)startRecord;


/**
 停止录制
 */
- (void)stopRecord;


/**
 保存录制

 @param recordName 用例名称如用户登录用例
 */
- (void)saveRecord:(NSString *)recordName;

/**
 记录每一次的点击事件
 
 @param point 位置
 @param isKeyboard 是否是点了键盘，虚拟点击用到
 @param endTouch 是否是最后一次点击，也就是点击结束录制按钮
 */
- (void)record:(CGPoint)point isKeyboard:(BOOL)isKeyboard endTouch:(BOOL)endTouch;


/**
 回放上一次录制用例

 @param count 循环回放次数
 @param complete 回放完成回调
 */
- (void)replayLastRecord:(uint32_t)count complete:(dispatch_block_t)complete;


/**
 回放录制过的用例

 @param recordPath 本地保存的用例路径
 @param repeatCount 循环回放次数
 @param complete 回放完成回调
 */
- (void)replayHistoryRecord:(NSString *)recordPath repeatCount:(int32_t)repeatCount complete:(dispatch_block_t)complete;

@end
