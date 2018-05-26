//
//  MFRecReplay.h
//  pkgame iOS
//
//  Created by Vic on 2018/5/18.
//

#import <Foundation/Foundation.h>

@class RPPreviewViewController;

@interface MFRecReplay : NSObject

+ (instancetype)sharedInstance;

- (void)startReplay:(NSURL *)fileURL;

- (void)stopReplay:(dispatch_block_t)complete;


@end
