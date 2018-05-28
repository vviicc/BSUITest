//
//  BSUITestWindow.m
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import "BSUITestWindow.h"
#import "BSUIRootController.h"

@interface BSUITestWindow()

@property (nonatomic, strong) BSUIRootController *rootController;

@end

@implementation BSUITestWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar + 200.0;
        self.rootViewController = self.rootController;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL pointInside = [self.rootController shouldReceiveTouch:point];
    return pointInside;
}

#pragma mark - setter

- (void)setViewCenter:(CGPoint)viewCenter
{
    self.rootController.viewCenter = viewCenter;
}

#pragma mark - getter

- (BSUIRootController *)rootController
{
    if (!_rootController) {
        _rootController = [BSUIRootController new];
    }
    
    return _rootController;
}

@end
