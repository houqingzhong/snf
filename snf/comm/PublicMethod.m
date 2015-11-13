//
//  PublicMethod.m
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "PublicMethod.h"
#import "SNFHeader.h"
#import <sys/xattr.h>

NSString *FormattedTimeStringFromTimeInterval(NSTimeInterval timeInterval) {
    
    NSString *timeString = nil;
    const int secsPerMin = 60;
    const int minsPerHour = 60;
    const char *timeSep = ":";
    NSTimeInterval seconds = timeInterval;
    seconds = floor(seconds);
    
    if(seconds < 60.0) {
        timeString = [NSString stringWithFormat:@"0:%02.0f", seconds];
    }
    else {
        int mins = seconds/secsPerMin;
        int secs = seconds - mins*secsPerMin;
        
        if(mins < 60.0) {
            timeString = [NSString stringWithFormat:@"%d%s%02d", mins, timeSep, secs];
        }
        else {
            int hours = mins/minsPerHour;
            mins -= hours * minsPerHour;
            timeString = [NSString stringWithFormat:@"%d%s%02d%s%02d", hours, timeSep, mins, timeSep, secs];
        }
    }
    return timeString;
}

@implementation PublicMethod

+ (void)saveDataToLocal:(id)obj key:(NSString *)key
{
    if (obj && key) {
        //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        //[[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        App(app);
        [app.localStore putObject:obj withId:key intoTable:server_data_cahce];
    }

}

+ (id)getLocalData:(NSString *)key
{
    if (key) {
        App(app);
        id obj = [app.localStore getObjectById:key fromTable:server_data_cahce];

        //id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        return obj;//[NSKeyedUnarchiver unarchiveObjectWithData:obj];
    }

    return nil;
}


+ (UInt64)getTimeNow
{

    UInt64 time = [[NSDate date] timeIntervalSince1970]*1000;

    return time;
}

+ (NSString*)dataToJsonString:(id)object
{
    
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted 
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


+ (void)allowGprsDownload:(BOOL)flag
{
//    [[NSUserDefaults standardUserDefaults] setObject:@(flag) forKey:];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    App(app);
    [app.localStore putObject:@{allow_3g_download:@(flag)} withId:allow_3g_download intoTable:setting_data_cache];

}

+ (void)allowGprsPlay:(BOOL)flag
{
//    [[NSUserDefaults standardUserDefaults] setObject:@(flag) forKey:@"allow_3g_play"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    App(app);
    [app.localStore putObject:@{allow_3g_play:@(flag)} withId:allow_3g_play intoTable:setting_data_cache];
}

+ (BOOL)isAllowPlayInGprs
{
    
    App(app);
    NSDictionary *dict = [app.localStore getObjectById:allow_3g_play fromTable:setting_data_cache];
    BOOL allow = [dict[allow_3g_play] boolValue];
    //BOOL allow = [[NSUserDefaults standardUserDefaults] boolForKey:@"allow_3g_play"];
    
    return allow;
}

+ (BOOL)isAllowDownloadInGprs
{
    App(app);
    //BOOL allow = [[app.localStore getObjectById:allow_3g_download fromTable:setting_data_cache] boolValue];
    //return [[NSUserDefaults standardUserDefaults] boolForKey:@"allow_3g_download"];
    NSDictionary *dict = [app.localStore getObjectById:allow_3g_download fromTable:setting_data_cache];
    BOOL allow = [dict[allow_3g_download] boolValue];
    
    return allow;
}

//http://developer.apple.com/library/ios/#qa/qa1719/_index.html
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    BOOL success = FALSE;
    if (&NSURLIsExcludedFromBackupKey > 0) {
        success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                 forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            //NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
    }else{
        assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
        
        const char* filePath = [[URL path] fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        success = (result == 0);
    }
    return success;
}

+ (NSString *)getDownloadPath
{
   NSString *docDir = [PublicMethod getDocumentPath];
    docDir = [docDir stringByAppendingPathComponent:@"video"];

    [PublicMethod createFolder:docDir];
    
    return docDir;
}

+ (NSString *)getDocumentPath
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [array lastObject];
    
    return docDir;
}

+ (void)createFolder:(NSString *)folder
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

+ (BOOL)play:(NSDictionary *)dict controller:(UIViewController *)targetController
{
    NSString *fileUrl = [NSString stringWithFormat:@"%@/video/%@",  Host, dict[@"file_name"]];
    
    NSURL *videoURL = [PublicMethod getDownloadFile:fileUrl];
    
    if (nil == videoURL) {
        
        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        newDict[@"md5"] = [fileUrl tb_MD5String];
        [PublicMethod download:newDict];
        return NO;
    }
    //    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"512fa609eade4ccd35fc4df95d9629f0" withExtension:@"f4v"];
    //    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"snf_jkfs" withExtension:@"mp4"];
    
    //    KxMovieViewController *player = [KxMovieViewController movieViewControllerWithContentPath:[videoURL path] parameters:nil];
    //    [self presentViewController:player animated:YES completion:nil];
    
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [targetController presentMoviePlayerViewControllerAnimated:player];
    return YES;
}

+ (void)download:(NSDictionary *)dict
{
    if (nil == dict) {
        return;
    }
    NSString *fileUrl = [NSString stringWithFormat:@"%@/video/%@",  Host, dict[@"file_name"]];

    [HttpEngine getDataFromServer:fileUrl key:[fileUrl tb_MD5String] callback:^(id obj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *file_url = obj[@"file_url"];
            
            if ([file_url hasPrefix:@"http://"] || [file_url hasPrefix:@"https://"]) {
                NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                newDict[@"file_url"] = file_url;
                [[DownloadClient sharedInstance] addTask:newDict];
            }

            [[DownloadClient sharedInstance] startDownload];
        });
    }];
}

+ (NSURL *)getDownloadFile:(NSString *)fileUrl
{
    NSString *docDir = [PublicMethod getDownloadPath];
    
    NSString *file = [NSString stringWithFormat:@"%@/%@.mp4", docDir, [fileUrl tb_MD5String]];
    
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

//移动下载完成的文件到目标文件夹   app在下载过程中crash 重启时会走这个逻辑
+ (void)moveToFolder:(NSURL *)location md5:(NSString *)fileUrlMd5
{
    
    if (nil == fileUrlMd5) {
        return;
    }
    
    NSString *docDir = [PublicMethod getDownloadPath];
    
    NSString *desPath = [NSString stringWithFormat:@"%@/%@.mp4", docDir, fileUrlMd5];
    
    NSError *error = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:desPath error:&error];
    
    // location是下载的临时文件目录,将文件从临时文件夹复制到沙盒
    [fileManager moveItemAtPath:location.path toPath:desPath error:&error];
}

@end
