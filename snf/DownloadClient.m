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
@property (nonatomic, strong) NSURLSessionDownloadTask *currentTask;
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
    
    self.currentTask = nil;
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

        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [array lastObject];
        
        NSString *folder = [docDir stringByAppendingPathComponent:@"mp3"];

        
        [self createFolder:folder];
        
        self.downloadManager;

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
        NSString *albumId = nil;
        NSString *trackId = nil;
        [ws parseInfoFromTask:downloadTask.taskDescription albumId:&albumId trackId:&trackId];
        if (albumId && trackId) {
            CGFloat progress = (CGFloat)totalBytesWritten/totalBytesExpectedToWrite;
            NSLog(@"%lf", progress);
            
            if (ws.callback) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ws.callback(progress, albumId, trackId, totalBytesWritten, totalBytesExpectedToWrite);
                });

            }
        }
                
    }];
    
    [_downloadManager setDownloadTaskDidFinishDownloadingBlock:^NSURL * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, NSURL * _Nonnull location) {
        
        NSString *albumId = nil;
        NSString *trackId = nil;
        [ws parseInfoFromTask:downloadTask.taskDescription albumId:&albumId trackId:&trackId];
        if (albumId && trackId) {
            
            [ws moveToFolder:location albumId:albumId trackId:trackId];
            
        }

        return nil;
        
    }];
    
    [_downloadManager setTaskDidCompleteBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSError * _Nullable error) {
        
        ws.currentTask = nil;
        if (error) {
            NSInteger statusCode = [(NSHTTPURLResponse *)task.response statusCode];
            if ((-1 == error.code && 0 == statusCode) || (2 == error.code && 200 == statusCode)) {

                [ws invalidSession];
                
            }
            else if (kCFURLErrorCancelled == error.code) {

            }
            else if (kCFURLErrorBackgroundSessionWasDisconnected == error.code) {
                
            }
            else
            {
                [ws startDownload];
            }
            
            return ;
        }
        
        NSString *albumId = nil;
        NSString *trackId = nil;
        [ws parseInfoFromTask:task.taskDescription albumId:&albumId trackId:&trackId];
        if (albumId && trackId) {
            if (error) {
                NSLog(@"fail: %@  %@  %@", albumId, trackId, error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    [ws startDownload];
                    
                });

            }
            else
            {
                NSLog(@"sucess: %@  %@", albumId, trackId);
                

              
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    ws.currentTask = nil;
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

- (void)startTask:(NSDictionary *)album track:(NSDictionary *)track
{
    
    if(![[DownloadClient sharedInstance] hasNetwork])
    {
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:NetworkError
                                        type:TSMessageNotificationTypeMessage];
        
        return;
    }
    
    NSString * url =  track[@"play_path"];
    if([NSObject isNull:url])
    {
        return;
    }
    
    WS(ws);
    [_downloadManager.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        BOOL flag = NO;
        for (NSURLSessionDownloadTask *task in downloadTasks) {
            NSString *albumId_ = nil;
            NSString *trackId_ = nil;
            [self parseInfoFromTask:task.description albumId:&albumId_ trackId:&trackId_];
            
            if ((albumId_.integerValue == [album[@"id"] integerValue])  && (trackId_.integerValue == [track[@"id"] integerValue])) {
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
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

            ws.currentTask = [ws.downloadManager.session downloadTaskWithRequest:request];
            ws.currentTask.taskDescription = [NSString stringWithFormat:@"%@:%@:%@", DownloadPrefix, album[@"id"], track[@"id"]];
            [ws.currentTask resume];
            NSLog(@"start downloading ...");
            NSLog(@"task  ...  %@", ws.currentTask.taskDescription);
            
        }
        
    }];
    
}

- (void)startDownload
{
    
    if(self.currentTask)
    {
        return;
    }
    
//    [PublicMethod getDownloadTask:^(NSDictionary *dict) {
//        NSDictionary *album = dict[@"album"];
//        NSDictionary *track = dict[@"track"];
//        if([track[@"download_state"] integerValue] != DownloadStateDownloadFinish)
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self startTask:album track:track];
//            });
//
//        }
//        
//    }];

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

- (NSURL *)getDownloadFile:(NSDictionary *)album track:(NSDictionary *)track
{
    NSString *docDir = [PublicMethod getDownloadPath];
    
    NSString *folder = [docDir stringByAppendingPathComponent:album[@"id"]];
    
    [self createFolder:folder];
    
    NSString *file = [NSString stringWithFormat:@"%@/%@.m4a", folder, track[@"id"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *filePath = [NSURL URLWithString:file];
    
    if([fileManager fileExistsAtPath:filePath.absoluteString])
    {
        
        return filePath;
    }
    else
    {
        return nil;
    }
    
}

- (BOOL)isFileDownloaded:(NSString *)albumId trackId:(NSString *)trackId
{
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [array lastObject];
        
        docDir = [docDir stringByAppendingPathComponent:@"mp3"];
        NSString *folder = [docDir stringByAppendingPathComponent:albumId];
        
        [self createFolder:folder];
    
        NSString *file = [NSString stringWithFormat:@"%@/%@.m4a", folder, trackId];

        NSURL *filePath = [NSURL URLWithString:file];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:filePath.absoluteString])
        {

            return YES;
        }
        else
        {
            return NO;
        }
}

//移动下载完成的文件到目标文件夹   app在下载过程中crash 重启时会走这个逻辑
- (void)moveToFolder:(NSURL *)location albumId:(NSString *)albumId trackId:(NSString *)trackId
{
    
    if (!albumId || !trackId) {
        return;
    }
    
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [array lastObject];
    
    docDir = [docDir stringByAppendingPathComponent:@"mp3"];
    NSString *folder = [docDir stringByAppendingPathComponent:albumId];
    
    [self createFolder:folder];
    
    NSString *desPath = [NSString stringWithFormat:@"%@/%@.m4a", folder, trackId];
    
    NSError *error = nil;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:desPath error:&error];
    
    // location是下载的临时文件目录,将文件从临时文件夹复制到沙盒
    [fileManager moveItemAtPath:location.path toPath:desPath error:&error];
}

- (void)parseInfoFromTask:(NSString *)taskDescription albumId:(NSString **)albumId trackId:(NSString **)trackId
{
//MP3DOWNLOAD:2792958:7967732

    if (!taskDescription) {
        return ;
    }
    
    if ([taskDescription hasPrefix:DownloadPrefix])
    {
        NSArray *strs = [taskDescription componentsSeparatedByString:@":"];
        if (strs.count == 3) {
            if (albumId) {
                *albumId = strs[1];
            }
            
            if (trackId) {
                *trackId = strs[2];
            }
        }
    }
}

- (void)createFolder:(NSString *)folder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:folder isDirectory:&isDir];
    if (!(isDirExist && isDir)) {
        NSError *error = nil;
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
        if(!bCreateDir)
        {
            NSLog(@"Create Audio Directory Failed.");
        }
        [PublicMethod addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:folder]];
    }
}

#pragma 后台任务完成回调设置
- (void)setCompleteHandler:(void (^)())completionHandler identifier:(NSString *)identifier
{
    self.backgroundSessionCompletionHandler = completionHandler;
}


-( void)clearOnLanch
{

    [_downloadManager.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionDownloadTask *task in downloadTasks) {
            [task cancel];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startDownload];
        });

    }];
}

- (void)currentDownloadTask
{

    NSString *albumId = nil;
    NSString *trackId = nil;
    [self parseInfoFromTask:_currentTask.taskDescription albumId:&albumId trackId:&trackId];
    
//    [PublicMethod getDownloadTracks:albumId trackId:trackId callback:^(NSDictionary *dict) {
//        
//    }];
}

- (NSString *)getDownloadPath:(NSDictionary *)album
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [array lastObject];
    
    docDir = [docDir stringByAppendingPathComponent:@"mp3"];
    NSString *folder = [docDir stringByAppendingPathComponent:album[@"id"]];
    
    [self createFolder:folder];

    return folder;
    
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

        __block BOOL flag = (downloadTasks.count > 0) ? YES : NO;
        
        if (!flag) {
//            [PublicMethod getDownloadTask:^(NSDictionary *dict) {
//                flag = dict ? YES : NO;
//                
//                if (callback) {
//                    callback(flag);
//                }
//            }];
        }
        else
        {
            if (callback) {
                callback(flag);
            }
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
