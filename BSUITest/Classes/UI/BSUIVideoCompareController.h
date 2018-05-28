//
//  BSUIVideoCompareController.h
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import <UIKit/UIKit.h>


/**
 录制与回放视频对比分析
 */
@interface BSUIVideoCompareController : UIViewController


/**
 录制视频URL
 */
@property (nonatomic, strong) NSURL *recURL;


/**
 回放视频URL
 */
@property (nonatomic, strong) NSURL *replayURL;

@end
