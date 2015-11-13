//
//  DownloadClient.h
//  icar
//
//  Created by 调伏自己 on 15/10/19.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNFHeader.h"

@interface DownloadClient : NSObject
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) void (^backgroundSessionCompletionHandler)();
@property (nonatomic, strong) void (^callback)(CGFloat progress, NSString *md5, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);

+ (DownloadClient *)sharedInstance;


- (void)setCompleteHandler:(void (^)())completionHandler identifier:(NSString *)identifier;

//task
-( void)clearOnLanch:(void (^)())callback;
- (void)startDownload;
- (void)stopDownload:(void (^)(BOOL))callback;
- (void)currentDownload:(void (^)(NSString *md5))callback;

- (void)addTask:(NSDictionary *)dict;


//network handle
- (BOOL)hasNetwork;
- (BOOL)isWifi;
- (BOOL)is3G;
- (void)isDownloading:(void (^)(BOOL))callback;
- (void)allow3GDownload;

@end
