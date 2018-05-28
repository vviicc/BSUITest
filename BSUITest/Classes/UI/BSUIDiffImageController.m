//
//  BSUIDiffImageController.m
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import "BSUIDiffImageController.h"

@interface BSUIDiffImageController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation BSUIDiffImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.closeBtn.frame = CGRectMake(0, 0, 50, 40);
    self.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 20);
    self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    self.pageControl.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 10, CGRectGetWidth(self.view.bounds), 10);
}

- (void)initViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat srollViewight = [UIScreen mainScreen].bounds.size.height;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(screenWidth * 2, srollViewight);
    [self.view addSubview:self.scrollView];
    
    self.titleLabel = [self titleLabel:@"录制时图片"];
    [self.view addSubview:self.titleLabel];
    
    UIImageView *recImageView = [[UIImageView alloc] initWithImage:self.recImage];
    recImageView.frame = CGRectMake(0, 0, screenWidth, srollViewight);
    [self.scrollView addSubview:recImageView];
    
    UIImageView *replayImageView = [[UIImageView alloc] initWithImage:self.replayImage];
    replayImageView.frame = CGRectMake(screenWidth, 0, screenWidth, srollViewight);
    [self.scrollView addSubview:replayImageView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    self.pageControl.numberOfPages = 2;
    [self.view addSubview:self.pageControl];
    
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == [UIScreen mainScreen].bounds.size.width) {
        self.titleLabel.text = @"回放时图片";
        self.pageControl.currentPage = 1;
    } else if (scrollView.contentOffset.x == 0){
        self.titleLabel.text = @"录制时图片";
        self.pageControl.currentPage = 0;
    }
}

@end
