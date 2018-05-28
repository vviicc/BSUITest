//
//  BSUIRootController.h
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import <UIKit/UIKit.h>

@interface BSUIRootController : UIViewController

@property (nonatomic, assign) CGPoint viewCenter;

- (BOOL)shouldReceiveTouch:(CGPoint)point;

@end
