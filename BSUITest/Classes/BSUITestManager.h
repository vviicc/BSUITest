//
//  BSUITestManager.h
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import <Foundation/Foundation.h>

@interface BSUITestManager : NSObject

+ (instancetype)sharedManager;

/**
 开启UITest

 @param enable 是否开启
 */
- (void)setEnable:(BOOL)enable;

/**
 设置center，如果不设置默认在顶部居中

 @param viewCenter 中心点
 */
- (void)setViewCenter:(CGPoint)viewCenter;

@end
