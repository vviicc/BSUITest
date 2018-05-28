//
//  BSUIRootController.m
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import "BSUIRootController.h"
#import "BSUITestLogic.h"
#import "BSUIRecordListController.h"

typedef NS_ENUM(NSInteger, BSRecordLabelTag) {
    BSRecordLabelTag_StartRecord = 0,
    BSRecordLabelTag_StopRecord
};

@interface BSUIRootController ()

@property (nonatomic, strong) UILabel *recordLabel;

@end

@implementation BSUIRootController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.recordLabel.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - 76) / 2.0, 2, 76, 34);
    
    if (!CGPointEqualToPoint(CGPointZero, self.viewCenter)) {
        self.recordLabel.center = self.viewCenter;
    }
}

- (void)initViews
{
    [self.view addSubview:self.recordLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapRecord)];
    [self.recordLabel addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPressRecord)];
    [self.recordLabel addGestureRecognizer:pressGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.recordLabel addGestureRecognizer:panGesture];
}

- (void)onTapRecord
{
    if (self.recordLabel.tag == BSRecordLabelTag_StartRecord) {
        self.recordLabel.tag = BSRecordLabelTag_StopRecord;
        self.recordLabel.text = @"结束录制\n录制中...";
        
        [[BSUITestLogic sharedInstance] startRecord];
    } else if (self.recordLabel.tag == BSRecordLabelTag_StopRecord) {
        self.recordLabel.tag = BSRecordLabelTag_StartRecord;
        self.recordLabel.text = @"轻点录制\n长按更多";
        
        [[BSUITestLogic sharedInstance] stopRecord];

        [self showSaveRecordView];
    }
}

- (void)showSaveRecordView
{
    if ([BSUITestLogic sharedInstance].logTouchs.count == 0) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"保存此次录制" message:@"给此次录制命名" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"eg:用户登录用例";
        textField.text = @"测试用例";
    }];
    
    __weak __typeof(self)weakSelf = self;
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *recName = alertController.textFields.firstObject.text;
        if (recName.length == 0) {
            recName = @"测试用例";
        }
        
        [[BSUITestLogic sharedInstance] saveRecord:recName];
        [weakSelf replayRecord];
    }];
    
    [alertController addAction:saveAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)replayRecord
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"回放" message:@"输入回放次数\n回放前请确保场景和开始录制时一致" preferredStyle:UIAlertControllerStyleAlert];
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
        
        [[BSUITestLogic sharedInstance] replayLastRecord:recCount.intValue complete:^{
        }];
    }];
    
    [alertController addAction:replayAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)onPressRecord
{
    [self presentViewController:[BSUIRecordListController new] animated:YES completion:nil];
}

- (BOOL)shouldReceiveTouch:(CGPoint)point
{
    BOOL shouldReceiveTouch = NO;
    
    CGPoint pointInLocalCoordinates = [self.view convertPoint:point fromView:nil];
    
    if (CGRectContainsPoint(self.recordLabel.frame, pointInLocalCoordinates)) {
        shouldReceiveTouch = YES;
    }
    
    if (!shouldReceiveTouch && self.presentedViewController) {
        shouldReceiveTouch = YES;
    }
    
    return shouldReceiveTouch;
}

#pragma mark - Gesture

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIGestureRecognizerState state = gestureRecognizer.state;
    
    if (state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self.view];
        self.recordLabel.center = CGPointMake(self.recordLabel.center.x + translation.x,
                                              self.recordLabel.center.y + translation.y);
        [gestureRecognizer setTranslation:CGPointZero inView:self.view];
    } else if (state == UIGestureRecognizerStateEnded) {
        CGPoint center = self.recordLabel.center;
        CGFloat newCenterX = center.x;
        CGFloat minCenterX = self.recordLabel.bounds.size.width / 2;
        CGFloat maxCenterX = [UIScreen mainScreen].bounds.size.width  - self.recordLabel.bounds.size.width / 2;
        if (newCenterX < minCenterX) {
            newCenterX = minCenterX;
        } else if  (newCenterX > maxCenterX) {
            newCenterX = maxCenterX;
        }
        
        CGFloat newCenterY = self.recordLabel.center.y;
        CGFloat minCenterY = self.recordLabel.bounds.size.height / 2;
        CGFloat maxCenterY = [UIScreen mainScreen].bounds.size.height  - self.recordLabel.bounds.size.height / 2;
        
        if (newCenterY < minCenterY) {
            newCenterY = minCenterY;
        } else if (newCenterY > maxCenterY) {
            newCenterY = maxCenterY;
        }
        
        self.recordLabel.center = CGPointMake(newCenterX, newCenterY);
    }
}

#pragma mark - getter

- (UILabel *)recordLabel
{
    if (!_recordLabel) {
        _recordLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _recordLabel.font = [UIFont systemFontOfSize:13];
        _recordLabel.textColor = [UIColor whiteColor];
        _recordLabel.textAlignment = NSTextAlignmentCenter;
        _recordLabel.userInteractionEnabled = YES;
        _recordLabel.text = @"轻点录制\n长按更多";
        _recordLabel.adjustsFontSizeToFitWidth = YES;
        _recordLabel.numberOfLines = 2;
        _recordLabel.layer.cornerRadius = 8;
        _recordLabel.layer.backgroundColor = [UIColor redColor].CGColor;
        _recordLabel.tag = BSRecordLabelTag_StartRecord;
    }
    
    return _recordLabel;
}


@end
