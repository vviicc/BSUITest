//
//  BSUIVideoCompareController.m
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import "BSUIVideoCompareController.h"
#import "BSUIDiffImageController.h"
#import "BSUIVideoPlayerView.h"
#import "UIImageDiff.h"

@import AVFoundation;

static NSString * const kBSVideoCompareCellIdentifier = @"kBSVideoCompareCellIdentifier";
static NSInteger const kBSImageDiffValue = 5;       // 图片差异阈值，越小精度越高
static CGFloat const kBSVideoSamplingTime = 0.2;    // 视频采样截图时间间隔

@interface BSDiffImageObject : NSObject
@property (nonatomic, strong) UIImage *recImage;
@property (nonatomic, strong) UIImage *replayImage;
@property (nonatomic, assign) NSInteger diffValue;
@property (nonatomic, assign) CGFloat time;
@end

@implementation BSDiffImageObject

@end

@interface BSUIVideoCompareController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) BSUIVideoPlayerView *recVideoPlayer;
@property (nonatomic, strong) BSUIVideoPlayerView *replayVideoPlayer;
@property (nonatomic, strong) UILabel *recLabel;
@property (nonatomic, strong) UILabel *replayLabel;
@property (nonatomic, strong) UIButton *playAgainBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *allSameTipLabel;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) NSMutableArray<BSDiffImageObject *> *diffImageArray;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation BSUIVideoCompareController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
    [self initNotifys];
    
    self.diffImageArray = [NSMutableArray array];
    self.serialQueue = dispatch_queue_create("com.bs.uitest.videoCompare", DISPATCH_QUEUE_SERIAL);
    
    __weak __typeof(self)weakSelf = self;
    [self compareRecVideo:self.recURL replayVideo:self.replayURL complete:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.indicatorView stopAnimating];
            weakSelf.allSameTipLabel.hidden = weakSelf.diffImageArray.count != 0;
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.closeBtn.frame = CGRectMake(0, 0, 50, 44);
    self.recLabel.frame = CGRectMake(0, 24, CGRectGetWidth(self.view.bounds) / 2.0, 20);
    self.replayLabel.frame = CGRectMake(CGRectGetMaxX(self.recLabel.frame), CGRectGetMinY(self.recLabel.frame), CGRectGetWidth(self.recLabel.bounds), CGRectGetHeight(self.recLabel.bounds));
    self.playAgainBtn.frame = CGRectMake(0, CGRectGetMinY(self.recLabel.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.recLabel.bounds));
    self.recVideoPlayer.frame = CGRectMake(0, 44, CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(self.view.bounds) / 2.0);
    self.replayVideoPlayer.frame = CGRectMake(CGRectGetMaxX(self.recVideoPlayer.frame), CGRectGetMinY(self.recVideoPlayer.frame), CGRectGetWidth(self.recVideoPlayer.frame), CGRectGetHeight(self.recVideoPlayer.frame));
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.recVideoPlayer.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) / 2.0 - 44);
    self.allSameTipLabel.frame = self.tableView.bounds;
    self.indicatorView.center = CGPointMake(CGRectGetWidth(self.tableView.bounds) / 2.0, CGRectGetHeight(self.tableView.bounds) / 2.0);
}

- (void)initNotifys
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoPlayEnded:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (void)onVideoPlayEnded:(id)sender
{
    static int totalPlayEndCount = 0;
    totalPlayEndCount += 1;
    
    // 两个视频都播放完毕
    if (totalPlayEndCount == 2) {
        self.playAgainBtn.hidden = NO;
        totalPlayEndCount = 0;
    }
}

- (void)onClickPlayAgain
{
    self.playAgainBtn.hidden = YES;
    [self.recVideoPlayer playAgain];
    [self.replayVideoPlayer playAgain];
}

- (void)initViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.recVideoPlayer = [[BSUIVideoPlayerView alloc] initWithFrame:CGRectZero videoURL:self.recURL];
    [self.view addSubview:self.recVideoPlayer];
    
    self.replayVideoPlayer = [[BSUIVideoPlayerView alloc] initWithFrame:CGRectZero videoURL:self.replayURL];
    [self.view addSubview:self.replayVideoPlayer];
    
    self.recLabel = [self titleLabel:@"录制视频"];
    [self.view addSubview:self.recLabel];
    
    self.replayLabel = [self titleLabel:@"回放视频"];
    [self.view addSubview:self.replayLabel];
    
    self.playAgainBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.playAgainBtn addTarget:self action:@selector(onClickPlayAgain) forControlEvents:UIControlEventTouchUpInside];
    [self.playAgainBtn setTitle:@"再次播放" forState:UIControlStateNormal];
    [self.playAgainBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.playAgainBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.playAgainBtn.hidden = YES;
    [self.view addSubview:self.playAgainBtn];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    
    self.allSameTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.allSameTipLabel.text = @"没有差异图片，完美！";
    self.allSameTipLabel.textAlignment = NSTextAlignmentCenter;
    self.allSameTipLabel.textColor = [UIColor lightGrayColor];
    self.allSameTipLabel.hidden = YES;
    [self.tableView addSubview:self.allSameTipLabel];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.tableView addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    [btn setTitle:@"X" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onClickClose) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn = btn;
    [self.view addSubview:btn];
}

- (UILabel *)titleLabel:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    label.font = [UIFont systemFontOfSize:15];
    return label;
}

- (void)onClickClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - video compare

- (void)compareRecVideo:(NSURL *)recURL replayVideo:(NSURL *)replayURL complete:(dispatch_block_t)complete
{
    int32_t recSecs = [self videoDuration:recURL];
    int32_t replaySecs = [self videoDuration:replayURL];
    int32_t secs = MIN(recSecs, replaySecs);
    
    CGFloat i = 0.0;
    
    while (i <= secs) {
        __weak __typeof(self) weakSelf = self;
        dispatch_async(self.serialQueue, ^{
            __strong __typeof(self) strongSelf = weakSelf;
            
            @autoreleasepool {
                if (strongSelf) {
                    UIImage *recImage = [strongSelf videoImage:recURL time:i];
                    UIImage *replayImage = [strongSelf videoImage:replayURL time:i];
                    
                    NSInteger diff = [UIImageDiff differentValueCountWithImage:recImage andAnotherImage:replayImage];
                    
                    if (diff > kBSImageDiffValue) {
                        BSDiffImageObject *diffImageObj = [BSDiffImageObject new];
                        diffImageObj.recImage = [strongSelf compressImage:recImage];
                        diffImageObj.replayImage = [strongSelf compressImage:replayImage];
                        diffImageObj.diffValue = diff;
                        diffImageObj.time = i;
                        
                        [strongSelf.diffImageArray addObject:diffImageObj];
                    }
                    
                    if ((i + kBSVideoSamplingTime > secs) && complete) {
                        complete();
                    }
                }
            }
        });
        
        i += kBSVideoSamplingTime;
    }
}

- (UIImage *)compressImage:(UIImage *)oriImage
{
    NSData *data = UIImageJPEGRepresentation(oriImage, 0.7);
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

- (UIImage *)videoImage:(NSURL *)videoURL time:(CGFloat)time
{
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    AVAssetImageGenerator* generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CGImageRef cgImage = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(time, 1) actualTime:nil error:nil];
    UIImage* image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return image;
}

- (int32_t)videoDuration:(NSURL *)videoURL
{
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    int32_t secs = (int32_t)(asset.duration.value / asset.duration.timescale);
    return secs;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.diffImageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBSVideoCompareCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kBSVideoCompareCellIdentifier];
    }
    
    if (indexPath.row < self.diffImageArray.count) {
        BSDiffImageObject *diffImageObj = self.diffImageArray[indexPath.row];
        UIImage *recImage = diffImageObj.recImage;
        CGFloat time = diffImageObj.time;
        NSInteger diffValue = diffImageObj.diffValue;
        
        cell.imageView.image = recImage;
        cell.textLabel.text = [NSString stringWithFormat:@"差异值:%@", @(diffValue)];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"时间点(秒):%.1f",time];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *diffCount = self.diffImageArray.count == 0 ? @"" : [NSString stringWithFormat:@":%@处",@(self.diffImageArray.count)];
    return [NSString stringWithFormat:@"差异图片%@(差异值越大越不相似)",diffCount];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= self.diffImageArray.count) {
        return;
    }
    
    BSDiffImageObject *diffImageObj = self.diffImageArray[indexPath.row];
    UIImage *recImage = diffImageObj.recImage;
    UIImage *replayImage = diffImageObj.replayImage;
    
    BSUIDiffImageController *diffImageCtrl = [[BSUIDiffImageController alloc] init];
    diffImageCtrl.recImage = recImage;
    diffImageCtrl.replayImage = replayImage;
    
    [self presentViewController:diffImageCtrl animated:YES completion:nil];
}


@end
