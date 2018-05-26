//
//  TPPreciseTimer.h
//  Loopy
//
//  Created by Michael Tyson on 06/09/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPPreciseTimer : NSObject {
    double timebase_ratio;
    
    NSMutableArray *events;
    NSCondition *condition;
    pthread_t thread;
}

+ (void)scheduleAction:(SEL)action target:(id)target inTimeInterval:(NSTimeInterval)timeInterval;
+ (void)scheduleAction:(SEL)action target:(id)target context:(id)context inTimeInterval:(NSTimeInterval)timeInterval;
+ (void)cancelAction:(SEL)action target:(id)target;
+ (void)cancelAction:(SEL)action target:(id)target context:(id)context;
#if NS_BLOCKS_AVAILABLE
+ (void)scheduleBlock:(void (^)(void))block inTimeInterval:(NSTimeInterval)timeInterval;
#endif

@end
