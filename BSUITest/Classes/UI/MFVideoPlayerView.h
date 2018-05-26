//
//  MFVideoPlayerView.h
//  pkgame iOS
//
//  Created by Vic on 2018/5/22.
//

#import <UIKit/UIKit.h>

@interface MFVideoPlayerView : UIView

- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL canDrag:(BOOL)canDrag;

- (void)playAgain;

@end
