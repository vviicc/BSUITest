//
//  BSUITestManager.h
//  Pods
//
//  Created by Vic on 2018/5/28.
//

#import <Foundation/Foundation.h>

@import CoreGraphics;

@interface BSUITestManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, assign) BOOL enable;

@property (nonatomic, assign)  CGPoint windowCenter;

@end
