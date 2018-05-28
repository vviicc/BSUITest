//
//  BSUIVideoPlayerController.m
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import "BSUIVideoPlayerController.h"
#import "BSUIVideoPlayerView.h"

@interface BSUIVideoPlayerController ()

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) BSUIVideoPlayerView *playerView;

@end

@implementation BSUIVideoPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.closeBtn.frame = CGRectMake(0, 0, 50, 44);
    self.playerView.frame = self.view.bounds;
}

- (void)initViews
{
    self.playerView = [[BSUIVideoPlayerView alloc] initWithFrame:CGRectZero videoURL:self.videoURL];
    [self.view addSubview:self.playerView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    [btn setTitle:@"X" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onClickClose) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn = btn;
    [self.view addSubview:btn];
}

- (void)onClickClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
