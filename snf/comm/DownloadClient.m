//
//  DownloadClient.m
//  icar
//
//  Created by 调伏自己 on 15/10/19.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "DownloadClient.h"

#define DownloadPrefix @"MP3DOWNLOAD"

NSString * const APPURLSessionDownloadTaskDidFailToMoveFileNotification = @"APPURLSessionDownloadTaskDidFailToMoveFileNotification";

@interface  DownloadClient()
{
    NSProgress  *_progress;
}
@property (nonatomic, strong) AFURLSessionManager *downloadManager;
@property (nonatomic, assign)   AFNetworkReachabilityStatus status;
@end

@implementation DownloadClient

+ (DownloadClient *)sharedInstance {
    static DownloadClient *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(canCacheIn3GIsChanged:)
                                                     name:kConfigCanDownloadStateChanged
                                                   object:nil];

        self.downloadManager;
        
        self.dataArray  =[NSMutableArray new];
    }
    
    return self;
}

- (AFURLSessionManager *)downloadManager
{
    if (nil == _downloadManager) {
        _downloadManager = [self getAFURLSessionManager];
        [self config];
    }
    return _downloadManager;
}

- (AFURLSessionManager *)getAFURLSessionManager
{
    NSString* sessionIdentifier = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] bundleIdentifier]];
    
    NSURLSessionConfiguration *configuration;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:sessionIdentifier];
    }
    else{
        configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:sessionIdentifier];
    }
    
    [configuration setAllowsCellularAccess:[PublicMethod isAllowDownloadInGprs]];
    return [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
}


- (void)canCacheIn3GIsChanged:(NSNotification *)n
{
    [self invalidSession];
}

- (void)invalidSession
{
    
    [_downloadManager invalidateSessionCancelingTasks:YES];
    
    _downloadManager = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(reset) withObject:nil afterDelay:2];

}

- (void)reset
{
    self.downloadManager;
    [self startDownload];
}

- (void)config
{
    WS(ws);
    [_downloadManager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSString *md5 = nil;
        [ws parseMd5FromTask:downloadTask.taskDescription md5:&md5];
        if (md5) {
            CGFloat progress = (CGFloat)totalBytesWritten/totalBytesExpectedToWrite;
            NSLog(@"%lf", progress);
            
            if (ws.callback) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ws.callback(progress, md5, totalBytesWritten, totalBytesExpectedToWrite);
                });

            }
        }
                
    }];
    
    [_downloadManager setDownloadTaskDidFinishDownloadingBlock:^NSURL * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, NSURL * _Nonnull location) {
        
        NSString *md5 = nil;
        [ws parseMd5FromTask:downloadTask.taskDescription md5:&md5];
        if (md5) {
            
            [PublicMethod moveToFolder:location md5:md5];

        }

        return nil;
        
    }];
    
    [_downloadManager setTaskDidCompleteBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSError * _Nullable error) {
        
        if (error) {
            NSInteger statusCode = [(NSHTTPURLResponse *)task.response statusCode];
            if ((-1 == error.code && 0 == statusCode) || (2 == error.code && 200 == statusCode)) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    [ws invalidSession];
                });
                
                
            }
            else if (kCFURLErrorCancelled == error.code) {

            }
            else if (kCFURLErrorBackgroundSessionWasDisconnected == error.code) {
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ws startDownload];
                });

            }
            
            return ;
        }
        
        NSString *md5 = nil;
        [ws parseMd5FromTask:task.taskDescription md5:&md5];
        if (md5) {
            if (error) {
                NSLog(@"fail:  %@  %@", md5, error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [ws startDownload];
                    
                });

            }
            else
            {
                NSLog(@"sucess: %@", md5);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [ws removeTask:md5];
                    [ws startDownload];
                    
                });

                
            }
            
        }
        

    }];
    
    [_downloadManager setSessionDidBecomeInvalidBlock:^(NSURLSession * _Nonnull session, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws invalidSession];
            NSLog(@"DidBecomeInvalidBlock");
            
        });
    }];
    
    [_downloadManager setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession * _Nonnull session) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"FinishEventsForBackgroundURLSessionBlock");
            if (ws.backgroundSessionCompletionHandler) {
                ws.backgroundSessionCompletionHandler();
            }

        });
    }];
    
}

- (void)startTask:(NSString *)fileUrl md5:(NSString *)filePathMd5
{
    if (nil == filePathMd5 || nil == fileUrl) {
        return;
    }
    
    if(![[DownloadClient sharedInstance] hasNetwork])
    {
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:NetworkError
                                        type:TSMessageNotificationTypeMessage];
        
        return;
    }
    
    if([NSObject isNull:fileUrl])
    {
        return;
    }
    
    WS(ws);
    [_downloadManager.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        BOOL flag = NO;
        for (NSURLSessionDownloadTask *task in downloadTasks) {
            NSString *md5 = nil;
            [self parseMd5FromTask:task.taskDescription md5:&md5];
            
            if ([md5 isEqualToString:filePathMd5])
            {
                [task suspend];
                [task resume];
                flag = YES;
            }
            else
            {
                [task cancel];
            }
        }
        
        if (!flag) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
            NSURLSessionDownloadTask *task = [ws.downloadManager.session downloadTaskWithRequest:request];
            task.taskDescription = [NSString stringWithFormat:@"%@:%@", DownloadPrefix, filePathMd5];
            [task resume];
            NSLog(@"start downloading ...");
            NSLog(@"task  ...  %@", task.taskDescription);
            
        }
    }];
}

- (void)startDownload
{
    
    NSDictionary *dict = [self.dataArray firstObject];
    NSString *fileURL = dict[@"file_url"];
    if ([fileURL hasPrefix:@"http://"] || [fileURL hasPrefix:@"https://"]) {
        [self startTask:fileURL md5:dict[@"md5"]];
    }
}


- (void)addTask:(NSDictionary *)dict
{
    if (nil == dict) {
        return;
    }
    
    NSString *md5 = dict[@"md5"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"md5 == %@", md5];
    NSArray *dicts = [_dataArray filteredArrayUsingPredicate:pre];
    if (dicts.count > 0) {
        return;
    }
    
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    newDict[@"md5"] = md5;
    [self.dataArray addObject:newDict];
}

- (void)removeTask:(NSString *)md5
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"md5 == %@", md5];
    NSArray *dicts = [_dataArray filteredArrayUsingPredicate:pre];
    if (dicts.count > 0) {
        [_dataArray removeObjectsInArray:dicts];
    }
}

- (void)stopDownload:(void (^)(BOOL))callback
{
    [_downloadManager.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        
        for (NSURLSessionDownloadTask *task in downloadTasks) {
            [task cancel];
        }
        
        if (callback) {
            callback(YES);
        }
    }];
}
//- (void)delayDownload
//{
//    if(self.currentTask)
//    {
//        return;
//    }
//    
//    [PublicMethod getDownloadTask:^(NSDictionary *dict) {
//        NSDictionary *album = dict[@"album"];
//        NSDictionary *track = dict[@"track"];
//        if([track[@"download_state"] integerValue] != DownloadStateDownloadFinish)
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self startTask:album track:track];
//            });
//        }
//        
//    }];
//}

//- (BOOL)isFileDownloaded:(NSString *)fileUrl
//{
//        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *docDir = [array lastObject];
//        
//        docDir = [docDir stringByAppendingPathComponent:@"video"];
//    
//        [self createFolder:docDir];
//    
//        NSString *file = [NSString stringWithFormat:@"%@/%@", docDir, [fileUrl tb_MD5String]];
//
//        NSURL *filePath = [NSURL URLWithString:file];
//
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        if([fileManager fileExistsAtPath:filePath.absoluteString])
//        {
//
//            return YES;
//        }
//        else
//        {
//            return NO;
//        }
//}

- (void)parseMd5FromTask:(NSString *)taskDescription md5:(NSString **)md5
{

    if (!taskDescription) {
        return ;
    }
    
    if ([taskDescription hasPrefix:DownloadPrefix])
    {
        NSArray *strs = [taskDescription componentsSeparatedByString:@":"];
        if (strs.count == 2) {
            if (md5) {
                *md5 = strs[1];
            }
        }
    }
}

#pragma 后台任务完成回调设置
- (void)setCompleteHandler:(void (^)())completionHandler identifier:(NSString *)identifier
{
    self.backgroundSessionCompletionHandler = completionHandler;
}


-( void)clearOnLanch:(void (^)())callback
{
    [_downloadManager.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        for (NSURLSessionDownloadTask *task in downloadTasks) {
            [task cancel];
        }
        
        if (callback) {
            callback();
        }

    }];
}

- (void)currentDownload:(void (^)(NSString *md5))callback;
{
    WS(ws);
    [_downloadManager.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        NSString *md5 = nil;

        BOOL flag = NO;
        for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
            [ws parseMd5FromTask:downloadTask.taskDescription md5:&md5];
            if (NSURLSessionTaskStateRunning == downloadTask.state) {
                flag = YES;
                break;
            }
        }
        
        if (flag && callback) {
            callback(md5);
        }
    }];

    
}

- (BOOL)hasNetwork
{
    App(app);
    return GCNetworkReachabilityStatusNotReachable != app.reachability.currentReachabilityStatus;
}

- (BOOL)isWifi
{
    App(app);
    return GCNetworkReachabilityStatusWiFi == app.reachability.currentReachabilityStatus;
}

- (BOOL)is3G
{
    App(app);
    return GCNetworkReachabilityStatusWWAN == app.reachability.currentReachabilityStatus;
}


-(void)isDownloading:(void (^)(BOOL))callback;
{

    [_downloadManager.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {

        BOOL flag = (downloadTasks.count > 0) ? YES : NO;
        
        if (callback) {
            callback(flag);
        }
        
    }];
}

- (void)allow3GDownload
{
    [self invalidSession];
}

//
//- (BOOL)getDownloadPath:(NSDictionary *)album
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docDir = [array lastObject];
//    
//    docDir = [docDir stringByAppendingPathComponent:@"mp3"];
//    NSString *folder = [docDir stringByAppendingPathComponent:album[@"id"]];
//    
//    [self createFolder:folder];
//    
//    NSString *file = [NSString stringWithFormat:@"%@/%@.m4a", folder, track[@"id"]];
//    
//        NSURL *filePath = [NSURL URLWithString:file];
//    
//        if([fileManager fileExistsAtPath:filePath.absoluteString])
//        {
//    
//            return YES;
//        }
//        else
//        {
//            return NO;
//        }
//    
//}
//
@end
