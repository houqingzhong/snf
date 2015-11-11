//
//  SNFHeader.h
//  snf
//
//  Created by 调伏自己 on 15/11/11.
//  Copyright © 2015年 调伏自己. All rights reserved.
//

#ifndef SNFHeader_h
#define SNFHeader_h
#define App(s) AppDelegate * s = (AppDelegate *)[[UIApplication sharedApplication] delegate]


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define ScreenSize [[UIScreen mainScreen] bounds].size
#define XA ScreenSize.width/640
#define WS(s) __weak typeof (self) s = self


#import <WTAZoomNavigationController.h>
//#import <PBJVideoPlayer/PBJVideoPlayer.h>
//#import <FFmpegWrapper.h>
//#import <VideoPlayerKit.h>
//#import <PLPlayerKit/PLPlayer.h>
//#import <KxMovieViewController.h>
#import <KRVideoPlayerController.h>
#import <UIView+TKGeometry.h>
#import <StandardPaths.h>
//#import <ALMoviePlayerController/ALMoviePlayerController.h>

#endif /* SNFHeader_h */
