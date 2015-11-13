//
//  SNFViewcontroller.m
//  snf
//
//  Created by 调伏自己 on 15/11/11.
//  Copyright © 2015年 调伏自己. All rights reserved.
//

#import "SNFViewcontroller.h"
#import "SNFHeader.h"

@interface SNFViewcontroller()<UITableViewDataSource, UITableViewDelegate>
{
    UIProgressView  *_downloadProgressView;
}
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSDictionary *dict;

@end

@implementation SNFViewcontroller

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [NSMutableArray new];
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"title"] = @"净空法师十念法－视频";
    dict[@"file_name"] = @"snf_jkfs";

    [self.dataArray addObject:dict];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _downloadProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];

    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate  = self;
    [self.view addSubview:self.tableview];

    _downloadProgressView.frame = CGRectMake(0, 60, self.view.width, 1);
    [self.view addSubview:_downloadProgressView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary *dict = _dataArray[indexPath.row];
    cell.textLabel.text = dict[@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = _dataArray[indexPath.row];
    
    BOOL isPlay = [PublicMethod play:dict controller:self];
    if (!isPlay) {
        WS(ws);
        [[DownloadClient sharedInstance] setCallback:^(CGFloat progress, NSString *md5, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            [ws  updateDownloadProgress:progress];
        }];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 60;
}

- (void)updateDownloadProgress:(CGFloat)progress
{
    _downloadProgressView.progress = progress;
}
@end
