//
//  SNFHeader.h
//  snf
//
//  Created by 调伏自己 on 15/11/11.
//  Copyright © 2015年 调伏自己. All rights reserved.
//

#ifndef SNFHeader_h
#define SNFHeader_h

#define server_data_cahce  @"server_data_cahce"
#define setting_data_cache @"setting_data_cache"

#define NetworkError @"亲，您的手机网络不太顺畅喔～"


#define allow_3g_download   @"allow_3g_download"
#define allow_3g_play       @"allow_3g_play"

#define  kConfigCanDownloadStateChanged             @"kConfigCanDownloadStateChanged"
//#define  kConfigCanPlayStateChanged                       @"kConfigCanPlayStateChanged"
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
#import <AFNetworking.h>
#import <YTKKeyValueStore.h>
#import <GCNetworkReachability.h>
#import <TSMessage.h>
//#import <ALMoviePlayerController/ALMoviePlayerController.h>
#import "AppDelegate.h"
#import "PublicMethod.h"
#import "NSObject+Extend.h"
#import "DownloadClient.h"

#define App(s) AppDelegate * s = (AppDelegate *)[[UIApplication sharedApplication] delegate]

#endif /* SNFHeader_h */
