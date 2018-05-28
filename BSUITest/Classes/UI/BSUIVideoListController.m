//
//  BSUIVideoListController.m
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import "BSUIVideoListController.h"
#import "BSUIVideoPlayerController.h"
#import "BSUIVideoCompareController.h"
#import "BSUITestLogic.h"
#import "BSUITestFileHelper.h"

static NSString * const kBSVideoListCellIdentifier = @"kBSVideoListCellIdentifier";

@interface BSVideoListCell : UITableViewCell

@property (nonatomic, copy) void(^didClickPlayVideo)(int32_t cellIndex, BOOL isRecVideo);
@property (nonatomic, copy) void(^didClickCompare)(int32_t cellIndex);

- (void)updateCell:(NSString *)videoDate cellIndex:(int32_t)cellIndex isRecVideo:(BOOL)isRecVideo;

@end

@interface BSVideoListCell()
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *playVideoBtn;
@property (nonatomic, strong) UIButton *compareBtn;

@property (nonatomic, assign) int32_t cellIndex;
@property (nonatomic, assign) BOOL isRecVideo;
@end

@implementation BSVideoListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dateLabel.frame = CGRectMake(10, 0, CGRectGetWidth(self.bounds) - 150, CGRectGetHeight(self.bounds));
    self.playVideoBtn.frame = CGRectMake(CGRectGetWidth(self.bounds) - 150, 0, 70, CGRectGetHeight(self.bounds));
    self.compareBtn.frame = CGRectMake(CGRectGetMaxX(self.playVideoBtn.frame) + 5, 0, 70, CGRectGetHeight(self.bounds));
}

- (void)initViews
{
    UIView *contentView = self.contentView;
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.dateLabel.font = [UIFont systemFontOfSize:13];
    [contentView addSubview:self.dateLabel];
    
    self.playVideoBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.playVideoBtn setTitle:@"观看视频" forState:UIControlStateNormal];
    [self.playVideoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.playVideoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.playVideoBtn addTarget:self action:@selector(onClickPlayVideo) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:self.playVideoBtn];
    
    self.compareBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.compareBtn setTitle:@"对比分析" forState:UIControlStateNormal];
    [self.compareBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.compareBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.compareBtn addTarget:self action:@selector(onClickCompare) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:self.compareBtn];
}

- (void)updateCell:(NSString *)videoDate cellIndex:(int32_t)cellIndex isRecVideo:(BOOL)isRecVideo
{
    self.dateLabel.text = videoDate;
    self.cellIndex = cellIndex;
    self.compareBtn.hidden = isRecVideo;
    self.isRecVideo = isRecVideo;
}

- (void)onClickPlayVideo
{
    if (self.didClickPlayVideo) {
        self.didClickPlayVideo(self.cellIndex, self.isRecVideo);
    }
}

- (void)onClickCompare
{
    if (self.didClickCompare) {
        self.didClickCompare(self.cellIndex);
    }
}

@end

@interface BSUIVideoListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *recVideo;
@property (nonatomic, strong) NSMutableArray<NSString *> *replayVideos;

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation BSUIVideoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [BSUITestFileHelper historyRecVideo:self.recTimestamp videosCallback:^(NSString *recVideoName, NSArray<NSString *> *replayVideos) {
        self.recVideo = recVideoName;
        self.replayVideos = [NSMutableArray arrayWithArray:([replayVideos reverseObjectEnumerator].allObjects)];
    }];
    
    [self initViews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.closeBtn.frame = CGRectMake(0, 20, 50, 44);
    self.tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64);
    self.emptyLabel.frame = self.tableView.bounds;
    self.titleLabel.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), 44);
}

- (void)initViews
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = [UIColor whiteColor];
    [tableView registerClass:[BSVideoListCell class] forCellReuseIdentifier:kBSVideoListCellIdentifier];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.rowHeight = 66;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    [btn setTitle:@"←" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onClickClose) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn = btn;
    [self.view addSubview:btn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = self.recName;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    self.titleLabel = titleLabel;
    [self.view addSubview:titleLabel];
    
    self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.emptyLabel.text = @"没有录屏文件\n请打开录屏开关,录制后再来看看";
    self.emptyLabel.numberOfLines = 2;
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.textColor = [UIColor lightGrayColor];
    [self.tableView addSubview:self.emptyLabel];
    self.emptyLabel.hidden = self.recVideo.length != 0;
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.recVideo.length == 0) {
        return 0;
    }
    
    return (self.replayVideos.count > 0 ? 1 : 0) + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0 ? @"录制视频" : @"最近回放";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return self.replayVideos.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSVideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:kBSVideoListCellIdentifier forIndexPath:indexPath];
    
    NSString *videoDate = nil;
    if (indexPath.section == 0) {
        videoDate = [self videoDate:nil isRecVideo:YES];
    } else if (indexPath.row < self.replayVideos.count) {
        videoDate = [self videoDate:self.replayVideos[indexPath.row] isRecVideo:NO];
    }
    
    [cell updateCell:videoDate cellIndex:(int32_t)indexPath.row isRecVideo:(indexPath.section == 0)];
    
    __weak __typeof(self)weakSelf = self;
    
    cell.didClickPlayVideo = ^(int32_t cellIndex, BOOL isRecVideo) {
        [weakSelf playVideo:cellIndex isRecVideo:isRecVideo];
    };
    
    cell.didClickCompare = ^(int32_t cellIndex) {
        [weakSelf compareVideo:cellIndex];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int32_t cellIndex = (int32_t)indexPath.row;
    BOOL isRecVideo = indexPath.section == 0;
    [self playVideo:cellIndex isRecVideo:isRecVideo];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row >= self.replayVideos.count) {
            return;
        }
        
        NSString *videoName = self.replayVideos[indexPath.row];
        [self.replayVideos removeObjectAtIndex:indexPath.row];
        [BSUITestFileHelper removeReplayVideo:videoName];
        
        if (self.replayVideos.count == 0) {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }
    
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)playVideo:(int32_t)cellIndex isRecVideo:(BOOL)isRecVideo
{
    NSString *videoName = nil;
    if (isRecVideo) {
        videoName = self.recVideo;
    } else if (cellIndex < self.replayVideos.count){
        videoName = self.replayVideos[cellIndex];
    }
    
    if (!videoName) {
        return;
    }
    
    NSString *touchDir = [BSUITestFileHelper uiTestDir];
    NSString *videoFilePath = [touchDir stringByAppendingPathComponent:videoName];
    NSURL *videoFileURL = [NSURL fileURLWithPath:videoFilePath isDirectory:NO];
    
    BSUIVideoPlayerController *playVideoController = [[BSUIVideoPlayerController alloc] init];
    playVideoController.videoURL = videoFileURL;
    
    [self presentViewController:playVideoController animated:YES completion:nil];
}

- (void)compareVideo:(int32_t)cellIndex
{
    if (cellIndex >= self.replayVideos.count) {
        return;
    }
    
    BSUIVideoCompareController *videoCompare = [[BSUIVideoCompareController alloc] init];
    NSString *touchDir = [BSUITestFileHelper uiTestDir];
    NSString *recFilePath = [touchDir stringByAppendingPathComponent:self.recVideo];
    NSString *replayFilePath = [touchDir stringByAppendingPathComponent:self.replayVideos[cellIndex]];
    
    videoCompare.recURL = [NSURL fileURLWithPath:recFilePath isDirectory:NO];
    videoCompare.replayURL = [NSURL fileURLWithPath:replayFilePath isDirectory:NO];
    [self presentViewController:videoCompare animated:YES completion:nil];
}

- (NSString *)videoDate:(NSString *)videoFile isRecVideo:(BOOL)isRecVideo
{
    NSArray *array = [videoFile componentsSeparatedByString:@"_"];
    NSTimeInterval videoTimestamp = 0;
    if (isRecVideo) {
        videoTimestamp = self.recTimestamp.doubleValue;
    } else {
        videoTimestamp = [array[2] doubleValue];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:videoTimestamp];
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

- (void)onClickClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
