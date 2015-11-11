//
//  AppDelegate.h
//  snf
//
//  Created by 调伏自己 on 15/11/5.
//  Copyright © 2015年 调伏自己. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YTKKeyValueStore;
@class GCNetworkReachability;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) YTKKeyValueStore  *localStore;

@property (strong, nonatomic) GCNetworkReachability *reachability;

@end

