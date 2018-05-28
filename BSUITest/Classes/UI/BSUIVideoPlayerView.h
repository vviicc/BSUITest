//
//  BSUIVideoPlayerView.h
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import <UIKit/UIKit.h>


/**
 视频播放View
 */
@interface BSUIVideoPlayerView : UIView

- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL;

- (void)playAgain;

@end
