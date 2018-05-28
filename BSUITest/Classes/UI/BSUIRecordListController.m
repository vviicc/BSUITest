//
//  BSUIRecordListController.m
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import "BSUIRecordListController.h"
#import "BSUIVideoListController.h"
#import "BSUITestLogic.h"
#import "BSUITestFileHelper.h"

static NSString * const kBSRecordListCellIdentifier  = @"kBSRecordListCellIdentifier";

@interface BSRecordListCell : UITableViewCell

- (void)updateCell:(NSString *)name date:(NSString *)date cellIndex:(int32_t)cellIndex;

@property (nonatomic, copy) void(^didClickReplay)(int32_t cellIndex);
@property (nonatomic, copy) void(^didClickVideo)(int32_t cellIndex);

@end

@interface BSRecordListCell()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *playbackBtn;
@property (nonatomic, strong) UIButton *videoBtn;

@property (nonatomic, assign) int32_t cellIndex;
@end

@implementation BSRecordListCell

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
    
    self.nameLabel.frame = CGRectMake(10, 20, CGRectGetWidth(self.bounds) - 150, 16);
    self.dateLabel.frame = CGRectMake(10, 42, CGRectGetWidth(self.bounds) - 150, 14);
    self.playbackBtn.frame = CGRectMake(CGRectGetWidth(self.bounds) - 150, 0, 70, CGRectGetHeight(self.bounds));
    self.videoBtn.frame = CGRectMake(CGRectGetMaxX(self.playbackBtn.frame) + 5, 0, 70, CGRectGetHeight(self.bounds));
}

- (void)initViews
{
    UIView *contentView = self.contentView;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.font = [UIFont systemFontOfSize:15];
    [contentView addSubview:self.nameLabel];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.dateLabel.textColor = [UIColor lightGrayColor];
    self.dateLabel.font = [UIFont systemFontOfSize:13];
    [contentView addSubview:self.dateLabel];
    
    self.playbackBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.playbackBtn setTitle:@"用例回放" forState:UIControlStateNormal];
    [self.playbackBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.playbackBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.playbackBtn addTarget:self action:@selector(onClickReplay) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:self.playbackBtn];
    
    self.videoBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.videoBtn setTitle:@"查看录屏" forState:UIControlStateNormal];
    self.videoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.videoBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.videoBtn addTarget:self action:@selector(onClickRecVideo) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:self.videoBtn];
}

- (void)updateCell:(NSString *)name date:(NSString *)date cellIndex:(int32_t)cellIndex
{
    self.nameLabel.text = name;
    self.dateLabel.text = date;
    self.cellIndex = cellIndex;
}

- (void)onClickReplay
{
    if (self.didClickReplay) {
        self.didClickReplay(self.cellIndex);
    }
}

- (void)onClickRecVideo
{
    if (self.didClickVideo) {
        self.didClickVideo(self.cellIndex);
    }
}

@end

@interface BSUIRecordListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *screenRecLabel;
@property (nonatomic, strong) UISwitch *screenRecSwitch;
@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) NSMutableArray<NSString *> *recFileNames;

@end

@implementation BSUIRecordListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recFileNames = [NSMutableArray arrayWithArray:[BSUITestFileHelper historyRecordPath]];
    
    [self initViews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.closeBtn.frame = CGRectMake(0, 20, 50, 44);
    self.tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64);
    self.emptyLabel.frame = self.tableView.bounds;
    self.titleLabel.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), 44);
    self.screenRecLabel.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.bounds) - 65, 44);
    self.screenRecSwitch.frame = CGRectMake(CGRectGetMaxX(self.screenRecLabel.frame) + 5, 25, 0, 0);
}

- (void)initViews
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.rowHeight = 66;
    [tableView registerClass:[BSRecordListCell class] forCellReuseIdentifier:kBSRecordListCellIdentifier];
    self.tableView = tableView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    
    self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.emptyLabel.text = @"没有录制文件\n录制并保存后再来看看";
    self.emptyLabel.numberOfLines = 2;
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.textColor = [UIColor lightGrayColor];
    [self.tableView addSubview:self.emptyLabel];
    self.emptyLabel.hidden = self.recFileNames.count != 0;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    [btn setTitle:@"←" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onClickClose) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn = btn;
    [self.view addSubview:btn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"最近录制";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    self.titleLabel = titleLabel;
    [self.view addSubview:titleLabel];
    
    UILabel *screenRecLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    screenRecLabel.text = @"录屏";
    screenRecLabel.textColor = [UIColor redColor];
    screenRecLabel.font = [UIFont boldSystemFontOfSize:15];
    screenRecLabel.textAlignment = NSTextAlignmentRight;
    self.screenRecLabel = screenRecLabel;
    [self.view addSubview:screenRecLabel];
    
    UISwitch *screenRecSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    screenRecSwitch.tintColor = [UIColor redColor];
    screenRecSwitch.onTintColor = [UIColor redColor];
    [screenRecSwitch setOn:[BSUITestLogic sharedInstance].screenRecEnable animated:NO];
    [screenRecSwitch addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    self.screenRecSwitch = screenRecSwitch;
    [self.view addSubview:screenRecSwitch];
    
    [self.tableView reloadData];
}

- (void)onSwitchChanged:(UISwitch *)aSwitch
{
    BOOL isEnable = aSwitch.isOn;
    [BSUITestLogic sharedInstance].screenRecEnable = isEnable;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recFileNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSRecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:kBSRecordListCellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row >= self.recFileNames.count) {
        return cell;
    }
    
    NSString *filePath = self.recFileNames[indexPath.row];
    [BSUITestFileHelper parseFileName:filePath recordInfoBlock:^(NSString *name, NSString *date, NSString *duration) {
        [cell updateCell:name date:[NSString stringWithFormat:@"%@ / %@", date, [NSString stringWithFormat:@"%@秒",@(duration.intValue)]] cellIndex:(int32_t)indexPath.row];
    }];
    
    __weak __typeof(self)weakSelf = self;
    cell.didClickReplay = ^(int32_t cellIndex) {
        if (cellIndex < weakSelf.recFileNames.count) {
            NSString *fileName = weakSelf.recFileNames[cellIndex];
            [weakSelf replayRecord:fileName];
        }
    };
    
    cell.didClickVideo = ^(int32_t cellIndex) {
        NSArray *array = [filePath componentsSeparatedByString:@"_"];
        NSString *recName = array[0];
        NSString *recTimestamp = array[1];
        
        BSUIVideoListController *videoListController = [[BSUIVideoListController alloc] init];
        videoListController.recName = recName;
        videoListController.recTimestamp = recTimestamp;
        
        [weakSelf presentViewController:videoListController animated:YES completion:nil];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= self.recFileNames.count) {
        return;
    }
    
    NSString *filePath = self.recFileNames[indexPath.row];
    [self replayRecord:filePath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row >= self.recFileNames.count) {
            return;
        }
        
        NSString *recName = self.recFileNames[indexPath.row];
        [self.recFileNames removeObjectAtIndex:indexPath.row];
        [BSUITestFileHelper removeRecord:recName];
        self.emptyLabel.hidden = self.recFileNames.count != 0;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (void)replayRecord:(NSString *)filePath
{
    __weak __typeof(self)weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"回放" message:@"输入回放循环次数\n回放前请确保场景和开始录制时一致" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"eg:2";
        textField.text = @"1";
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"暂不回放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction *replayAction = [UIAlertAction actionWithTitle:@"开始回放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *recCount = alertController.textFields.firstObject.text;
        if (recCount.length == 0) {
            recCount = @"1";
        }
        
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [[BSUITestLogic sharedInstance] replayHistoryRecord:filePath repeatCount:recCount.intValue complete:^{
            }];
        }];
    }];
    
    [alertController addAction:replayAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)onClickClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
