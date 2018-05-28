//
//  BSUIDiffImageController.h
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import <UIKit/UIKit.h>


/**
 录制与回放视频差异截图查看
 */
@interface BSUIDiffImageController : UIViewController


/**
 录制图片
 */
@property (nonatomic, strong) UIImage *recImage;

/**
 回放图片
 */
@property (nonatomic, strong) UIImage *replayImage;

@end
