#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BSUITestFileHelper.h"
#import "BSUITestLogic.h"
#import "BSUITestManager.h"
#import "BSUIDiffImageController.h"
#import "BSUIRecordListController.h"
#import "BSUIRootController.h"
#import "BSUITestWindow.h"
#import "BSUIVideoCompareController.h"
#import "BSUIVideoListController.h"
#import "BSUIVideoPlayerController.h"
#import "BSUIVideoPlayerView.h"
#import "KTouchPointerWindow.h"
#import "PTFakeMetaTouch.h"
#import "SRScreenRecorder.h"
#import "UIImage+PHA.h"
#import "TPPreciseTimer.h"

FOUNDATION_EXPORT double BSUITestVersionNumber;
FOUNDATION_EXPORT const unsigned char BSUITestVersionString[];

