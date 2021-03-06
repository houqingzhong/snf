//
//  AppDelegate.m
//  snf
//
//  Created by 调伏自己 on 15/11/5.
//  Copyright © 2015年 调伏自己. All rights reserved.
//

#import "AppDelegate.h"
#import "SNFHeader.h"
#import "WTALeftViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.localStore = [[YTKKeyValueStore alloc] initDBWithName:@"local-key-value"];
    NSString *tableName = server_data_cahce;
    [_localStore createTableWithName:tableName];
    tableName = setting_data_cache;
    [_localStore createTableWithName:tableName];
    
    self.reachability = [GCNetworkReachability reachabilityForInternetConnection];
    [self.reachability startMonitoringNetworkReachabilityWithHandler:^(GCNetworkReachabilityStatus status) {
        switch (status) {
            case GCNetworkReachabilityStatusWWAN:
                NSLog(@"-------GCNetworkReachabilityStatusWWAN------");
                [[DownloadClient sharedInstance] startDownload];
                break;
                
            case GCNetworkReachabilityStatusWiFi:
                NSLog(@"-------GCNetworkReachabilityStatusWiFi------");
                [[DownloadClient sharedInstance] startDownload];
                break;
            case GCNetworkReachabilityStatusNotReachable:
                NSLog(@"-------GCNetworkReachabilityStatusNotReachable------");
                [[DownloadClient sharedInstance] stopDownload:^(BOOL finshed) {
                    
                }];
                
                break;
            default:
                break;
        }
    }];
    


    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    [[self window] setTintColor:[UIColor purpleColor]];
    
    WTALeftViewController *leftViewController = [WTALeftViewController new];
    WTAZoomNavigationController *zoomNavigationController = [[WTAZoomNavigationController alloc] initWithZoomFactor:200.0f];
    [zoomNavigationController setSpringAnimationOn:YES];
    [zoomNavigationController setLeftViewController:leftViewController];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [imageView setContentMode:UIViewContentModeCenter];
    [zoomNavigationController setBackgroundView:imageView];
    
    [[self window] setRootViewController:zoomNavigationController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    NSLog(@"downlaod  completionHandler");
    
    [[DownloadClient sharedInstance] setCompleteHandler:completionHandler identifier:identifier];
    
}

@end
