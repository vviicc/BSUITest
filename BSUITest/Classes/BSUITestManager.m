//
//  BSUITestManager.m
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import "BSUITestManager.h"
#import "BSUITestWindow.h"
#import "BSUITestLogic.h"

@interface BSUITestManager()

@property (nonatomic, strong) BSUITestWindow *uiTestWindow;

@end

@implementation BSUITestManager

+ (instancetype)sharedManager
{
    static BSUITestManager *sharedMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMgr = [[BSUITestManager alloc] init];
    });
    
    return sharedMgr;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.uiTestWindow.hidden = NO;
        
        [BSUITestLogic sharedInstance].recWindow = self.uiTestWindow;
        [[BSUITestLogic sharedInstance] hookSendEvent];
    }
    
    return self;
}

#pragma mark - setter

- (void)setEnable:(BOOL)enable
{
    self.uiTestWindow.hidden = !enable;
}

- (void)setViewCenter:(CGPoint)viewCenter
{
    self.uiTestWindow.viewCenter = viewCenter;
}

#pragma mark - getter

- (BSUITestWindow *)uiTestWindow
{
    if (!_uiTestWindow) {
        _uiTestWindow = [[BSUITestWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    return _uiTestWindow;
}

@end
