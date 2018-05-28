//
//  BSUIVideoPlayerView.m
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import "BSUIVideoPlayerView.h"

@import AVFoundation;

@interface BSUIVideoPlayerView()

@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, strong) AVAsset *avAsset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) id timeObserver;

@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *playTimeLabel;
@property (nonatomic, strong) UISlider *sliderView;
@property (nonatomic, strong) UILabel *playDurationLabel;

@end

@implementation BSUIVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    NSAssert(NO, @"use initWithFrame:videoURL instead");
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL
{
    if (self = [super initWithFrame:frame]) {
        self.videoURL = videoURL;
        [self initViews];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeVideoKVO];
    [self removeTimeObserver];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.videoView.frame = self.bounds;
    self.avPlayerLayer.frame = self.bounds;
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 20, CGRectGetWidth(self.bounds), 20);
    self.playTimeLabel.frame = CGRectMake(15, 0, 35, CGRectGetHeight(self.bottomView.bounds));
    self.sliderView.frame = CGRectMake(CGRectGetMaxX(self.playTimeLabel.frame) + 5, 0, CGRectGetWidth(self.bounds) - 110, CGRectGetHeight(self.bottomView.bounds));
    self.playDurationLabel.frame = CGRectMake(CGRectGetWidth(self.bottomView.bounds) - 50, 0, 35, CGRectGetHeight(self.bottomView.bounds));
}

- (void)initViews
{
    [self addSubview:self.videoView];
    [self addSubview:self.bottomView];
}

- (void)removeVideoKVO
{
    [self.playerItem removeObserver:self forKeyPath:@"status"];
}

- (void)removeTimeObserver
{
    [self.avPlayer removeTimeObserver:self.timeObserver];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"] && [object isKindOfClass:[AVPlayerItem class]]) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            [self.avPlayer play];
        }
    }
}

- (void)handlePlayPeriodicTimer:(CMTime)time
{
    NSTimeInterval curTime = CMTimeGetSeconds(time);
    NSTimeInterval totTime = CMTimeGetSeconds(self.avPlayer.currentItem.duration);
    CGFloat percent = curTime / totTime;
    NSString *formatCurTime = [self formatPlayTime:curTime];
    NSString *formatTotTime = [self formatPlayTime:totTime];
    
    self.playTimeLabel.text = formatCurTime;
    self.playDurationLabel.text = formatTotTime;
    self.sliderView.value = percent;
}

- (NSString *)formatPlayTime:(NSTimeInterval)time
{
    int min = time / 60;
    int sec = (int32_t)time % 60;
    NSString *formatTime = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    return formatTime;
}

- (void)onSliderChanged:(UISlider *)slider
{
    CGFloat percent = slider.value;
    
    if (self.avPlayer.status == AVPlayerStatusReadyToPlay) {
        NSTimeInterval time = percent * CMTimeGetSeconds(self.avPlayer.currentItem.duration);
        CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
        
        __weak __typeof(self) weakSelf = self;
        [self.avPlayer seekToTime:seekTime completionHandler:^(BOOL finished) {
            [weakSelf.avPlayer play];
        }];
    }
}

- (void)playAgain
{
    if (self.avPlayer.status == AVPlayerStatusReadyToPlay) {
        __weak __typeof(self) weakSelf = self;
        [self.avPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished) {
                [weakSelf.avPlayer play];
            }
        }];
    }
}

#pragma mark - getter

- (AVAsset *)avAsset
{
    if (!_avAsset) {
        _avAsset = [AVAsset assetWithURL:self.videoURL];
    }
    
    return _avAsset;
}

- (AVPlayerItem *)playerItem
{
    if (!_playerItem) {
        _playerItem = [AVPlayerItem playerItemWithAsset:self.avAsset];
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return _playerItem;
}

- (AVPlayer *)avPlayer
{
    if (!_avPlayer) {
        _avPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        __weak __typeof(self) weakSelf = self;
        self.timeObserver = [_avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [weakSelf handlePlayPeriodicTimer:time];
        }];
    }
    
    return _avPlayer;
}

- (AVPlayerLayer *)avPlayerLayer
{
    if (!_avPlayerLayer) {
        _avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        _avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _avPlayerLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    
    return _avPlayerLayer;
}

- (UIView *)videoView
{
    if (!_videoView) {
        _videoView = [[UIView alloc] initWithFrame:CGRectZero];
        [_videoView.layer addSublayer:self.avPlayerLayer];
    }
    
    return _videoView;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [UIColor darkGrayColor];
        [_bottomView addSubview:self.playTimeLabel];
        [_bottomView addSubview:self.sliderView];
        [_bottomView addSubview:self.playDurationLabel];
    }
    
    return _bottomView;
}

- (UISlider *)sliderView
{
    if (!_sliderView) {
        _sliderView = [[UISlider alloc] initWithFrame:CGRectZero];
        _sliderView.minimumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.7];
        _sliderView.maximumTrackTintColor = [UIColor whiteColor];
        CGFloat sliderWidth = 15;
        [_sliderView setThumbImage:[self imageFromColor:[UIColor whiteColor] size:CGSizeMake(sliderWidth, sliderWidth)] forState:UIControlStateNormal];
        
        [_sliderView addTarget:self action:@selector(onSliderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _sliderView;
}

- (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillEllipseInRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UILabel *)playTimeLabel
{
    if (!_playTimeLabel) {
        _playTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _playTimeLabel.font = [UIFont systemFontOfSize:12];
        _playTimeLabel.textColor = [UIColor whiteColor];
    }
    
    return _playTimeLabel;
}

- (UILabel *)playDurationLabel
{
    if (!_playDurationLabel) {
        _playDurationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _playDurationLabel.font = [UIFont systemFontOfSize:12];
        _playDurationLabel.textAlignment = NSTextAlignmentRight;
        _playDurationLabel.textColor = [UIColor whiteColor];
    }
    
    return _playDurationLabel;
}

@end
