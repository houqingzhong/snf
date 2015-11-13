//
//  PublicMethod.h
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNFHeader.h"

NSString *FormattedTimeStringFromTimeInterval(NSTimeInterval timeInterval);

@interface PublicMethod : NSObject

//data save 
+ (id)getLocalData:(NSString *)key;
+ (void)saveDataToLocal:(id)obj key:(NSString *)key;

//network
+ (void)allowGprsDownload:(BOOL)flag;
+ (void)allowGprsPlay:(BOOL)flag;
+ (BOOL)isAllowDownloadInGprs;
+ (BOOL)isAllowPlayInGprs;

//file
+ (NSString *)getDownloadPath;
+ (NSString *)getDownloadFile:(NSString *)fileUrl;
+ (void)moveToFolder:(NSURL *)location md5:(NSString *)fileUrlMd5;
/**
 * 防止itunes 和 icloud自动备份特定的文件，譬如下载下来的视频等
 */
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;


//play
+ (BOOL)play:(NSDictionary *)dict controller:(UIViewController *)targetController;
//download
+ (void)download:(NSDictionary *)dict;
@end
