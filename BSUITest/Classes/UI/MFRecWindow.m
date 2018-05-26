//
//  MFRecWindow.m
//  pkgame iOS
//
//  Created by Vic on 2018/5/14.
//

#import "MFRecWindow.h"
#import "MFRecMainController.h"

@interface MFRecWindow()
@property (nonatomic, strong) MFRecMainController *recMainController;
@end

@implementation MFRecWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar + 200.0;
        self.rootViewController = self.recMainController;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL pointInside = [self.recMainController shouldReceiveTouch:point];
    return pointInside;
}

#pragma mark - getter

- (MFRecMainController *)recMainController
{
    if (!_recMainController) {
        _recMainController = [MFRecMainController new];
    }
    
    return _recMainController;
}

@end
